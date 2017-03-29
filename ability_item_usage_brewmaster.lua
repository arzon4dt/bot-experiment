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

local castPSDesire = 0;
local castTCDesire = 0;
local castDHDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityTC = npcBot:GetAbilityByName( "brewmaster_thunder_clap" );
	abilityDH = npcBot:GetAbilityByName( "brewmaster_drunken_haze" );
	abilityPS = npcBot:GetAbilityByName( "brewmaster_primal_split" );
	
	-- Consider using each ability
	castTCDesire = ConsiderThunderClap();
	castDHDesire, castDHTarget = ConsiderDrunkenHaze();
	castPSDesire = ConsiderPrimalSplit();

	if ( castDHDesire > castPSDesire and castDHDesire > castTCDesire ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDH, castDHTarget );
		return;
	end
		
	if ( castTCDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTC );
		return;
	end
	if ( castPSDesire > 0  ) 
	then
		npcBot:Action_UseAbility( abilityPS );
		return;
	end

end

function CanCastThunderClapOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastDrunkenHazeOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune()  and not npcTarget:IsInvulnerable();
end

function ConsiderThunderClap()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityTC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityTC:GetSpecialValueInt( "radius" );
	local nCastRange = 0;
	local nDamage = abilityTC:GetSpecialValueInt("damage");

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
				if ( CanCastThunderClapOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 0, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcBot, locationAoE.targetloc ) < nRadius - 150 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
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

		if ( npcTarget ~= nil ) 
		then
			if ( CanCastThunderClapOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < (nRadius - 50))
			then
				return BOT_ACTION_DESIRE_VERYHIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderPrimalSplit()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	if #tableNearbyAllyHeroes == 0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local distance = 300;
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*distance, true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 3*distance, false, BOT_MODE_NONE );
		if #tableNearbyEnemyHeroes >= 2 and #tableNearbyAllyHeroes >= 2 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < distance ) 
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and #tableNearbyEnemyHeroes >= 2 and GetUnitToUnitDistance( npcTarget, npcBot ) < distance ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDrunkenHaze()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDH:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDH:GetCastRange();

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_LANING or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and CanCastDrunkenHazeOnTarget( npcTarget ) and not npcTarget:HasModifier("modifier_brewmaster_drunken_haze") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and CanCastDrunkenHazeOnTarget( npcTarget ) and not npcTarget:HasModifier("modifier_brewmaster_drunken_haze")  )
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
			if ( CanCastDrunkenHazeOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil and not npcMostDangerousEnemy:HasModifier("modifier_brewmaster_drunken_haze")  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
