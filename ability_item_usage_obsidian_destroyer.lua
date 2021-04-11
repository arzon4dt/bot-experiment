if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end


local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutil = require(GetScriptDirectory() ..  "/MyUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local castSADesire = 0;
local castDRDesire = 0;
local castEADesire = 0;
local castSSDesire = 0;
local abilitySA = "";
local abilityDR = "";
local abilityEA = "";
local abilitySS = "";
local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilitySA == "" then abilitySA = npcBot:GetAbilityByName( "obsidian_destroyer_arcane_orb" ); end 
	if abilityDR == "" then abilityDR = npcBot:GetAbilityByName( "obsidian_destroyer_astral_imprisonment" ); end 
	if abilityEA == "" then abilityEA = npcBot:GetAbilityByName( "obsidian_destroyer_equilibrium" ); end
	if abilitySS == "" then abilitySS = npcBot:GetAbilityByName( "obsidian_destroyer_sanity_eclipse" ); end
	
	if abilitySA:IsTrained() 
		and abilityEA:GetLevel() >= 3 
		and abilitySA:GetAutoCastState( ) == false 
	then
		abilitySA:ToggleAutoCast();
	end
	
	castSADesire, castSATarget = ConsiderSearingArrows()
	castDRDesire, castDRTarget = ConsiderDisruption();
	-- castEADesire = ConsiderEquilibrium();
	castSSDesire, castSSLocation = ConsiderStaticStorm();
	
	if ( castEADesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityEA );
		return;
	end
	if castSADesire > 0 
	then
		npcBot:Action_UseAbilityOnEntity(abilitySA, castSATarget);
		return;
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


function ConsiderSearingArrows()

	if ( abilitySA:IsFullyCastable() == false or abilitySA:GetAutoCastState( ) == true ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local attackRange = npcBot:GetAttackRange()

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, attackRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderDisruption()

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
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes == 2 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		else
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end
		end
	end
	
	local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
	for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
	do
		if  myFriend:GetUnitName() ~= npcBot:GetUnitName() and mutil.IsRetreating(myFriend) and
			myFriend:WasRecentlyDamagedByAnyHero(2.0) and mutil.CanCastOnNonMagicImmune(myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
	-- Check for a channeling enemy
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) and mutil.CanCastOnNonMagicImmune( npcEnemy ) 
		    and not mutil.IsDisabled(true, npcEnemy) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		if #tableNearbyEnemyHeroes > 1 then
			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;
			local npcTarget = npcBot:GetTarget();
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if npcEnemy ~= npcTarget and mutil.CanCastOnNonMagicImmune( npcEnemy ) and not mutil.IsDisabled(true, npcEnemy) 
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
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, (nCastRange+200)/2) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) and
		    not mutil.IsDisabled(true, npcTarget) 
		then
			local allies = npcTarget:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			if #allies < 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderEquilibrium()

	-- Make sure it's castable
	if ( not abilityEA:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nAttackRange = npcBot:GetAttackRange();

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	


function ConsiderStaticStorm()

	-- Make sure it's castable
	if ( not abilitySS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilitySS:GetSpecialValueInt( "radius" );
	local nCastRange = abilitySS:GetCastRange();
	local nCastPoint = abilitySS:GetCastPoint( );
	local MyIntVal = npcBot:GetMana();
	local nMultiplier = abilitySS:GetSpecialValueFloat( "damage_multiplier" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if (  mutil.IsRetreating(npcBot)  and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 ) 
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyInt = npcEnemy:GetMana();
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and ( nDamage >= ( 0.45 + (0.05*(npcEnemy:GetLevel()/5)) ) * npcEnemy:GetMaxHealth() or  mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL ) ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and npcTarget:GetHealth() > 150 and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  
		then
			local EnemyInt = npcTarget:GetMana();
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and ( nDamage >= ( 0.45 + (0.05*(npcTarget:GetLevel()/5)) ) * npcTarget:GetMaxHealth() or  mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL ) ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end
