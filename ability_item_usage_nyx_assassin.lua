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
local castVDDesire = 0;
local castBRDesire = 0;
local castUBRDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	--[[local m = npcBot:NumModifiers();
	for i = 0, m
	do
		print(npcBot:GetModifierName(i))
	end]]--
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:HasModifier("modifier_nyx_assassin_vendetta") ) then return end

	abilityOO = npcBot:GetAbilityByName( "nyx_assassin_impale" );
	abilityTD = npcBot:GetAbilityByName( "nyx_assassin_spiked_carapace" );
	abilityFB = npcBot:GetAbilityByName( "nyx_assassin_mana_burn" );
	abilityVD = npcBot:GetAbilityByName( "nyx_assassin_vendetta" );
	abilityBR = npcBot:GetAbilityByName( "nyx_assassin_burrow" );
	abilityUBR = npcBot:GetAbilityByName( "nyx_assassin_unburrow" );

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
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nLength, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and GetUnitToUnitDistance(npcEnemy, npcBot) < nLength ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTargetToKill ) )
	then
		local distance = GetUnitToUnitDistance(npcTargetToKill, npcBot);
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and distance < nLength )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTargetToKill:GetExtrapolatedLocation( (distance / nSpeed) + nCastPoint );
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nLength, 2*nRadius, 0, 10000 );
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
		local distance = GetUnitToUnitDistance(npcTarget, npcBot);
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOverWhelmingOddsOnTarget( npcTarget ) and distance < nLength  ) 
		then
			--return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation( );
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (distance / nSpeed) + nCastPoint );
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
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
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
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK  ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsUsingAbility( )  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
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
	local nMultiplier = abilityFB:GetSpecialValueInt("float_multiplier")

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	-- If a mode has set a target, and we can kill them, do it
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() and CanCastFireblastOnTarget( npcTargetToKill ) )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nMultiplier*npcTargetToKill:GetAttributeValue(ATTRIBUTE_INTELLECT), DAMAGE_TYPE_MAGICAL ) > npcTargetToKill:GetHealth() and GetUnitToUnitDistance( npcTargetToKill, npcBot ) < ( nCastRange + 200 ) )
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

	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderVendetta()
	local npcBot = GetBot();

	if ( not abilityVD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nDamage = abilityVD:GetSpecialValueInt("bonus_damage")
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
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
	
	local npcTargetToKill = npcBot:GetTarget();
	if ( npcTargetToKill ~= nil and npcTargetToKill:IsHero() )
	then
		if ( npcTargetToKill:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL ) > npcTargetToKill:GetHealth()  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK  ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance( npcBot, npcTarget ) < 2500 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderBurrow()

local npcBot = GetBot();

if ( not npcBot:HasScepter() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

if ( not abilityBR:IsFullyCastable() and not abilityBR:IsHidden() ) then 
	return BOT_ACTION_DESIRE_NONE;
end

local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
then
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
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