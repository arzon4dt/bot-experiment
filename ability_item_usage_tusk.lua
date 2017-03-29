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

local castISDesire = 0;
local castFSDesire = 0;
local castSBDesire = 0;
local castWPDesire = 0;
local castWKDesire = 0;
local castSBLDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityIS = npcBot:GetAbilityByName( "tusk_ice_shards" );
	abilityFS = npcBot:GetAbilityByName( "tusk_frozen_sigil" );
	abilitySB = npcBot:GetAbilityByName( "tusk_snowball" );
	abilitySBL = npcBot:GetAbilityByName( "tusk_launch_snowball" );
	abilityWP = npcBot:GetAbilityByName( "tusk_walrus_punch" );
	abilityWK = npcBot:GetAbilityByName( "tusk_walrus_kick" );

	-- Consider using each ability
	castSBDesire, castSBTarget = ConsiderSnowBall();
	castSBLDesire = ConsiderSnowBallLaunch();
	castWPDesire, castWPTarget = ConsiderWalrusPunch();
	castWKDesire, castWKTarget = ConsiderWalrusKick();
	castISDesire, castISLocation = ConsiderIceShards();
	castFSDesire = ConsiderFrozenSigil();
	
	if ( castSBLDesire > 0 ) 
	then
		npcBot:Action_ClearActions(false);
		npcBot:Action_UseAbility( abilitySBL );
		return;
	end
	
	if ( castISDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityIS, castISLocation );
		return;
	end
	
	if ( castSBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilitySB, castSBTarget );
		return;
	end
	
	if ( castWPDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityWP, castWPTarget );
		return;
	end
	
	if ( castFSDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityFS );
		return;
	end
	
	if ( castWKDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityWK, castWKTarget );
		return;
	end

end

function CanCastIceShardsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end


function CanCastSnowBallOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function CanCastWalrusPunchOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function ConsiderIceShards()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityIS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
--
	-- If we want to cast Laguna Blade at all, bail
	--[[if ( castSBDesire > 0 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end]]--

	-- Get some of its values
	local nRadius = abilityIS:GetSpecialValueInt( "shard_width" );
	local nCastRange = 1200;
	local nCastPoint = abilityIS:GetCastPoint( );
	local nDamage = abilityIS:GetSpecialValueInt("shard_damage");
	local nSpeed = abilityIS:GetSpecialValueInt("shard_speed");

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				--return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetXUnitsInFront(20);
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcEnemy, npcBot)/nSpeed) + nCastPoint );
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastIceShardsOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange ) )
		then
			--[[if npcTargetToKill:IsFacingUnit( npcBot, 45 ) then
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetLocation();
			else
				return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetXUnitsInFront(400);
			end]]--
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTargetToKill, npcBot)/nSpeed) + nCastPoint );
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, nDamage );

		if ( locationAoE.count >= 3 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) then
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
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.6 ) 
		then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange ) 
		then
			if ( CanCastIceShardsOnTarget( npcTarget ) )
			then
				--[[if npcTarget:IsFacingUnit( npcBot, 45 ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				else
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetXUnitsInFront(400);
				end]]--
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot)/nSpeed) + nCastPoint );
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSnowBall()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilitySB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 1200;
	local nDamage = abilitySB:GetSpecialValueInt( "snowball_damage" );
	
	-- If enemy is channeling cancel it
	local npcTarget = npcBot:GetTarget();
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	-- If a mode has set a target, and we can kill them, do it
	--local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastSnowBallOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				if ( CanCastSnowBallOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastSnowBallOnTarget( npcEnemy ) )
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
			if ( CanCastSnowBallOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderFrozenSigil()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFS:IsFullyCastable() ) 
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
	-- Mode based usage
	--------------------------------------
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
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


function ConsiderWalrusPunch()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityWP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityWP:GetCastRange();
	local nDamage = abilityWP:GetManaCost() * 3.5;
	
	-- If enemy is channeling cancel it
	local npcTarget = npcBot:GetTarget();
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	-- If a mode has set a target, and we can kill them, do it
	--local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastSnowBallOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				if ( CanCastWalrusPunchOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastWalrusPunchOnTarget( npcEnemy ) )
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 ) 
		then
			if ( CanCastWalrusPunchOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderWalrusKick()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not npcBot:HasScepter() or not abilityWK:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityWP:GetCastRange();
	local nDamage = 350;
	
	-- If enemy is channeling cancel it
	local npcTarget = npcBot:GetTarget();
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	-- If a mode has set a target, and we can kill them, do it
	--local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and CanCastSnowBallOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < ( nCastRange + 200 ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				if ( CanCastWalrusPunchOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastWalrusPunchOnTarget( npcEnemy ) )
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange + 200 ) 
		then
			if ( CanCastWalrusPunchOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderSnowBallLaunch()

	local npcBot = GetBot();
	
	if ( abilitySBL:IsHidden() ) then 
		return BOT_ACTION_DESIRE_NONE;
	else
		--print("Not Hidden")
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end