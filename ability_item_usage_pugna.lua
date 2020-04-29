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
local castTSDesire = 0;
local castLDDesire = 0;

local abilityOO = nil;
local abilityFB = nil;
local abilityTS = nil;
local abilityLD = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityOO == nil then abilityOO = npcBot:GetAbilityByName( "pugna_nether_blast" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "pugna_decrepify" ) end
	if abilityTS == nil then abilityTS = npcBot:GetAbilityByName( "pugna_nether_ward" ) end
	if abilityLD == nil then  abilityLD = npcBot:GetAbilityByName( "pugna_life_drain" ) end

	-- Consider using each ability
	castOODesire, castOOLocation = ConsiderOverwhelmingOdds();
	castFBDesire, castFBTarget = ConsiderFireblast();
	castTSDesire, castTSLocation = ConsiderTombStone();
	castLDDesire, castLDTarget = ConsiderLifeDrain();

	if ( castTSDesire > 0  ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityTS, castTSLocation );
		return;
	end
	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	if ( castOODesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityOO, castOOLocation );
		return;
	end
	if ( castLDDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLD, castLDTarget );
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
	local nDelay = abilityOO:GetSpecialValueInt( "delay" );
	local nRadius = abilityOO:GetSpecialValueInt( "radius" );
	local nCastRange = abilityOO:GetCastRange();
	local nCastPoint = abilityOO:GetCastPoint( );
	local nDamage = abilityOO:GetSpecialValueInt("blast_damage");

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
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, nDelay, 0 );
		local tableNearbyTowers = npcBot:GetNearbyTowers( 1000, true);
		local tableNearbyBarracks = npcBot:GetNearbyBarracks( 1000, true);
		if tableNearbyTowers[1] ~= nil then
			return BOT_ACTION_DESIRE_LOW, tableNearbyTowers[1]:GetLocation();
		end
		if tableNearbyBarracks[1] ~= nil then
			return BOT_ACTION_DESIRE_LOW, tableNearbyBarracks[1]:GetLocation();
		end
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay + nCastPoint );
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	local nRadius = 0;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			else
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
			and not mutil.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderTombStone()

	-- Make sure it's castable
	if ( not abilityTS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityTS:GetCastRange();
	local nCastPoint = abilityTS:GetCastPoint();

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsInFront(nCastRange/2);
		end
	end
	

	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLifeDrain()

	-- Make sure it's castable
	if ( not abilityLD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityLD:GetCastRange();
	local nDamage = 500;

	--------------------------------------
	-- Mode based usage
	-------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
				end
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if  mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end