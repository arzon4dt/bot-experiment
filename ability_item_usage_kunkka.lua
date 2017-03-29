local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local Combo1Time = 0; 
local Combo2Time = 0; 
local Combo3Time = 0; 

local C1Delay = 2.5; 
local C2Delay = 1.8; 
local C3Delay = 3.5; 
local Combo1 = 0;
local Combo2 = 0;
local Combo3 = 0;

local castTODesire = 0;
local castXSDesire = 0;
local castGSDesire = 0;

local abilityTO = "";
local abilityXS = "";
local abilityRT = "";
local abilityGS = "";

function AbilityUsageThink()

	local npcBot = GetBot();
	
	if not npcBot:IsAlive() then
		Combo1Time = 0;
		Combo2Time = 0;
		Combo3Time = 0;
	end
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced() or npcBot:NumQueuedActions() > 0   ) then return end

	if abilityTO == "" then abilityTO = npcBot:GetAbilityByName( "kunkka_torrent" ); end
	if abilityXS == "" then abilityXS = npcBot:GetAbilityByName( "kunkka_x_marks_the_spot" ); end
	if abilityRT == "" then abilityRT = npcBot:GetAbilityByName( "kunkka_return" ); end
	if abilityGS == "" then abilityGS = npcBot:GetAbilityByName( "kunkka_ghostship" ); end
	
	Combo1, Combo1Target, Combo1Loc = ConsiderCombo1();
	Combo2, Combo2Target, Combo2Loc = ConsiderCombo2();
	Combo3, Combo3Target, Combo3Loc = ConsiderCombo3();
	castTODesire, castTOLoc = ConsiderTorrent()
	castXSDesire, castXSTarget = ConsiderXMark()
	castGSDesire, castGSLoc = ConsiderGhostShip()
	
	if not abilityRT:IsHidden() and 
		( 
		  ( Combo3Time ~= 0 and DotaTime() >= Combo3Time + C3Delay ) or 
		  ( Combo1Time ~= 0 and DotaTime() >= Combo1Time + C1Delay ) or
		  ( Combo2Time ~= 0 and DotaTime() >= Combo2Time + C2Delay ) 
		)
	then
		npcBot:Action_UseAbility(abilityRT);
		Combo1Time = 0;
		Combo2Time = 0;
		Combo3Time = 0;
		return
	end
	
	if Combo1 > 0 then
		Combo1Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo1Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityGS,  Combo1Loc);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityTO, Combo1Loc);
		return;
	end
	
	if Combo2 > 0 then
		Combo2Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo2Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityTO, Combo2Loc);
		return;
	end
	
	if Combo3 > 0 then
		Combo3Time = DotaTime();
		npcBot:Action_ClearActions(false);
		npcBot:ActionQueue_UseAbilityOnEntity(abilityXS, Combo3Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityGS,  Combo3Loc);
		return;
	end
	
	if castTODesire > 0 then 
		npcBot:Action_UseAbilityOnLocation(abilityTO,  castTOLoc);
		return;
	end
	
	if castXSDesire > 0 then
		Combo1Time = DotaTime() + C2Delay;
		npcBot:Action_UseAbilityOnEntity(abilityXS,  castXSTarget);
		return;
	end
	
	if castGSDesire > 0 then
		npcBot:Action_UseAbilityOnLocation(abilityGS,  castGSLoc);
		return;
	end
	
end

function CanCastXMarkOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function ConsiderCombo1()
	local npcBot = GetBot()
	
	if not abilityTO:IsFullyCastable() or not abilityXS:IsFullyCastable() or not abilityGS:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityTO:GetManaCost() + abilityXS:GetManaCost() + abilityGS:GetManaCost();
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastXMarkOnTarget(npcTarget) and 
			GetUnitToUnitDistance(npcTarget, npcBot) > nCastRange/2 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			--return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetXUnitsInFront( 75 )
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil
end

function ConsiderCombo2()
	local npcBot = GetBot()
	
	if not abilityTO:IsFullyCastable() or not abilityXS:IsFullyCastable() or abilityGS:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityTO:GetManaCost() + abilityXS:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastXMarkOnTarget(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			
			--return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetXUnitsInFront( 75 )
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end

function ConsiderCombo3()
	local npcBot = GetBot()
	
	if not abilityGS:IsFullyCastable() or not abilityXS:IsFullyCastable() or abilityTO:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityGS:GetManaCost() + abilityXS:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastXMarkOnTarget(npcTarget) and 
			GetUnitToUnitDistance(npcTarget, npcBot) > nCastRange/2 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end

function ConsiderTorrent()
	local npcBot = GetBot()
	
	if not abilityTO:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, {};
	end
	
	local nCastPoint = abilityTO:GetCastPoint();
	local nDelay = abilityTO:GetSpecialValueFloat("delay");
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nDelay + nCastPoint);
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastXMarkOnTarget(npcTarget) and GetUnitToUnitDistance(npcTarget, npcBot) < 600 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nDelay + nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, {};
end

function ConsiderXMark()
	local npcBot = GetBot()
	
	if not abilityXS:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityXS:GetCastRange();
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() or ( npcEnemy:GetActiveMode() == BOT_MODE_RETREAT and npcEnemy:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderGhostShip()
	local npcBot = GetBot()
	
	if not abilityGS:IsFullyCastable() or Combo1 > 0 or Combo2 > 0 or Combo3 > 0
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityGS:GetCastRange();
	local nRadius = abilityGS:GetSpecialValueInt("ghostship_width");
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, GetTowardsFountainLocation(npcBot:GetLocation(), nCastRange - 200)
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange/2, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end