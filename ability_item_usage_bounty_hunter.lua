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
local abilityE = nil;
local abilityR = nil;

local castQDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if mutil.CanNotUseAbility(npcBot) then return end
	
	if abilityQ == nil then abilityQ = npcBot:GetAbilityByName( "bounty_hunter_shuriken_toss" ) end
	if abilityE == nil then abilityE = npcBot:GetAbilityByName( "bounty_hunter_wind_walk" ) end
	if abilityR == nil then abilityR = npcBot:GetAbilityByName( "bounty_hunter_track" ) end

	castQDesire, castQTarget = ConsiderQ();
	castEDesire              = ConsiderE();
	castRDesire, castRTarget = ConsiderR();

	if ( castRDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityR, castRTarget );
		return;
	end

	if ( castQDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityQ, castQTarget );
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
	if ( not abilityQ:IsFullyCastable() or npcBot:HasModifier('modifier_bounty_hunter_wind_walk') ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt( "bounce_aoe" );
	local nCastRange = abilityQ:GetCastRange( );
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local nDamage    = abilityQ:GetSpecialValueInt( 'bonus_damage' );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	local tableNearbyCreeps = npcBot:GetNearbyLaneCreeps( nCastRange + 200, true );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if npcEnemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
		if mutil.CanCastOnNonMagicImmune(npcEnemy) and mutil.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			if mutil.IsInRange(npcEnemy, npcBot, nCastRange + 200) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif tableNearbyCreeps[1] ~= nil and mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
				and mutil.IsInRange(npcEnemy, tableNearbyCreeps[1], nRadius - 150)
			then	
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1] ;
			end
		end
	end

	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local trackedEnemy = 0;
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track')  ) 
			then
				trackedEnemy = trackedEnemy + 1;
			end
		end
		if trackedEnemy >= 2 then
			if tableNearbyCreeps[1] ~= nil then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[1];
			elseif tableNearbyEnemyHeroes[1] ~= nil and mutil.IsInRange(tableNearbyEnemyHeroes[1], npcBot, nCastRange + 200) 
			then
				return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) 
		then
			if mutil.IsInRange(npcTarget, npcBot, nCastRange + 200) then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			elseif npcTarget:HasModifier('modifier_bounty_hunter_track') 
			then
				for i=1, #tableNearbyCreeps do
					if tableNearbyCreeps[i] ~= nil and mutil.IsInRange(npcTarget, tableNearbyCreeps[i], nRadius - 150)
					then
						return BOT_ACTION_DESIRE_HIGH, tableNearbyCreeps[i] ;
					end
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() or npcBot:HasModifier('modifier_bounty_hunter_wind_walk') ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 ) or npcBot:WasRecentlyDamagedByTower(2.5) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and not mutil.IsInRange(npcTarget, npcBot, 1000) and mutil.IsInRange(npcTarget, npcBot, 2500)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange( );
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if 	mutil.IsValidTarget(npcEnemy)
			and mutil.CanCastOnNonMagicImmune(npcEnemy) 
			and not mutil.StillHasModifier(npcEnemy, 'modifier_bounty_hunter_track') 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end
