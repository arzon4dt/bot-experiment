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

local castDPDesire = 0;
local castPCDesire = 0;
local castSDDesire = 0;
local castPWDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	--print(npcBot:GetAttackRange())
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityDP = npcBot:GetAbilityByName( "templar_assassin_refraction" );
	abilityPC = npcBot:GetAbilityByName( "templar_assassin_meld" );
	abilitySD = npcBot:GetAbilityByName( "templar_assassin_trap" );
	abilityPW = npcBot:GetAbilityByName( "templar_assassin_psionic_trap" );

	-- Consider using each ability
	castDPDesire = ConsiderDarkPact();
	castPCDesire = ConsiderPounce();
	--castSDDesire = ConsiderShadowDance();
	castPWDesire, castPWLocation = ConsiderPlagueWard();
	
	if ( castPWDesire > 0 )
	then
		npcBot:Action_UseAbilityOnLocation( abilityPW, castPWLocation );
		return;
	end
	
	if ( castDPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityDP );
		return;
	end
	
	if ( castPCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPC );
		return;
	end
	
	if ( castSDDesire > 0 ) 
	then
		--npcBot:Action_UseAbility( abilitySD );
		return;
	end

end


function CanCastPlagueWardOnTarget( npcTarget )
return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune()  and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderDarkPact()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityDP:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nRange, 400, 0, 0 );
		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 ) then
			return BOT_ACTION_DESIRE_LOW;
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

		if ( npcTarget ~= nil and npcTarget:IsHero()) 
		then
			if ( GetUnitToUnitDistance( npcBot, npcTarget ) < 2*nRange )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPounce()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityPC:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;
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
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() )
	then
		if ( npcTarget:GetActualIncomingDamage( nTotalDamage, DAMAGE_TYPE_PHYSICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange - 150 ) )
		then
			return BOT_ACTION_DESIRE_HIGH;
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and not enemyDisabled(npcTarget)) 
		then
			if ( GetUnitToUnitDistance( npcBot, npcTarget ) < ( nCastRange - 150 ) )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderShadowDance()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or npcEnemy:IsUsingAbility() ) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.5 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil and npcTarget:IsHero() and #tableNearbyEnemyHeroes >= 2 and GetUnitToUnitDistance( npcBot, npcTarget ) < 200 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderPlagueWard()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPW:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local mandateTrapLoc = {
		Vector(-982, 688),
		Vector(-230, 15),
		Vector(-1750, 1250),
		Vector(2600, -2032),
		Vector(-260, 1788),
		Vector(3180, 250),
		Vector(-2350, 177),
		Vector(980, 2514)
	}
	
	-- Get some of its values
	--local nRadius abilityPW:GetSpecialValueInt( "radius" );

	--^Special Value

	local nCastRange = abilityPW:GetCastRange();
	local nCastPoint = abilityPW:GetCastPoint();

	local creeps = npcBot:GetNearbyCreeps(1000, true)
	local enemyHeroes = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				if ( CanCastPlagueWardOnTarget( npcEnemy ) )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
				end
			end
		end
	end

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		npcBot:GetActiveMode() == BOT_MODE_ROAM or
		npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		npcBot:GetActiveMode() == BOT_MODE_GANK or
		npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	--[[
	for _,loc in pairs(mandateTrapLoc)
	do
		if GetUnitToLocationDistance(npcBot, loc) < nCastRange then
			local exsit = false;
			local listTrap = GetUnitList(UNIT_LIST_ALLIES);
			for _,unit in pairs(listTrap)
			do
				if unit:GetUnitName() ==  "npc_dota_templar_assassin_psionic_trap" then
					local x = unit:GetLocation().x;
					local y = unit:GetLocation().y;
					if Vector(x, y) == loc then
						exist = true;
						break;
					end
				end
			end
			if not exist then
				return BOT_ACTION_DESIRE_LOW, loc;
			end	
		end
	end
	]]--

	return BOT_ACTION_DESIRE_NONE, 0;
end
