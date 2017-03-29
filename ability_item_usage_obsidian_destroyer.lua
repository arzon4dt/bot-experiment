local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local castSADesire = 0;
local castDRDesire = 0;
local castSSDesire = 0;
local abilitySA = "";
local abilityDR = "";
local abilityEA = "";
local abilitySS = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end

	if abilitySA == "" then abilitySA = npcBot:GetAbilityByName( "obsidian_destroyer_arcane_orb" ); end 
	if abilityDR == "" then abilityDR = npcBot:GetAbilityByName( "obsidian_destroyer_astral_imprisonment" ); end 
	if abilityEA == "" then abilityEA = npcBot:GetAbilityByName( "obsidian_destroyer_essence_aura" ); end
	if abilitySS == "" then abilitySS = npcBot:GetAbilityByName( "obsidian_destroyer_sanity_eclipse" ); end
	
	if abilitySA:IsTrained() and abilityEA:GetLevel() >= 3 and not abilitySA:GetAutoCastState( )  then
		abilitySA:ToggleAutoCast();
	end
	
	castSADesire, castSATarget = ConsiderSearingArrows()
	castDRDesire, castDRTarget = ConsiderDisruption();
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	
	if castSADesire > 0 
	then
		npcBot:Action_UseAbilityOnEntity(abilitySA, castSATarget);
	end
	if ( castDRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityDR, castDRTarget );
		return;
	end
	if ( castSSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilitySS, castSSLocation );
		return;
	end

	
end

function CanCastSearingArrowOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastDisruptionOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastStaticStormOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function enemyDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) then
		return true;
	end
	return false;
end


function ConsiderSearingArrows()

	local npcBot = GetBot();
	
	if ( not abilitySA:IsFullyCastable() or abilitySA:GetAutoCastState( ) ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local attackRange = npcBot:GetAttackRange()

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastSearingArrowOnTarget( npcTarget ) and GetUnitToUnitDistance(npcTarget, npcBot) <= attackRange ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderDisruption()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityDR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityDR:GetCastRange();
	local nDamage = abilityDR:GetSpecialValueInt("damage");
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and CanCastDisruptionOnTarget ( npcEnemy ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
		if myFriend:GetUnitName() ~= npcBot:GetUnitName() and myFriend:GetActiveMode() == BOT_MODE_RETREAT and myFriend:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and CanCastDisruptionOnTarget( myFriend )
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcEnemy:GetHealth() or npcEnemy:IsChanneling() ) and CanCastDisruptionOnTarget( npcEnemy ) and not enemyDisabled( npcEnemy ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( CanCastDisruptionOnTarget( npcEnemy ) and #tableNearbyEnemyHeroes >= 2 )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil and not enemyDisabled( npcMostDangerousEnemy )  )
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
		if ( npcTarget ~= nil and npcTarget:IsHero() ) 
		then
			if ( CanCastDisruptionOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 and not enemyDisabled( npcTarget ))
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderStaticStorm()

	local npcBot = GetBot();
	
	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local MyIntVal = npcBot:GetAttributeValue(ATTRIBUTE_INTELLECT); 
	local nMultiplier = abilitySS:GetSpecialValueInt( "damage_multiplier" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 3 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyInt = npcEnemy:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and npcEnemy:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcEnemy:GetHealth() and npcEnemy:IsHero() ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
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

		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and CanCastStaticStormOnTarget( npcTarget ) ) 
		then
			local EnemyInt = npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and npcTarget:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > npcTarget:GetHealth() and npcTarget:IsHero() ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end
