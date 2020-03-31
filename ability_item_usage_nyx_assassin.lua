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
local castVDDesire = 0;
local castBRDesire = 0;
local castUBRDesire = 0;

local abilityOO = nil;
local abilityTD = nil;
local abilityFB = nil;
local abilityVD = nil;
local abilityBR = nil;
local abilityUBR = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if ( mutil.CanNotUseAbility(npcBot) or npcBot:HasModifier("modifier_nyx_assassin_vendetta") ) then return end

	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "nyx_assassin_impale" ) end
	if abilityTD == nil then abilityTD = npcBot:GetAbilityByName( "nyx_assassin_spiked_carapace" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "nyx_assassin_mana_burn" ) end
	if abilityVD == nil then abilityVD = npcBot:GetAbilityByName( "nyx_assassin_vendetta" ) end
	if abilityBR == nil then abilityBR = npcBot:GetAbilityByName( "nyx_assassin_burrow" ) end
	if abilityUBR == nil then abilityUBR = npcBot:GetAbilityByName( "nyx_assassin_unburrow" ) end

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTDDesire = ConsiderTimeDilation();
	castVDDesire = ConsiderVendetta();
	castBRDesire = ConsiderBurrow();
	castUBRDesire = ConsiderUnBorrow();

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
	
	if ( castVDDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityVD );
		return;
	end
	
	if ( castBRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityBR );
		return;
	end
	
	if ( castUBRDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityUBR );
		return;
	end
	
end

function ConsiderOverwhelmingOdds()

	-- Make sure it's castable
	if ( not abilityOO:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nLength = abilityOO:GetSpecialValueInt( "length" );
	local nRadius = abilityOO:GetSpecialValueInt( "width" );
	local nSpeed = abilityOO:GetSpecialValueInt( "speed" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint( );
	local nDamage = abilityOO:GetAbilityDamage();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nLength, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and  mutil.IsInRange(npcTarget, npcBot, nLength) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nLength)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nLength, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nLength - 200) 
		then
		    local distance = GetUnitToUnitDistance(npcTarget, npcBot);
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (distance / nSpeed) + nCastPoint );
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
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
		for _,enemy in pairs (tableNearbyEnemyHeroes)
		do
			local enemyTarget = enemy:GetTarget()
			if enemy:IsUsingAbility() or enemyTarget == npcBot then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(npcBot) 
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600) and npcTarget:IsUsingAbility( )  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
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
	local nMultiplier = abilityFB:GetSpecialValueInt("float_multiplier")

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)  and
	   mutil.CanKillTarget( npcTarget, nMultiplier*npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT), DAMAGE_TYPE_MAGICAL )
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )  and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVendetta()

	if ( not abilityVD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nDamage = abilityVD:GetSpecialValueInt("bonus_damage")
	
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
	
	local npcTarget = npcBot:GetTarget();
	if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 400) and
	   mutil.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_PHYSICAL)	
	then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot,2000)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderBurrow()

if ( not npcBot:HasScepter() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

if ( not abilityBR:IsFullyCastable() and not abilityBR:IsHidden() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

if mutil.IsInTeamFight(npcBot, 1200)
then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
end

return BOT_ACTION_DESIRE_NONE;

end


function ConsiderUnBorrow()

local npcBot = GetBot();

if ( not npcBot:HasScepter() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

if ( not npcBot:HasModifier("modifier_nyx_assassin_burrow") ) then 
	return BOT_ACTION_DESIRE_NONE;
end

if ( not abilityUBR:IsFullyCastable() and not abilityUBR:IsHidden() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
if tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 
then
	return BOT_ACTION_DESIRE_MODERATE;
end

return BOT_ACTION_DESIRE_NONE;

end