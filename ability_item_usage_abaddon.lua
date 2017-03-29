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
local castACDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() ) then return end

	abilityDC = npcBot:GetAbilityByName( "abaddon_death_coil" );
	abilityAC = npcBot:GetAbilityByName( "abaddon_aphotic_shield" );

	-- Consider using each ability
	castACDesire, castACTarget = ConsiderAphoticShield();
	castDCDesire, castDCTarget = ConsiderDeathCoil();

	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end

	if ( castDCDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDC, castDCTarget );
		return;
	end
	
	

end


function CanCastDeathCoilOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastAphoticShieldOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function isDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced( )  then
		return true;
	end
	return false;
end

function ConsiderDeathCoil()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDC:GetCastRange();
	local nDamage = abilityDC:GetSpecialValueInt("target_damage");
	local nSelfDamage = abilityDC:GetSpecialValueInt("self_damage");
	
	-- If we're seriously retreating, see if we can suicide
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCastDeathCoilOnTarget( npcEnemy ) and npcBot:GetHealth() <= nSelfDamage ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end
	
	if npcBot:HasModifier("modifier_abaddon_borrowed_time") then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and CanCastDeathCoilOnTarget( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_LOW, npcEnemy
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastDeathCoilOnTarget( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	-- If we're in a teamfight, use it on the protect ally
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( npcAlly:GetUnitName() ~= npcBot:GetUnitName() and CanCastDeathCoilOnTarget( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.5 ) or isDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
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
			if ( CanCastDeathCoilOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderAphoticShield()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityAC:GetCastRange();

	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local lowHpAlly = nil;
		local nLowestHealth = 1000;

		local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
		for _,npcAlly in pairs( tableNearbyAllies )
		do
			if ( CanCastAphoticShieldOnTarget( npcAlly ) )
			then
				local nAllyHP = npcAlly:GetHealth();
				if ( ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) or isDisabled(npcAlly) )
				then
					nLowestHealth = nAllyHP;
					lowHpAlly = npcAlly;
				end
			end
		end

		if ( lowHpAlly ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
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
			local closestAlly = nil;
			local nDist = 10000;

			local tableNearbyAllies = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE  );
			for _,npcAlly in pairs( tableNearbyAllies )
			do
				if ( CanCastAphoticShieldOnTarget( npcAlly ) )
				then
					local nAllyDist = GetUnitToUnitDistance(npcTarget, npcAlly);
					if ( ( nAllyDist < nDist ) or isDisabled(npcAlly) )
					then
						nDist = nAllyDist;
						closestAlly = npcAlly;
					end
				end
			end

			if ( closestAlly ~= nil )
			then
				return BOT_ACTION_DESIRE_MODERATE, closestAlly;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

