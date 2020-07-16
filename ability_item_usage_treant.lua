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

local castNGDesire = 0;
local castLSDesire = 0;
local castLADesire = 0;
local castOGDesire = 0;
local castEFDesire = 0;

local abilityNG = nil;
local abilityLS = nil;
local abilityLA = nil;
local abilityOG = nil;
local abilityEF = nil;

local npcBot = nil;
local checkBuildingTime = DotaTime();
local team = GetTeam();
local castEiFTime = -90;

function AbilityUsageThink()

	if npcBot == nil then npcBot = GetBot(); end
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityNG == nil then abilityNG = npcBot:GetAbilityByName( "treant_natures_grasp" ) end
	if abilityLS == nil then abilityLS = npcBot:GetAbilityByName( "treant_leech_seed" ) end
	if abilityLA == nil then abilityLA = npcBot:GetAbilityByName( "treant_living_armor" ) end
	if abilityOG == nil then abilityOG = npcBot:GetAbilityByName( "treant_overgrowth" ) end
	if abilityEF == nil then abilityEF = npcBot:GetAbilityByName( "treant_eyes_in_the_forest" ) end

	-- Consider using each ability
	--castNGDesire, castNGTarget = ConsiderNatureGuise();
	castNGDesire, castNGTarget = ConsiderNatureGrasp();
	castLSDesire, castLSTarget = ConsiderLeechSeed();
	castLADesire, castLATarget = ConsiderLivingArmor();
	castOGDesire, castOGTarget = ConsiderOvergrowth();
	castEFDesire, castEFTarget = ConsiderEyeForest();
	

	if ( castOGDesire > castLSDesire and castOGDesire > castLADesire ) 
	then
		npcBot:Action_UseAbility( abilityOG );
		return;
	end
	
	if ( castNGDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnLocation( abilityNG, castNGTarget );
		return;
	end

	if ( castLSDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityLS,  castLSTarget);
		return;
	end
	
	if ( castEFDesire > 0 ) 
	then
		castEiFTime = DotaTime();
		npcBot:Action_UseAbilityOnTree( abilityEF, castEFTarget );
		return;
	end
	
	if ( castLADesire > 0 ) 
	then
		local typeAOE = mutil.CheckFlag(abilityLA:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			npcBot:Action_UseAbilityOnLocation( abilityLA, castLATarget:GetLocation() );
		else
			npcBot:Action_UseAbilityOnEntity( abilityLA, castLATarget );
		end
		return;
	end

end



function GetTargetBuildingToHeal(total_heal)
	local target_building = nil;
	local min_hp = 10000;
	for i=1, #mutil.towers do
		local tower = GetTower(team, mutil.towers[i]);
		if tower ~= nil and tower:HasModifier('modifier_treant_living_armor') == false then
			local hp = tower:GetHealth();
			if hp < min_hp and hp + total_heal < tower:GetMaxHealth() then
				target_building = tower;
				min_hp = hp;
			end	
		end
	end
	for i=1, #mutil.barracks do
		local barrack = GetBarracks(team, mutil.barracks[i]);
		if barrack ~= nil and barrack:HasModifier('modifier_treant_living_armor') == false then
			local hp = barrack:GetHealth();
			if hp < min_hp and hp + total_heal < barrack:GetMaxHealth() then
				target_building = barrack;
				min_hp = hp;
			end	
		end
	end
	return target_building;
end

function ConsiderNatureGrasp()

	-- Make sure it's castable
	if ( not abilityNG:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nRadius = abilityNG:GetSpecialValueInt( "latch_range" );
	local nCastRange = abilityNG:GetCastRange();
	local nCastPoint = abilityNG:GetCastPoint( );

	if nCastRange > 1600 then nCastRange = 1600; end

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
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
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( mutil.IsDefending(npcBot) or mutil.IsPushing(npcBot) ) and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if (  locationAoE.count >= 4 and #lanecreeps >= 4   ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange-200) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNatureGuise()

	-- Make sure it's castable
	if ( not abilityNG:IsFullyCastable() or npcBot:HasModifier('modifier_treant_natures_guise_invis') == true ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityNG:GetSpecialValueInt('radius');

	local trees = npcBot:GetNearbyTrees(nRadius);

	if #trees >= 1 then
		if mutil.IsRetreating(npcBot) 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcBot;
				end
			end
		end
		
		-- If we're going after someone
		if mutil.IsGoingOnSomeone(npcBot) 
		then
			local npcTarget = npcBot:GetTarget();
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderLeechSeed()

	-- Make sure it's castable
	if ( not abilityLS:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityLS:GetSpecialValueInt('radius');
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
	
	local nCastRange = 1600;
	local total_heal = abilityLA:GetSpecialValueInt('total_heal');
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot) and npcBot:HasModifier('modifier_treant_living_armor') == false
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
			if ( GetUnitToUnitDistance( myTower, npcBot  ) < 400 and myTower:HasModifier('modifier_treant_living_armor') == false ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myTower;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		for _,npcAlly in pairs( tableNearbyAllyHeroes )
		do
			if (  mutil.CanCastOnNonMagicImmune(npcAlly) and( npcAlly:GetHealth() / npcAlly:GetMaxHealth() ) < 0.5 and npcAlly:HasModifier('modifier_treant_living_armor') == false ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcAlly;
			end
		end
	end
	
	-- If we're going after someone
	if mutil.IsGoingOnSomeone(npcBot) and npcBot:HasModifier('modifier_treant_living_armor') == false
	then
		local npcTarget = npcBot:GetTarget();
		if mutil.IsValidTarget(npcTarget) and ( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.5  and mutil.IsInRange(npcTarget, npcBot, 600) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcBot;
		end
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local Player = GetTeamMember(i);
		if Player:IsAlive() and Player:HasModifier('modifier_treant_living_armor') == false and Player:GetHealth()/Player:GetMaxHealth() < 0.65 and 
		   mutil.IsRetreating(Player) and Player:DistanceFromFountain() > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE, Player;
		end
	end
	
	local target_building = nil;
	if  DotaTime() > checkBuildingTime + 5.0 then
		target_building = GetTargetBuildingToHeal(total_heal);
		checkBuildingTime = DotaTime();
	end
	
	if target_building ~= nil then
		return  BOT_ACTION_DESIRE_HIGH, target_building;
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


function ConsiderEyeForest()

	-- Make sure it's castable
	if ( not abilityEF:IsFullyCastable() 
		or npcBot:HasScepter() == false 
		or npcBot:DistanceFromFountain() < 1000 
		or DotaTime() < castEiFTime + 3.0 ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	

	-- Get some of its values
	local nRadius = abilityEF:GetCastRange();

	local trees = npcBot:GetNearbyTrees(nRadius + 200);

	if #trees >= 1 then
		for i=1, #trees do
			if ( IsLocationVisible(GetTreeLocation(trees[i])) or IsLocationPassable(GetTreeLocation(trees[i])) ) then
				return BOT_ACTION_DESIRE_HIGH, trees[i];
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end