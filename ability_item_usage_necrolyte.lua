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

	abilityGS = npcBot:GetAbilityByName( "necrolyte_sadist" );
	abilitySC = npcBot:GetAbilityByName( "necrolyte_death_pulse" );
	abilityCH = npcBot:GetAbilityByName( "necrolyte_reapers_scythe" );

	-- Consider using each ability
	castGSDesire = ConsiderGuardianSprint();
	castSCDesire = ConsiderSlithereenCrush();
	castCHDesire, castCHTarget = ConsiderCorrosiveHaze();
	

	if ( castCHDesire > 0 ) 
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
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable() and not HasForbiddenModifier(npcTarget) and 
	string.find(npcTarget:GetUnitName(), "hero");
end


function HasForbiddenModifier(npcTarget)
	local modifier = {
		"modifier_winter_wyvern_winters_curse",
		"modifier_modifier_dazzle_shallow_grave",
		"modifier_modifier_oracle_false_promise",
		"modifier_oracle_fates_edict"
	}
	for _,mod in pairs(modifier)
	do
		if npcTarget:HasModifier(mod) then
			return true
		end	
	end
	return false;
end


function ConsiderGuardianSprint()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityGS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityGS:GetSpecialValueInt( "slow_aoe" );
	
	local SadStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_necrolyte_death_pulse_counter" then
			SadStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	
	if SadStack >= 8 and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.65 then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
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
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius - 100 and 
			npcTarget:GetActiveMode() == BOT_MODE_RETREAT and npcTarget:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
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
	local nRadius = abilitySC:GetSpecialValueInt( "area_of_effect" );
	local nCastRange = 0;
	local nDamage = abilitySC:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_FARM ) then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
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
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAlliesHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		local lowHPAllies = 0;
		for _,ally in pairs(tableNearbyAlliesHeroes)
		do
			local allyHealth = ally:GetHealth() / ally:GetMaxHealth();
			if allyHealth < 0.5 then
				lowHPAllies = lowHPAllies + 1;
			end
		end
		
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) or lowHPAllies >= 1 then
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastSlithereenCrushOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
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
	local nDamagaPerHealth = abilityCH:GetSpecialValueFloat("damage_per_health");

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastCorrosiveHazeOnTarget( npcTarget ) )
			then
				local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxHealth() - npcTarget:GetHealth() )
				if npcTarget:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth()
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget;
				end
			end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local npcToKill = nil;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxHealth() - npcEnemy:GetHealth() )
			if ( CanCastCorrosiveHazeOnTarget( npcEnemy ) and 
				npcEnemy:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth() and 
				GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange + 200 ) 
				)
			then
				npcToKill = npcEnemy;
			end
		end

		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxHealth() - npcEnemy:GetHealth() )
		if ( CanCastCorrosiveHazeOnTarget( npcEnemy ) and npcEnemy:IsHero() and
			npcEnemy:GetActualIncomingDamage( EstDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth() and 
			GetUnitToUnitDistance( npcEnemy, npcBot ) < ( nCastRange + 200 ) 
			)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end
