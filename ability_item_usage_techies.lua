--require(GetScriptDirectory() ..  "/ability_item_usage_generic")
local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
--local inspect = require(GetScriptDirectory() ..  "/inspect")
--local enemyStatus = require(GetScriptDirectory() .. "/enemy_status" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end


local castDCDesire = 0;
local castIGDesire = 0;
local castFBDesire = 0;
local castOODesire = 0;
local threshold = 0.25;

function AbilityUsageThink()

	local npcBot = GetBot();
	--print(npcBot:GetActiveMode())
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityIG = npcBot:GetAbilityByName( "techies_land_mines" );
	abilityFB = npcBot:GetAbilityByName( "techies_stasis_trap" );
	abilityDC = npcBot:GetAbilityByName( "techies_suicide" );
	abilityOO = npcBot:GetAbilityByName( "techies_remote_mines" );
	

	-- Consider using each ability
	castDCDesire, castDCLocation = ConsiderDecay();
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castIGDesire, castIGTarget = ConsiderIgnite();
	castFBDesire, castFBTarget = ConsiderFireblast();
	
	castSoulRing();
	
	if ( castIGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityIG, castIGTarget );
		return;
	end
	
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityDC, castDCLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityFB, castFBTarget );
		return;
	end

	
end

function CanCastDecayOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastIgniteOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function SoulRingAvailable()
	local npcBot = GetBot();
    for i = 0, 5 
	do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == "item_soul_ring") then
				return item;
			end
		end
    end
    return nil;
end

function castSoulRing()
    local npcBot = GetBot();
	local sr=SoulRingAvailable()
    if sr~=nil and sr:IsFullyCastable() and npcBot:GetHealth() > 2 * 150
	then
		local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
		if ( abilityIG:IsCooldownReady() or  abilityFB:IsCooldownReady() or  abilityDC:IsCooldownReady() or  abilityOO:IsCooldownReady() ) and
			currManaRatio < 0.75
		then	
			npcBot:Action_UseAbility(sr);
			return
		end
	end
end

function ConsiderIgnite()
	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityIG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	local inRadius = false;
	local nCastRange = abilityIG:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange);

	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_techies_land_mine"
		then
			if GetUnitToLocationDistance(u, vLocation) <= 400 then
				inRadius = true
				break;
			end
		end
	end

	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	if not inRadius and currManaRatio > threshold and npcBot:DistanceFromFountain() > 1500 and DotaTime() > 0 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not inRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers > 0 and not tableNearbyEnemyTowers[1]:IsInvulnerable() and not inRadius then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyTowers[1]:GetLocation() + RandomVector(100);
		end
	end
	
	if (  npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT  ) 
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() and not inRadius then
			return BOT_ACTION_DESIRE_LOW, tableNearbyAllyTowers[1]:GetLocation() + RandomVector(100);
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget( npcTarget ) and not inRadius ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	local npcBot = GetBot();
	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local unit = GetUnitList(UNIT_LIST_ALLIES);
	local inRadius = false;
	local nCastRange = abilityFB:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange);

	for _,u in pairs (unit)
	do
		if u:GetUnitName() == "npc_dota_techies_stasis_trap"
		then
			if GetUnitToLocationDistance(u, vLocation) <= 600 then
				inRadius = true
				break;
			end
		end
	end
	
	if not inRadius then
		castSoulRing()
	end
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	if not inRadius and currManaRatio > threshold and npcBot:DistanceFromFountain() > 1500 and DotaTime() > 0 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not inRadius ) 
			then
				return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	
	if (  npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT  ) 
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() and not inRadius then
			return BOT_ACTION_DESIRE_LOW, tableNearbyAllyTowers[1]:GetLocation() + RandomVector(100);
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget( npcTarget ) and not inRadius ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderDecay()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nRadius = abilityDC:GetSpecialValueInt( "radius" );
	local nCastRange = abilityDC:GetCastRange();
	local nCastPoint = abilityDC:GetCastPoint( );
	local nDamage = abilityDC:GetSpecialValueInt("damage");
	local nHPP = npcBot:GetHealth() / npcBot:GetMaxHealth();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if nHPP >= 0.65 then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange);
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0.1, 10000 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nCastRange + 200  ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 and CanCastDecayOnTarget( npcTarget ) ) 
		then
			local EnemyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if ( #EnemyHeroes >= 1 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local npcBot = GetBot();
	
	local unit = GetUnitList(UNIT_LIST_ALLIES);
	local inRadius = false;
	local nCastRange = abilityOO:GetCastRange();
	local vLocation = npcBot:GetXUnitsInFront(nCastRange);

	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
	if  currManaRatio > threshold and npcBot:DistanceFromFountain() > 1000 then
		return BOT_ACTION_DESIRE_LOW, vLocation;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and not inRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers > 0 and not tableNearbyEnemyTowers[1]:IsInvulnerable() and not inRadius then
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyTowers[1]:GetLocation() + RandomVector(100);
		end
	end
	
	if (  npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT  ) 
	then
		local tableNearbyAllyTowers = npcBot:GetNearbyTowers( 800, false );
		if tableNearbyAllyTowers ~= nil and #tableNearbyAllyTowers > 0 and not tableNearbyAllyTowers[1]:IsInvulnerable() and not inRadius then
			return BOT_ACTION_DESIRE_LOW, tableNearbyAllyTowers[1]:GetLocation() + RandomVector(100);
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastIgniteOnTarget( npcTarget ) and not inRadius ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, 0;
end
