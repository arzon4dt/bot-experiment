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

local castOODesire = 0;
local castFBDesire = 0;
local castTDDesire = 0;
local castPNDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	abilityOO = npcBot:GetAbilityByName( "leshrac_split_earth" );
	abilityTD = npcBot:GetAbilityByName( "leshrac_diabolic_edict" );
	abilityFB = npcBot:GetAbilityByName( "leshrac_lightning_storm" );
	abilityPN = npcBot:GetAbilityByName( "leshrac_pulse_nova" );

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTDDesire = ConsiderTimeDilation();
	castPNONDesire = ConsiderPulseNovaOn();
	castPNOFFDesire = ConsiderPulseNovaOff();

	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castTDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityTD );
		return;
	end
	
	if ( castPNONDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPN );
		return;
	end
	
	if ( castPNOFFDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityPN );
		return;
	end
	

end

function CanCastOverWhelmingOddsOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastPulseNovaOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function ConsiderOverwhelmingOdds()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	local nCastPoint = abilityOO:GetCastPoint( ) + abilityOO:GetSpecialValueFloat( "delay" );
	local nDamage = abilityOO:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTargetToKill ) and GetUnitToUnitDistance(npcTargetToKill, npcBot) <= nAttackRange )
	then
		if ( npcTargetToKill:IsHero() and  npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nAttackRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTarget ) and GetUnitToUnitDistance(npcTarget, npcBot) <= nAttackRange  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()

	local npcBot = GetBot();
	--[[if npcBot:GetActiveMode() ~= 0 and npcBot:GetActiveMode() ~= 1 then
		print(npcBot:GetActiveMode());
	end]]--
	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = 0;
	local nDamage = abilityFB:GetAbilityDamage()

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
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
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nCastRange, true );
			for _,npcCreepTarget in pairs(tableNearbyEnemyCreeps) do
				if ( GetUnitToUnitDistance( npcCreepTarget, npcBot  ) < nCastRange + 200 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcCreepTarget;
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderPulseNovaOn()
	local npcBot = GetBot();

	if ( not abilityPN:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if npcBot:HasModifier("modifier_leshrac_pulse_nova") then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityPN:GetSpecialValueInt("radius")
	local nDamage = abilityPN:GetSpecialValueInt("damage")
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastPulseNovaOnTarget( npcEnemy ) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 1 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE;
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
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastPulseNovaOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPulseNovaOff()
	local npcBot = GetBot();

	if ( not abilityPN:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if not npcBot:HasModifier("modifier_leshrac_pulse_nova") then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityPN:GetSpecialValueInt("radius")
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	if (tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0) then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end