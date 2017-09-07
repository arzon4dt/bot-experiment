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

local castLSDesire = 0;
local castLADesire = 0;
local castOGDesire = 0;

local abilityLS = nil;
local abilityLA = nil;
local abilityOG = nil;

local npcBot = nil;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityLS == nil then abilityLS = npcBot:GetAbilityByName( "treant_leech_seed" ) end
	if abilityLA == nil then abilityLA = npcBot:GetAbilityByName( "treant_living_armor" ) end
	if abilityOG == nil then abilityOG = npcBot:GetAbilityByName( "treant_overgrowth" ) end

	-- Consider using each ability
	castLSDesire, castLSTarget = ConsiderLeechSeed();
	castLADesire, castLATarget = ConsiderLivingArmor();
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	

	if ( castOGDesire > castLSDesire and castOGDesire > castLADesire ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end

	if ( castLSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLS, castLSTarget );
		return;
	end
	
	if ( castLADesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLA, castLATarget );
		return;
	end

end

function ConsiderLeechSeed()

	-- Make sure it's castable
	if ( not abilityLS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityLS:GetCastRange();
	local nDuration = abilityLS:GetSpecialValueInt( "duration" );
	local nDOT = abilityLS:GetSpecialValueInt( "leech_damage" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderLivingArmor()

	-- Make sure it's castable
	if ( not abilityLA:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end

	-- If we're pushing or defending a lane
	if mutil.IsDefending(npcBot)
	then
		local tableNearbyFriendlyTowers = npcBot:GetNearbyTowers( 400, false );
		for _,myTower in pairs(tableNearbyFriendlyTowers) do
			if ( GetUnitToUnitDistance( myTower, npcBot  ) < 400 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myTower;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1300, false, BOT_MODE_NONE );
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if (  mutil.CanCastOnNonMagicImmune(npcAlly) and( npcAlly:GetHealth() / npcAlly:GetMaxHealth() ) < 0.5 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 600)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player:GetHealth()/Player:GetMaxHealth() < 0.65 and 
		   mutil.IsRetreating(Player) and Player:DistanceFromFountain() > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE, Player;
		end
	end
	
	local Team = GetTeam();
	for i = 0, 10
	do
		local tower =  GetTower(Team, i);
		if tower ~= nil and tower:GetHealth() > 0 then
			local THealth = tower:GetHealth()/tower:GetMaxHealth();
			if  THealth < 1.0 and npcBot:GetMana()/npcBot:GetMaxMana() > 0.45 then 
				return BOT_ACTION_DESIRE_MODERATE, tower;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function ConsiderOvergrowth()

	-- Make sure it's castable
	if ( not abilityOG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityOG:GetSpecialValueInt( "radius" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local nInvUnit = mutil.CountInvUnits(true, tableNearbyEnemyHeroes);
		if nInvUnit >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nRadius - 200)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
