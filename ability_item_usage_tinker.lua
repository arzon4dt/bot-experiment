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
local castFBDesire = 0;
local castSCDesire = 0;
local castTSDesire = 0;
local castRADesire = 0;
local castSoulRingDesire = 0;
local castBoTDesire = 0;
local timeCast = 0;
local channleTime = 3;
function AbilityUsageThink()
	
	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:HasModifier("modifier_tinker_rearm")  ) then return end

	abilityFB = npcBot:GetAbilityByName( "tinker_laser" );
	abilitySC = npcBot:GetAbilityByName( "tinker_heat_seeking_missile" );
	abilityTS = npcBot:GetAbilityByName( "tinker_march_of_the_machines" );
	abilityRA = npcBot:GetAbilityByName( "tinker_rearm" );
	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castSCDesire = ConsiderSlithereenCrush();
	castTSDesire, castTSLocation = ConsiderTombStone();
	castRADesire = ConsiderRearm();
	castSoulRingDesire, itemSR = ConsiderSoulRing() 
	castBoTDesire, itemBoT, castBoTLocation = ConsiderBoT() 
	
	channleTime = abilityRA:GetSpecialValueFloat("channel_tooltip");
	
	if castSoulRingDesire > 0 then
		npcBot:Action_UseAbility( itemSR );
		return
	end
	
	if castBoTDesire > 0 then
		npcBot:Action_UseAbilityOnLocation( itemBoT, castBoTLocation );
		return
	end
	
	if ( castTSDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTS, castTSLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
	if ( castRADesire > 0 and DotaTime() > timeCast + channleTime ) 
	then
		npcBot:Action_ClearActions(true);
		npcBot:ActionPush_UseAbility( abilityRA );
		timeCast = DotaTime();
		return;
	end
end

function IsItemAvailable(item_name)
	local npcBot = GetBot();
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

function TravelOffCD()
	local npcBot = GetBot();
	local bot1=IsItemAvailable("item_travel_boots");
	local bot2=IsItemAvailable("item_travel_boots_2");
	if bot1~=nil then
		return bot1:IsFullyCastable();
	end
	if bot2~=nil then
		return bot2:IsFullyCastable();
	end
	return true;
end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderSoulRing()
	
	local npcBot = GetBot();
	
	local sr=IsItemAvailable("item_soul_ring")
	
	if sr == nil then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	if not sr:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
    if npcBot:GetHealth() > 2 * 150 and currManaRatio < 0.90 and castRADesire > 0
	then
		return BOT_ACTION_DESIRE_HIGH, sr;
	end
	
	return BOT_ACTION_DESIRE_NONE, {};
end


function ConsiderBoT()
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	
	local npcBot = GetBot();
	
	local bot=IsItemAvailable("item_travel_boots")
	
	if bot == nil then
		return BOT_ACTION_DESIRE_NONE, {}, {};
	end
	
	if not bot:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, {}, {};
	end
	
	local currManaRatio = npcBot:GetMana() / npcBot:GetMaxMana();
    if npcBot:GetMana() < abilityRA:GetManaCost() and npcBot:DistanceFromFountain() > 0
	then
		if GetTeam( ) == TEAM_DIRE then
			return BOT_ACTION_DESIRE_HIGH, bot, DB;
		end
		if GetTeam( ) == TEAM_RADIANT then
			return BOT_ACTION_DESIRE_HIGH, bot, RB;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, {}, {};
end


function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nDamage = abilityFB:GetSpecialValueInt("laser_damage");
	local currManaP = npcBot:GetMana() / npcBot:GetMaxMana();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if npcBot:GetActiveMode() == BOT_MODE_LANING then
		local laneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		for _,creep in pairs(laneCreeps)
		do
			if creep:GetHealth() <= nDamage and currManaP > 0.45  then
				return BOT_ACTION_DESIRE_LOW, creep;
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ))
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PURE ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTargetToKill;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastFireblastOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
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
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderSlithereenCrush()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "radius" );
	local nDamage = abilitySC:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastSlithereenCrushOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
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

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- if we're in creep wave and in range of enemy hero
	if ( npcBot:GetActiveMode() ~= BOT_MODE_LANING) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		local npcTarget = tableNearbyEnemyHeroes[1];

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nRadius - 100))
			then
				local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 0, nRadius, 0.0, 100000 );
				if ( locationAoE.count >= 3 ) then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderTombStone()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if castFBDesire > 0 or castSCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nCastPoint = abilityTS:GetCastPoint();
	local nRadius = abilityTS:GetSpecialValueInt("radius");

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
         npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );

		if ( locationAoE.count >= 3 and (npcBot:GetMana() / npcBot:GetMaxMana()) > 0.45 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderRearm()
	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( npcBot:HasModifier("modifier_tinker_rearm") or not abilityRA:IsFullyCastable() or abilityRA:IsInAbilityPhase() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if castFBDesire > 0 or castSCDesire > 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nManaCost = abilityRA:GetManaCost()
	local botMana = npcBot:GetMana();
	
	if npcBot:DistanceFromFountain() == 0 and not TravelOffCD() then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( botMana >= nManaCost and npcTarget ~= nil and not abilityFB:IsCooldownReady() and not abilitySC:IsCooldownReady() and GetUnitToUnitDistance( npcBot, npcTarget ) < 1000  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if ( botMana >= nManaCost and not abilityTS:IsCooldownReady()  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE
end