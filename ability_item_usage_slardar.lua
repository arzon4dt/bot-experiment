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

local castGSDesire = 0;
local castSCDesire = 0;
local castCHDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityGS = npcBot:GetAbilityByName( "slardar_sprint" );
	abilitySC = npcBot:GetAbilityByName( "slardar_slithereen_crush" );
	abilityCH = npcBot:GetAbilityByName( "slardar_amplify_damage" );

	-- Consider using each ability
	castGSDesire = ConsiderGuardianSprint();
	castSCDesire = ConsiderSlithereenCrush();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	

	if ( castCHDesire > castGSDesire and castCHDesire > castSCDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityCH, castCHTarget );
		return;
	end

	if ( castSCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilitySC );
		return;
	end
	
	if ( castGSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityGS );
		return;
	end

end

function CanCastSlithereenCrushOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastCorrosiveHazeOnTarget( npcTarget )
	return npcTarget:CanBeSeen()  and not npcTarget:IsInvulnerable();
end


function ConsiderGuardianSprint()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityGS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderSlithereenCrush()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilitySC:GetSpecialValueInt( "crush_radius" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetAbilityDamage();

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
			if ( CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nRadius - 100))
			then
				return BOT_ACTION_DESIRE_VERYHIGH;
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

function ConsiderCorrosiveHaze()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityCH:GetCastRange();

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_LANING or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and CanCastCorrosiveHazeOnTarget( npcTarget ) and not npcTarget:HasModifier("modifier_slardar_amplify_damage") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and CanCastCorrosiveHazeOnTarget( npcTarget ) and not npcTarget:HasModifier("modifier_slardar_amplify_damage")  )
			then
				return BOT_ACTION_DESIRE_LOW, npcTarget;
			end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastCorrosiveHazeOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil and not npcMostDangerousEnemy:HasModifier("modifier_slardar_amplify_damage")  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
