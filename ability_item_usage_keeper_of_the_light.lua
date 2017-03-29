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

local castFBDesire = 0;
local castCSDesire = 0;
local castCSSDesire = 0;
local castCS2Desire = 0;
local castBLDesire = 0;
local castFGDesire = 0;
local castRCDesire = 0;

function AbilityUsageThink()

	local npcBot = GetBot();
	
	-- Check if we're already using an ability
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:IsSilenced()  ) then return end
	abilityFB = npcBot:GetAbilityByName( "keeper_of_the_light_mana_leak" );
	abilityCS = npcBot:GetAbilityByName( "keeper_of_the_light_illuminate" );
	abilityCSS = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form_illuminate" );
	abilityCS2 = npcBot:GetAbilityByName( "keeper_of_the_light_blinding_light" );
	abilityBL = npcBot:GetAbilityByName( "keeper_of_the_light_chakra_magic" );
	abilityFG = npcBot:GetAbilityByName( "keeper_of_the_light_spirit_form" );
	abilityRC = npcBot:GetAbilityByName( "keeper_of_the_light_recall" );

	-- Consider using each ability
	castFBDesire, castFBTarget = ConsiderFireblast();
	castCSDesire, castCSLocation = ConsiderChrono();
	castCSSDesire, castCSSLocation = ConsiderChronoS();
	castCS2Desire, castCS2Location = ConsiderChrono2();
	castBLDesire, castBLTarget = ConsiderBloodlust();
	castFGDesire, castFGTarget = ConsiderFleshGolem();
	castRCDesire, castRCTarget = ConsiderRecall();
	
	if ( castFGDesire > 0 ) 
	then
		
		npcBot:Action_UseAbility( abilityFG );
		return;
	end
	
	if ( castCS2Desire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCS2, castCS2Location );
		return;
	end	
	
	if ( castFBDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castCSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCS, castCSLocation );
		return;
	end	
	if ( castCSSDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnLocation( abilityCSS, castCSSLocation );
		return;
	end	
	
	if ( castBLDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityBL, castBLTarget );
		return;
	end
	
	if ( castRCDesire > 0 ) 
	then
		
		npcBot:Action_UseAbilityOnEntity( abilityRC, castRCTarget );
		return;
	end
	
	
	
end

function CanCastFireblastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastBloodlustOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderFireblast()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end


	-- Get some of its values
	local nCastRange = abilityFB:GetCastRange();
	--------------------------------------
	-- Mode based usage
	--------------------------------------
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
		if ( npcTarget ~= nil  and npcTarget:IsHero() ) 
		then
			if ( CanCastFireblastOnTarget( npcTarget ) and GetUnitToUnitDistance( npcBot, npcTarget ) < nCastRange + 200 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderChrono()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( npcBot:HasScepter() or npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or not abilityCS:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();
	local nCastPoint = abilityCS:GetCastPoint();

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChronoS()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityCSS:IsFullyCastable() or abilityCSS:IsHidden() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS:GetSpecialValueInt("radius");
	local nCastRange = abilityCS:GetCastRange();
	local nCastPoint = abilityCS:GetCastPoint();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
		npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
		( npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or npcBot:HasScepter()) ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and 
				GetUnitToUnitDistance(npcEnemy, npcBot) < 800  )
			then
				return BOT_ACTION_DESIRE_LOW, npcBot:GetXUnitsInFront(400);
			end
		end
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( GetUnitToUnitDistance(npcEnemy, npcBot) < nCastRange ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange and #tableNearbyEnemyHeroes >= 2 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBloodlust()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityBL:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityBL:GetCastRange();
	
	if  npcBot:GetMana() / npcBot:GetMaxMana() < 0.75 then
		return BOT_ACTION_DESIRE_MODERATE, npcBot;
	else
		local tableNearbyFriendlyHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
		for _,myFriend in pairs(tableNearbyFriendlyHeroes) do
			if ( CanCastBloodlustOnTarget(myFriend) and GetUnitToUnitDistance( myFriend, npcBot  ) < nCastRange + 200 and myFriend:GetMana() / myFriend:GetMaxMana() < 0.5  ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, myFriend;
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFleshGolem()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( npcBot:HasScepter() or npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or not abilityFG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = 1000;
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
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
	
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE  );
		if ( #tableNearbyEnemyHeroes >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE;
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
		if ( npcTarget ~= nil and GetUnitToUnitDistance( npcBot, npcTarget ) < 800 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderChrono2()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or abilityCS2:IsHidden() or not abilityCS2:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityCS2:GetSpecialValueInt("radius");
	local nCastRange = abilityCS2:GetCastRange();
	local nCastPoint = abilityCS2:GetCastPoint();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and 
		npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH  ) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) )
			then
				if GetUnitToUnitDistance(npcEnemy, npcBot) < nRadius then
					return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation()
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and CanCastFireblastOnTarget(npcTarget) and GetUnitToUnitDistance( npcTarget, npcBot ) < nCastRange - nRadius / 2  ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end


function ConsiderRecall()
	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form") or abilityRC:IsHidden() or not abilityRC:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local player = GetTeamMember(i);
		if player ~= nil and not IsPlayerBot(player:GetPlayerID()) and player:IsAlive() and GetUnitToUnitDistance(npcBot, player) > 1000 then
				local p = player:GetMostRecentPing();
				if p ~= nil and GetUnitToLocationDistance(player, p.location) < 1000 and GameTime() - p.time < 10 then
					--print("Human pinged to get recalled")
					return BOT_ACTION_DESIRE_MODERATE, player;
				end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, false) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT ) 
	then
		local nearbyTower = npcBot:GetNearbyTowers(1000, true) 
		if nearbyTower[1] ~= nil then
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(nearbyTower[1], player);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25  then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_ATTACK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < 1000  ) 
		then	
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(player, npcBot);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 2500 and health >= 0.25 then
						maxDist = dist;
						target = GetTeamMember(i);
					end
				end
			end
			if target ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, target;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end