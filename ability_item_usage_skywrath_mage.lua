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

local abilities = mutils.InitiateAbilities(bot, {0,1,2,5});

local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local function CanCastOnCreep(unit)
	return unit:CanBeSeen() and unit:IsMagicImmune() == false and unit:IsInvulnerable() == false; 
end

local function GetReservedMana(ability_idx)
	local reserved = 0;
	for i=1, #abilities do
		if i~=ability_idx  
			and ( mutils.CanBeCast(abilities[i]) == true
			or ( abilities[i]:IsTrained() and abilities[i]:GetCooldownTimeRemaining() < 3 ) ) 
		then
			reserved = reserved + abilities[i]:GetManaCost();
		end	
	end
	return reserved;
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nDamage   = abilities[1]:GetSpecialValueFloat('bolt_damage')+bot:GetAttributeValue(ATTRIBUTE_INTELLECT)*abilities[1]:GetSpecialValueFloat('int_multiplier');
	local nRadius    = abilities[1]:GetSpecialValueInt('scepter_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) ) or 
		( bot:GetActiveMode() == BOT_MODE_LANING and abilities[1]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and CanCastOnCreep(creeps[i]) == true
				and nDamage > creeps[i]:GetHealth()
			then	
				return BOT_ACTION_DESIRE_MODERATE, creeps[i];
			end
		end
		local heroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #heroes do
			if mutils.IsValidTarget(heroes[i]) 
				and mutils.CanCastOnNonMagicImmune(heroes[i]) 
			then	
				return BOT_ACTION_DESIRE_MODERATE, heroes[i];
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and bot:GetMana() > GetReservedMana(1)
		then
			return BOT_ACTION_DESIRE_MODERATE, target;
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
	local nRadius    = abilities[2]:GetSpecialValueInt('slow_radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local enemies=bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_MODERATE;
		end	
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
			and mutils.IsDisabled(true, target) == false
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
	
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nDamage    = abilities[3]:GetSpecialValueInt('damage');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	for i=1, #enemies do
		if mutils.IsValidTarget(enemies[i]) 
			and mutils.CanCastOnNonMagicImmune(enemies[i])
			and enemies[i]:IsChanneling() == true
		then
			return BOT_ACTION_DESIRE_HIGH, enemies[i];
		end	
	end
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local target = mutils.GetStrongestUnit(nCastRange, bot, true, false, 5.0);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
			and mutils.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_MODERATE, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target)
			and mutils.IsInRange(target, bot, nCastRange) 
		then
			if target:IsRooted() or target:IsStunned() then
				return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
			elseif target:GetCurrentMovementSpeed() < target:GetBaseMovementSpeed() then
				return BOT_ACTION_DESIRE_MODERATE, target:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire			 = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	if castQDesire > 0 then	
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[3], eTarget);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);	
		return
	end
	
end