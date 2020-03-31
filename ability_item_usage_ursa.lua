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

local castESDesire = 0;
local castOPDesire = 0;
local castERDesire = 0;

local abilityES = nil;
local abilityOP = nil;
local abilityER = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityES == nil then abilityES = npcBot:GetAbilityByName( "ursa_earthshock" ) end
	if abilityOP == nil then abilityOP = npcBot:GetAbilityByName( "ursa_overpower" ) end
	if abilityER == nil then abilityER = npcBot:GetAbilityByName( "ursa_enrage" ) end
	
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

function ConsiderEarthshock()

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
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nRadius, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes > 0 and ( npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) ) ) 
		then
			local loc = mutil.GetEscapeLoc();
			if utils.IsFacingLocation(npcBot,loc,15) then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function ConsiderOverpower()

	-- Make sure it's castable
	if ( not abilityOP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're pushing a lane 
	if mutil.IsPushing(npcBot) and npcBot:GetMana() / npcBot:GetMaxMana() >= 0.65 
	then
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 and tableNearbyEnemyTowers[1] ~= nil and
		   mutil.IsInRange(tableNearbyEnemyTowers[1], npcBot, 300)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_FARM 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderEnrage()

	-- Make sure it's castable
	if ( not abilityER:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_FARM and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.20
	then
		local npcTarget = npcBot:GetAttackTarget();
		if npcTarget ~= nil then
			return BOT_ACTION_DESIRE_LOW;
		end
	end	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.65
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 300) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
