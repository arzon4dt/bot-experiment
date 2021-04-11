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

local castFBDesire = 0;
local castUFBDesire = 0;
local castACDesire = 0;
local castHPDesire = 0;
local castHoGDesire = 0;

local abilityUFB = nil;
local abilityFB = nil;
local abilityAC = nil;
local abilityHP = nil;
local abilityHoG = nil;

local npcBot = GetBot();
npcBot.creeps = {}; 
local maxUnit = 0;

function AbilityUsageThink()

	--if npcBot == nil then npcBot = GetBot(); end
	--print(tostring(#npcBot.creeps))
	
	--[[for _,u in pairs(npcBot.creeps) do
		print(tostring(u).." : "..u:GetUnitName().." > "..tostring(u:HasModifier('modifier_chen_holy_persuasion')))
	end]]--
	
	-- Check if we're already using an ability
	if mutil.CanNotUseAbility(npcBot) then return end

	if abilityUFB == nil then abilityUFB = npcBot:GetAbilityByName( "chen_penitence" ) end
	if abilityFB == nil then abilityFB = npcBot:GetAbilityByName( "chen_divine_favor" ) end
	--if abilityAC == nil then abilityAC = npcBot:GetAbilityByName( "chen_test_of_faith_teleport" ) end
	if abilityHP == nil then abilityHP = npcBot:GetAbilityByName( "chen_holy_persuasion" ) end
	if abilityHoG == nil then abilityHoG = npcBot:GetAbilityByName( "chen_hand_of_god" ) end

	-- Consider using each ability
	-- castFBDesire, castFBTarget = ConsiderFireblast();
	castUFBDesire, castUFBTarget = ConsiderUnrefinedFireblast();
	--castACDesire, castACTarget = ConsiderAphoticShield();
	--castHPDesire, castHPTarget = ConsiderHolyPersuasion();
	castHoGDesire = ConsiderHandofGod();
	
	if ( castHoGDesire > 0 ) 
	then
		npcBot:Action_UseAbility( abilityHoG );
		return;
	end
	
	if ( castACDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityAC, castACTarget );
		return;
	end
	
	if ( castUFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityUFB, castUFBTarget );
		return;
	end

	if ( castFBDesire > 0 ) 
	then
		npcBot:Action_UseAbilityOnEntity( abilityFB, castFBTarget );
		return;
	end
	
	if ( castHPDesire > 0 ) 
	then
		--print(tostring(castHPTarget))
		--AddedToDominated(castHPTarget);
		npcBot:Action_UseAbilityOnEntity( abilityHP, castHPTarget );
		return;
	end
	
	--UpdateDominatedCreeps();

end

function AddedToDominated(unit)
	if #npcBot.creeps == 0 then
		table.insert(npcBot.creeps, unit);
	else
		for _,u in pairs(npcBot.creeps) do
			if tostring(unit) ~= tostring(u) then
				table.insert(npcBot.creeps, unit);
			end
		end
	end
end

function UpdateDominatedCreeps()
	local removedkey = -1;
	for i,u in pairs(npcBot.creeps) do
		if u:IsNull() or u == nil or not u:IsAlive() or not u:HasModifier('modifier_chen_holy_persuasion') or u:GetTeam() ~= npcBot:GetTeam() or IsDuplicated(u) then
			removedkey = i;
			break;
		end
	end
	if removedkey ~= -1 then
		table.remove(npcBot.creeps, removedkey);
	end
end

function IsDuplicated(unit)
	local count = 0;
	for _,u in pairs(npcBot.creeps) do
		if tostring(unit) == tostring(u) then
			count = count + 1;
		end
	end
	return count > 1;
end

function ConsiderUnrefinedFireblast()

	-- Make sure it's castable
	if ( not abilityUFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nCastRange = abilityUFB:GetCastRange();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and mutil.CanCastOnNonMagicImmune(npcEnemy) ) 
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
		if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function ConsiderFireblast()

	-- Make sure it's castable
	if ( not abilityFB:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local numPlayer =  GetTeamPlayers(GetTeam());
	if  mutil.IsDefending(npcBot)
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
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 4000 and health >= 0.25 then
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
	
	if mutil.IsPushing(npcBot)
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
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 4000 and health >= 0.25  then
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
	
	if mutil.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( npcTarget ~= nil  and npcTarget:IsHero() and GetUnitToUnitDistance( npcTarget, npcBot ) < 1600  ) 
		then	
			local maxDist = 0;
			local target = nil;
			for i = 1, #numPlayer
			do
				local player = GetTeamMember(i);
				if player ~= nil and player:IsAlive() and player:GetActiveMode() ~= BOT_MODE_RETREAT then
					local dist = GetUnitToUnitDistance(player, npcBot);
					local health = player:GetHealth()/player:GetMaxHealth();
					if IsPlayerBot(player:GetPlayerID()) and dist > maxDist and dist > 4000 and health >= 0.25 then
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


function ConsiderHolyPersuasion()

	-- Make sure it's castable
	if ( not abilityHP:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local nCastRange = abilityHP:GetCastRange();

	-- If we're in a teamfight, use it on the scariest enemy
	local lowHpAlly = nil;
	local nLowestHealth = 10000;

	local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
	for _,npcAlly in pairs( tableNearbyAllies )
	do
		if ( mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetUnitName() ~= npcBot:GetUnitName() )
		then
			local nAllyHP = npcAlly:GetHealth();
			if  nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.25 and npcAlly:WasRecentlyDamagedByAnyHero(3.0)  
			then
				nLowestHealth = nAllyHP;
				lowHpAlly = npcAlly;
			end
		end
	end

	if ( lowHpAlly ~= nil )
	then
		return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end
function ConsiderAphoticShield()

	-- Make sure it's castable
	if ( not abilityAC:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityAC:GetCastRange();

	-- If we're in a teamfight, use it on the scariest enemy
	local lowHpAlly = nil;
	local nLowestHealth = 10000;

	local tableNearbyAllies = npcBot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE  );
	for _,npcAlly in pairs( tableNearbyAllies )
	do
		if ( mutil.CanCastOnNonMagicImmune(npcAlly) and npcAlly:GetUnitName() ~= npcBot:GetUnitName() )
		then
			local nAllyHP = npcAlly:GetHealth();
			if  ( nAllyHP < nLowestHealth and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.35 ) and
				( npcAlly:GetActiveMode() == BOT_MODE_RETREAT and npcAlly:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
			then
				nLowestHealth = nAllyHP;
				lowHpAlly = npcAlly;
			end
		end
	end

	if ( lowHpAlly ~= nil )
	then
		return BOT_ACTION_DESIRE_MODERATE, lowHpAlly;
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderHandofGod()

	-- Make sure it's castable
	if ( not abilityHoG:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if mutil.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if mutil.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	local maxDist = 0;
	local target = nil;
	for i = 1, #numPlayer
	do
		local Ally = GetTeamMember(i);
		if Ally:IsAlive() and 
			Ally:GetActiveMode() == BOT_MODE_RETREAT and Ally:GetActiveModeDesire() >= BOT_ACTION_DESIRE_HIGH and
			Ally:GetHealth() /Ally:GetMaxHealth() < 0.45 and Ally:WasRecentlyDamagedByAnyHero(2.0)
		then
			target = GetTeamMember(i);
			break;
		end
	end
	if target ~= nil then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end



