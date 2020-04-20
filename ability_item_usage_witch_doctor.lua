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

local function GetNumEnemyCreepsAroundTarget(target, bEnemy, nRadius)
	local locationAoE = bot:FindAoELocation( true, false, target:GetLocation(), 0, nRadius, 0, 0 );
	if ( locationAoE.count >= 3 ) then
		return 3;
	end
	return 0;
end

local function GetReservedMana()
	local reserved = 0;
	if mutils.CanBeCast(abilities[4]) == true or ( abilities[4]:IsTrained() and abilities[4]:GetCooldownTimeRemaining() < 5 ) then
		reserved = reserved + abilities[4]:GetManaCost();
	end
	if mutils.CanBeCast(abilities[1]) == true or ( abilities[1]:IsTrained() and abilities[1]:GetCooldownTimeRemaining() < 5 ) then
		reserved = reserved + abilities[1]:GetManaCost();
	end
	if mutils.CanBeCast(abilities[3]) == true or ( abilities[3]:IsTrained() and abilities[3]:GetCooldownTimeRemaining() < 5 ) then
		reserved = reserved + abilities[3]:GetManaCost();
	end
	return reserved;
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('bounce_range');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and mutils.IsDisabled(true, enemies[i]) == false
			then
				return BOT_ACTION_DESIRE_MODERATE, enemies[i];
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		if #allies <= 2 then
			local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
			for i=1, #creeps do
				if creeps[i] ~= nil 
					and CanCastOnCreep(creeps[i]) == true
				then	
					local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
					if n_creeps >= 3 then
						return BOT_ACTION_DESIRE_MODERATE, creeps[i];
					end	
				end
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) 
			and mutils.IsDisabled(true, target) == false
		then
			local available_stun = 0
			local allies = target:GetNearbyHeroes(800, true, BOT_MODE_NONE)
			for i=1, #allies do
				if allies[i]~=bot
					and mutils.IsDisabled(false, allies[i]) == false
				then
					available_stun = available_stun + allies[i]:GetStunDuration(true);
				end
			end
			if available_stun < 1 then
				return BOT_ACTION_DESIRE_MODERATE, target;	
			else
				local enemies = target:GetNearbyHeroes(0.75*nRadius, false, BOT_MODE_NONE);
				if #enemies > 1 then
					return BOT_ACTION_DESIRE_MODERATE, target;	
				end
				local creeps = target:GetNearbyLaneCreeps(0.75*nRadius, false);
				if #creeps > 0 then
					return BOT_ACTION_DESIRE_MODERATE, target;	
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
	local nRadius    = abilities[2]:GetSpecialValueInt('radius');
	
	local lowHpAllies = 0;	
	if bot:GetMana() > GetReservedMana() then
		local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
		for i=1, #allies do
			if mutils.IsValidTarget(allies[i])
				and mutils.CanCastOnMagicImmune(allies[i])
				and allies[i]:GetHealth() < 0.55*allies[i]:GetMaxHealth()
			then
				lowHpAllies = lowHpAllies + 1;
			end	
		end
	end
	
	if lowHpAllies >= 1 and abilities[2]:GetToggleState() == false then
		return BOT_ACTION_DESIRE_MODERATE;
	elseif lowHpAllies == 0 and abilities[2]:GetToggleState() == true then
			return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nRadius    = abilities[3]:GetSpecialValueInt('bounce_range');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
			then
				return BOT_ACTION_DESIRE_MODERATE, enemies[i]:GetLocation();
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) 
		then
			return BOT_ACTION_DESIRE_MODERATE, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false 
		or mutils.CanBeCast(abilities[1]) == true 
		or mutils.CanBeCast(abilities[3]) == true 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local nDamage    = abilities[4]:GetSpecialValueInt('damage')*8;
	local manaCost   = abilities[4]:GetManaCost();
	local nRadius    = abilities[4]:GetSpecialValueInt('attack_range_tooltip');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange+0.25*nRadius) 
			and target:GetHealth() > 0.5*nDamage
		then
			local enemies = bot:GetNearbyHeroes(250, true, BOT_MODE_NONE)
			if #enemies == 0 then
				if mutils.IsInRange(bot, target, nCastRange) == true then
					local distance = GetUnitToUnitDistance(target, bot);
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( target:GetLocation(), 0.75*distance );
				else
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation( target:GetLocation(), nCastRange-100 );
				end	
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if bot:IsChanneling() 
		and mutils.CanBeCast(abilities[2]) == true 
		and bot:GetHealth() < 0.55*bot:GetMaxHealth()
		and abilities[2]:GetToggleState() == false
	then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire			 = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	if castQDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_ClearActions(false);
		bot:Action_UseAbilityOnLocation(abilities[3], eTarget);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbilityOnLocation(abilities[4], rTarget);		
		return
	end
	
end