local bot = GetBot();

if bot:IsInvulnerable() or bot:IsHero() == false or bot:IsIllusion() then return; end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")

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

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5,3});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castDDesire = 0;
local castRDesire = 0;
local castCogsTime = -90;

local camps = GetNeutralSpawners();

local function IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= target
			and ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end

local function IsHeroBetweenMeAndLocation(source, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius + 25 			
			then
				return true;
			end
		end
	end
	return false;
end

local function IsCreepBetweenMeAndLocation(source, endLoc, radius)
	local vStart = source:GetLocation();
	local vEnd = endLoc;
	local enemy_heroes = bot:GetNearbyLaneCreeps(1600, true);
	for i=1, #enemy_heroes do
		local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation());
		if tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < radius + 25 			
		then
			return true;
		end
	end
	local ally_heroes = bot:GetNearbyLaneCreeps(1600, false);
	for i=1, #ally_heroes do
		local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation());
		if tResult ~= nil 
			and tResult.within == true  
			and tResult.distance < radius + 25 			
		then
			return true;
		end
	end
	return false;
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false or bot:HasModifier('modifier_rattletrap_battery_assault') == true then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('radius');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nRadius) == true	
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt('cogs_radius');
	local nColSize	 = 80;
	
	local nDuration = abilities[2]:GetSpecialValueFloat('duration');
	
	if DotaTime() < castCogsTime + nDuration then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local allies = bot:GetNearbyHeroes(nRadius+2*nColSize, false, BOT_MODE_NONE);
		if #allies <= 1 then
			local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
			if #enemies > 0 then
				local enemies2 = bot:GetNearbyHeroes(nRadius+2*nColSize, true, BOT_MODE_NONE);
				if #enemies2 == 0 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) == true 
			and mutils.IsInRange(target, bot, nRadius) == true
		then
			local allies = bot:GetNearbyHeroes(nRadius+2*nColSize, false, BOT_MODE_NONE);
			if #allies <= 2 then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nRadius    = abilities[3]:GetSpecialValueInt('radius');
	local speed      = abilities[3]:GetSpecialValueInt('speed');
	local nCastRange = 1600;
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, 0.5*nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, 0.5*nRadius, 0, 0 );
		if ( locationAoE.count >= 3 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)  
		then
			local distance = GetUnitToUnitDistance(bot, target);
			local moveCon = target:GetMovementDirectionStability();
			local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 0.65 then
				pLoc = target:GetLocation();
			end
			return BOT_ACTION_DESIRE_MODERATE, pLoc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderD()
	if  mutils.CanBeCast(abilities[5]) == false or bot:HasScepter() == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[5]:GetCastPoint();
	local manaCost   = abilities[5]:GetManaCost();
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)  
			and mutils.IsInRange(bot, target, 600) == true	
		then
			local n_ability = 0;
			for i=1, 4 do
				if abilities[i] ~= nil 
					and abilities[i]:IsTrained() == true
					and mutils.CheckFlag(abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
					and mutils.CheckFlag(abilities[i]:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
				then
					if abilities[i]:GetCooldownTimeRemaining() > 3 then
						n_ability = n_ability + 1;
					end
				end
			end
			if  n_ability >= 3 then
				return BOT_ACTION_DESIRE_ABSOLUTE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost   = abilities[4]:GetManaCost();
	local nRadius    = abilities[4]:GetSpecialValueInt('stun_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local speed      = abilities[4]:GetSpecialValueInt('speed');
	local nCastRange2 = 1500 + abilities[4]:GetLevel()*500;
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
		local botBaseDist = bot:DistanceFromFountain();
		for i=1, #allies do
			if mutils.IsValidTarget(allies[i])
				and allies[i] ~= bot
				and mutils.CanCastOnMagicImmune(allies[i])
				and allies[i]:DistanceFromFountain() < botBaseDist
				and GetUnitToUnitDistance(allies[i], bot) > 0.5*nCastRange
			then
				local distance = GetUnitToUnitDistance(allies[i], bot)
				local moveCon = allies[i]:GetMovementDirectionStability();
				local pLoc = allies[i]:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
				if moveCon < 0.65 then
					pLoc = allies[i]:GetLocation();
				end
				if IsHeroBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false 
					and mutils.IsCreepBetweenMeAndTarget(bot, allies[i], pLoc, nRadius) == false
				then
					return BOT_ACTION_DESIRE_MODERATE, pLoc;
				end
			end	
		end	
		local loc = mutils.GetEscapeLoc();
		local bDist = GetUnitToLocationDistance(bot, loc);
		for i=1, #camps do
			local cDist = utils.GetDistance(camps[i].location, loc); 
			if cDist < bDist 
				and GetUnitToLocationDistance(bot, camps[i].location) > 0.25*nCastRange2 
			then
				if IsHeroBetweenMeAndLocation(bot, camps[i].location, nRadius) == false 
					and IsCreepBetweenMeAndLocation(bot, camps[i].location, nRadius) == false
				then
					return BOT_ACTION_DESIRE_MODERATE, camps[i].location;
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if  mutils.IsValidTarget(target) and mutils.CanCastOnMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange-150)
		then
			local distance = GetUnitToUnitDistance(target, bot)
			local moveCon = target:GetMovementDirectionStability();
			local pLoc = target:GetExtrapolatedLocation( nCastPoint + ( distance / speed ) );
			if moveCon < 0.65 then
				pLoc = target:GetLocation();
			end
			if mutils.IsAllyHeroBetweenMeAndTarget(bot, target, pLoc, nRadius) == false 
				and mutils.IsCreepBetweenMeAndTarget(bot, target, pLoc, nRadius) == false
			then
				return BOT_ACTION_DESIRE_MODERATE, pLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire		  	 = ConsiderQ();
	castWDesire			 = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castDDesire			 = ConsiderD();
	castRDesire, rTarget = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[1]);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[2]);	
		castCogsTime = DotaTime();	
		return
	end
	
	if castEDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnLocation(abilities[3], eTarget);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[5]);		
		return
	end
	
end