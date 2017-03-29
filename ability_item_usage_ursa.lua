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

local castESDesire = 0;
local castOPDesire = 0;
local castERDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityES = npcBot:GetAbilityByName( "ursa_earthshock" );
	abilityOP = npcBot:GetAbilityByName( "ursa_overpower" );
	abilityER = npcBot:GetAbilityByName( "ursa_enrage" );

		
	--[[if CheckFlag(abilityES:GetBehavior(), ABILITY_BEHAVIOR_AOE ) then
		print("OK")
	else
		print("NO")
	end]]--
	
	-- Consider using each ability
	castESDesire = ConsiderEarthshock();
	castOPDesire = ConsiderOverpower();
	castERDesire = ConsiderEnrage();

	if ( castERDesire > castESDesire and castERDesire > castESDesire ) 
	then
		npcBot:Action_UseAbility( abilityER );
		return;
	end

	if ( castESDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityES );
		return;
	end
	
	if ( castOPDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityOP );
		return;
	end

end

function CanCastEarthshockOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function ConsiderEarthshock()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityES:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityES:GetSpecialValueInt( "shock_radius" );
	local nCastRange = 0;
	local nDamage = abilityES:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastEarthshockOnTarget( npcEnemy ) ) 
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
			if ( CanCastEarthshockOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nRadius - 185))
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- if we're in creep wave and in range of enemy hero
	if ( npcBot:GetActiveMode() ~= BOT_MODE_LANING) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		local npcTarget = tableNearbyEnemyHeroes[1];

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastEarthshockOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nRadius - 185))
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


function ConsiderOverpower()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're pushing a lane 
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
			for _,eTower in pairs(tableNearbyEnemyTowers) do
				if ( GetUnitToUnitDistance( eTower, npcBot  ) < 200 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN or npcBot:GetActiveMode() == BOT_MODE_FARM   ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  )
			then
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 400 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEnrage()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityER:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 400, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  )
			then
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 200 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
