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

local npcBot = GetBot();

local abilityQ = nil;
local abilityW = nil;
local abilityE = nil;
local abilityD = nil;
local abilityR = nil;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castDDesire = 0;
local castRDesire = 0;

local remnantLoc = Vector(0, 0, 0);
local remnantCastTime = -100;
local remnantCastGap  = 0.2;

function AbilityUsageThink()
	
	if npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "void_spirit_resonant_pulse" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "void_spirit_aether_remnant" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "void_spirit_dissimilate" ) end
	--if abilityD == nil then abilityD = npcBot:GetAbilityByName( "ember_spirit_activate_fire_remnant" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "void_spirit_astral_step" ) end

	castQDesire              = ConsiderQ();
	castWDesire, castWLoc    = ConsiderW();
	castEDesire              = ConsiderE();
	--castDDesire, castDLoc    = ConsiderD();
	castRDesire, castRLoc    = ConsiderR();

	
	if ( castRDesire > 0 ) 
	then
		remnantCastTime = DotaTime();
		npcBot:Action_UseAbilityOnLocation( abilityR, castRLoc );
		return;
	end
	
	if ( castDDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityD, castDLoc );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityQ );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityW, castWLoc );
		return;
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityE );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius   = abilityQ:GetSpecialValueInt( "radius" );
	local nDamage   = abilityQ:GetSpecialValueInt( "damage" );
	local nManaCost = abilityQ:GetManaCost( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and ( npcEnemy:IsChanneling() or mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) ) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
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
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 50)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetSpecialValueInt('radius');
	local nCastRange = abilityW:GetCastRange()-200;
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	local nDamage    = abilityW:GetSpecialValueInt( 'impact_damage');
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + nRadius/2, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PHYSICAL) then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
			end
		end
	end
	
	if ( mutil.IsPushing(npcBot) or mutil.IsDefending(npcBot) ) and mutil.AllowedToSpam(npcBot, nManaCost)
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation()
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius   = abilityE:GetSpecialValueInt( "first_ring_distance_offset" );
	local nDamage   = abilityE:GetAbilityDamage();
	local nManaCost = abilityE:GetManaCost( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius+200, true, BOT_MODE_NONE );
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
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius+200, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
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

function ConsiderD()
	-- Make sure it's castable
	if ( not abilityD:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local units = GetUnitList(UNIT_LIST_ALLIED_OTHER);
	
	if mutil.IsRetreating(npcBot) or mutil.IsGoingOnSomeone(npcBot) then
		for _,u in pairs(units) do
			if u ~= nil and u:GetUnitName() == "npc_dota_ember_spirit_remnant" and GetUnitToLocationDistance(u, remnantLoc) < 250 then
				return BOT_ACTION_DESIRE_MODERATE, u:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, {};
end

function ConsiderR()
	
	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() or npcBot:IsRooted() or DotaTime() <= remnantCastTime + remnantCastGap ) then 
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	
	-- Get some of its values
	local nRadius      = abilityR:GetSpecialValueInt( "radius" );
	local nCastRange   = abilityR:GetSpecialValueInt("max_travel_distance")-200;
	local nCastPoint   = abilityR:GetCastPoint();
	local nDamage      = abilityR:GetSpecialValueInt( "pop_damage" );
	local nSpeed       = 3000;
	local nManaCost    = abilityR:GetManaCost( );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if mutil.CanCastOnMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			if npcEnemy:GetMovementDirectionStability() < 1.0 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			else
				local eta = ( GetUnitToUnitDistance(npcEnemy, npcBot) / nSpeed ) + nCastPoint;
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(eta);	
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) )
			then
				local loc = mutil.GetEscapeLoc();
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetXUnitsTowardsLocation( loc, nCastRange-(#tableNearbyEnemyHeroes*100) );
			end
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 350) and mutil.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			local targetAlly  = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local targetEnemy = npcTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if targetEnemy ~= nil and targetAlly ~= nil and #targetEnemy >= #targetAlly then
				if npcTarget:GetMovementDirectionStability() < 1.0 then
					return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
				else
					local eta = ( GetUnitToUnitDistance(npcTarget, npcBot) / nSpeed ) + nCastPoint;
					return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(eta);	
				end
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, {};
end