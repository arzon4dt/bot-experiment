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
local abilityR = nil;

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "dazzle_poison_touch" ) end
	if abilityW == nil then abilityW = npcBot:GetAbilityByName( "dazzle_shallow_grave" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "dazzle_shadow_wave" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "dazzle_bad_juju" ) end
	
	castQDesire, castQTarget = ConsiderQ();
	castWDesire, castWTarget = ConsiderW();
	castEDesire, castETarget = ConsiderE();
	-- castRDesire, castRLoc    = ConsiderR();

	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityR, castRLoc );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
		return;
	end
	
	if ( castWDesire > 0 ) 
	then
		local typeAOE = mutil.CheckFlag(abilityW:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			npcBot:Action_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() );
		else
			npcBot:Action_UseAbilityOnEntity( abilityW, castWTarget );
		end
		return;
	end
	
	if ( castEDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityE, castETarget );
		return;
	end
	
end

function ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.35
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot;
	end
	
	local tableNearbyAllyHeroes  = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcAlly) and npcAlly:WasRecentlyDamagedByAnyHero(2.0) and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.15
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityE:GetCastRange();
	local nCastPoint = abilityE:GetCastPoint( );
	local nManaCost  = abilityE:GetManaCost( );
	local nMaxTarget = abilityE:GetSpecialValueInt( 'max_targets' );
	local nDmgRadius = abilityE:GetSpecialValueInt( 'damage_radius' );
	
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, false, BOT_MODE_NONE );
	for _,npcAlly in pairs( tableNearbyAllyHeroes )
	do
		local AllyHealth =  npcAlly:GetHealth() / npcAlly:GetMaxHealth();
		if  mutil.CanCastOnMagicImmune(npcAlly) and 
			(( npcAlly:WasRecentlyDamagedByAnyHero(2.0) and AllyHealth < 0.75 ) or AllyHealth < 0.25 or mutil.IsDisabled(true, npcAlly) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.5
	then
		return BOT_ACTION_DESIRE_HIGH, npcBot;
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if mutil.CanCastOnMagicImmune(npcEnemy) then
			local nearbyCreeps = npcEnemy:GetNearbyLaneCreeps(2*nDmgRadius, true);
			local nearbyHeroes = npcEnemy:GetNearbyHeroes(2*nDmgRadius, true, BOT_MODE_NONE);
			local numCreep = 0;
			local numHeroes = 0;
			if nearbyCreeps == nil then numCreep = 0 else numCreep = #nearbyCreeps end;
			if nearbyHeroes == nil then numHeroes = 0 else numHeroes = #nearbyHeroes end;
			if numCreep + numHeroes >= nMaxTarget and nearbyCreeps[1] ~= nil and mutil.CanCastOnMagicImmune(nearbyCreeps[1]) then
				return BOT_ACTION_DESIRE_HIGH, nearbyCreeps[1];
			end
			if numCreep + numHeroes >= nMaxTarget and nearbyHeroes[1] ~= nil and mutil.CanCastOnMagicImmune(nearbyHeroes[1]) then
				return BOT_ACTION_DESIRE_HIGH, nearbyHeroes[1];
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityR:GetSpecialValueInt('radius');
	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );

	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( mutil.IsRoshan(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if #tableNearbyAllyHeroes >= 3 then
				return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
			end
		end
	end
	
	if mutil.IsPushing(npcBot) 
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1200, false);
		local towers     = npcBot:GetNearbyTowers(1200, true);
		local barracks     = npcBot:GetNearbyBarracks(1200, true);
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4 and ( towers[1] ~= nil or barracks[1] ~= nil  ) ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local locationAoEE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoEE.count >= 3  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoEE.targetloc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end