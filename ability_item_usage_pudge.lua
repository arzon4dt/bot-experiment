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
local castRDesire = 0;
local castDDesire = 0;

local moveS = 0;
local moveST = nil;

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
	local ally_heroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
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

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('hook_width');
	local speed    	 = abilities[1]:GetSpecialValueInt('hook_speed');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange())-300;
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
			and mutils.IsInRange(bot, target, nCastRange)
		then
			-- if moveST ~= target:GetUnitName() or target:GetMovementDirectionStability() ~= moveS then
				-- print(target:GetUnitName().." : "..tostring(target:GetMovementDirectionStability()))
				-- moveST = target:GetUnitName();
				-- moveS = target:GetMovementDirectionStability();
			-- end
			local allies = bot:GetNearbyHeroes(150, false, BOT_MODE_NONE);
			if #allies <= 1 then
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
	end
	
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_RETREAT);
	if #allies > 0 then
		local botBaseDist = bot:DistanceFromFountain();
		for i=1, #allies do
			if mutils.IsValidTarget(allies[i])
				and allies[i] ~= bot
				and mutils.CanCastOnMagicImmune(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(5.0)
				and allies[i]:GetHealth() < 0.5*allies[i]:GetMaxHealth()
				and ( allies[i]:GetTarget() == nil or allies[i]:GetAttackTarget() == nil )
				and allies[i]:DistanceFromFountain() > botBaseDist
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
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderW()
	if  mutils.CanBeCast(abilities[2]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt('rot_radius');
	
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and bot:GetHealth() > 0.65*bot:GetMaxHealth() 
	then
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if #creeps >= 4 and abilities[2]:GetToggleState() == false then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
		then
			if mutils.IsInRange(bot, target, nRadius)	
				and abilities[2]:GetToggleState() == false 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			elseif mutils.IsInRange(bot, target, nRadius) == false 
				and abilities[2]:GetToggleState() == true 	
			then	
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	else
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		if (( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) 
			or #enemies == 0 
			or ( ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and ( #creeps < 4 or bot:GetHealth() < 0.6*bot:GetMaxHealth() ) ) )
			and abilities[2]:GetToggleState() == true
		then 
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost   = abilities[4]:GetManaCost();
	local nStr = bot:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local nStrMultiply = abilities[4]:GetSpecialValueFloat('strength_damage')
	local nDamage    = (abilities[4]:GetSpecialValueInt('dismember_damage')+nStrMultiply*nStr)*3;
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),15) 
			and mutils.IsInRange(bot, target, nCastRange)	
			and mutils.IsDisabled(true, target) == false	
			and target:GetHealth() >  0.5*nDamage
		then
			local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_ATTACK);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, target;
			end
		end
	end
	
	if bot:HasScepter() == true then
		local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i]:GetUnitName() ~= bot:GetUnitName() 
				and mutils.CanCastOnNonMagicImmune(allies[i]) == true
				and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
			then
				local mode2 = allies[i]:GetActiveMode();
				local loc = mutils.GetEscapeLoc2(allies[i]);
				if  allies[i]:IsFacingLocation(loc,30)
					and ( ( mode2 == BOT_MODE_RETREAT and allies[i]:GetHealth() < 0.20 * allies[i]:GetMaxHealth() ) 
						or ( allies[i]:GetHealth() < 0.20 * allies[i]:GetMaxHealth() 
							and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) )
				then	
					return BOT_ACTION_DESIRE_ABSOLUTE, allies[i];
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local function ConsiderD()
	if  mutils.CanBeCast(abilities[5]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = 1400;
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	if enemies == nil or #enemies == 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function AbilityUsageThink()
	
	if bot:IsChanneling() then
		if mutils.CanBeCast(abilities[2]) == true 
			and  mutils.IsGoingOnSomeone(bot)
		then
			local nRadius = abilities[2]:GetSpecialValueInt('rot_radius');
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) 
				and mutils.CanCastOnNonMagicImmune(target) 
				and bot:IsFacingLocation(target:GetLocation(),15) 
				and mutils.IsInRange(bot, target, nRadius)	
				and abilities[2]:GetToggleState() == false 
			then
				bot:Action_UseAbility(abilities[2]);		
				return
			end
		end
	end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire			 = ConsiderW();
	-- castEDesire			 = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnEntity(abilities[4], rTarget);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnLocation(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
end