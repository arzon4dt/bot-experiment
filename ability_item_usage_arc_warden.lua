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

local castWADesire = 0;
local castMFDesire = 0;
local castWBDesire = 0;
local castPRDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityWA = npcBot:GetAbilityByName( "arc_warden_spark_wraith" );
	abilityMF = npcBot:GetAbilityByName( "arc_warden_magnetic_field" );
	abilityWB = npcBot:GetAbilityByName( "arc_warden_tempest_double" );
	abilityPR = npcBot:GetAbilityByName( "arc_warden_flux" );

	-- Consider using each ability
	castPRDesire, castPRTarget = ConsiderFlux();
	castWADesire, castWALocation = ConsiderSparkWraith();
	castMFDesire, castMFLocation = ConsiderMagneticField();
	castWBDesire = ConsiderTempestDouble();

	if ( castPRDesire > castWADesire ) 
	then
		--print("Use WA");
		npcBot:Action_UseAbilityOnEntity( abilityPR, castPRTarget );
		return;
	end

	if ( castWADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityWA, castWALocation );
		return;
	end
	
	if ( castMFDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityMF, castMFLocation );
		return;
	end
	
	if ( castWBDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityWB );
		return;
	end

end

function CanCastSparkWraithOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastFluxOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end

function ConsiderSparkWraith()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityWA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityWA:GetSpecialValueInt( "radius" );
	local nCastRange = abilityWA:GetCastRange();
	local nDamage = abilityWA:GetSpecialValueInt("spark_damage");
	local nDelay = abilityWA:GetSpecialValueInt("activation_delay");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If mana is full and we're laning just hit hero
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		npcBot:GetMana() == npcBot:GetMaxMana() ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			--return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, tableNearbyEnemyHeroes[1]:GetExtrapolatedLocation( nDelay );
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastSparkWraithOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange ) )
		then
			--return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetLocation();
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nDelay );
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1000, nRadius, 0, nDamage );

		if ( locationAoE.count >= 3 ) then
		--print("WA Farm");
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 0 );

		if ( locationAoE.count >= 1 ) then
		--print("WA Farm");
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			if ( CanCastSparkWraithOnTarget( npcTarget ) )
			then
				--return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderMagneticField()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityMF:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castPRDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityMF:GetSpecialValueInt( "radius" );
	local nCastRange = abilityMF:GetCastRange();

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
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end

	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and not npcTarget:HasModifier("modifier_arc_warden_magnetic_field") ) then
		--print("WA Farm");
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 600, true );
		if ( #tableNearbyEnemyCreeps >= 3 or #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if ( GetUnitToUnitDistance(npcAlly, npcTarget) < nCastRange and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field")  ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation();
				end
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFlux()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityPR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityPR:GetCastRange();
	local nDot = abilityPR:GetSpecialValueInt( "damage_per_second" );
	local nDuration = abilityPR:GetSpecialValueInt( "duration" );
	local nDamage = nDot * nDuration;
	
	-- If a mode has set a target, and we can kill them, do it
	--local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastFluxOnTarget( npcTarget )  )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastFluxOnTarget( npcEnemy ) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
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

		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			if ( CanCastFluxOnTarget( npcTarget ) and not enemyDisabled(npcTarget) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end



function ConsiderTempestDouble()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityWB:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil  )
			then
				return BOT_ACTION_DESIRE_LOW;
			end
	end
	
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 600, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 600, true );
		if ( #tableNearbyEnemyCreeps >= 3 or #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------


	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 600 ) 
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcTarget, npcBot ) < 600 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

-- attempt to disable buybacks for clones to prevent a clone buying in alone
if DotaTime() < 0 then
	
	--print("I would still like buy in permission plz")
	return
end

function  BuybackUsageThink()
	--print("Clones shouldn't cheat")
end
