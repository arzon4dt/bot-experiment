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

local castOODesire = 0;
local castFBDesire = 0;
local castTDDesire = 0;
local castPNDesire = 0;

local abilityOO = nil;
local abilityTD = nil;
local abilityFB = nil;
local abilityPN = nil;

local npcBot = nil;

local splitEarthLoc = nil;
local skUse = false;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "leshrac_split_earth" ) end
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "leshrac_diabolic_edict" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "leshrac_lightning_storm" ) end
	if abilityPN == nil then abilityPN = npcBot:GetAbilityByName( "leshrac_pulse_nova" ) end
		
	local radius = abilityOO:GetSpecialValueInt( "radius" );

	if abilityOO:IsInAbilityPhase() and not IsThereHeroWithinRadius(splitEarthLoc, radius) 
	   and not skUse and npcBot:GetActiveMode() ~= BOT_MODE_ROSHAN 
	then
		npcBot:Action_ClearActions(true);
		return
	end 	
		
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTDDesire = ConsiderTimeDilation();
	castPNONDesire = ConsiderPulseNovaOn();
	castPNOFFDesire = ConsiderPulseNovaOff();

	if ( castOODesire > 0 ) 
	then	
		splitEarthLoc = castOOLocation;
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

function IsThereHeroWithinRadius(vLoc, nRadius)
	local units = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _,u in pairs(units) do
		if GetUnitToLocationDistance(u, vLoc) < nRadius then
			return true;
		end
	end
	return false;
end

function ConsiderOverwhelmingOdds()

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
	
	local skThere, skLoc = mutil.IsSandKingThere(npcBot, nCastRange+200, 2.0);
	
	if skThere then
		skUse = true;
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			then
				skUse = false;
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			skUse = false;
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nAttackRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			skUse = false;
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nAttackRange+200)
		then
			skUse = false;
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()

	-- Make sure it's castable
	if ( not abilityTD:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityTD:GetSpecialValueInt("radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if  mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( nRadius, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.65 ) or
		   ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderFireblast()

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
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana()/npcBot:GetMaxMana() > 0.65 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 and tableNearbyEnemyCreeps[1] ~= nil 
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyCreeps[1];
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderPulseNovaOn()


	if ( not abilityPN:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if npcBot:HasModifier("modifier_leshrac_pulse_nova") then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityPN:GetSpecialValueInt("radius")
	local nDamage = abilityPN:GetSpecialValueInt("damage")
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy)  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPulseNovaOff()
	
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