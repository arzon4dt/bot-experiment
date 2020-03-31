if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")
local abUtils = require(GetScriptDirectory() ..  "/AbilityItemUsageUtility")

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

local bot = GetBot();

local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;

local lastCheck = -90;
local sharpDelay = 1.5;
local sharpRadius = 0;
local sharpDuration = 0;
local sharpCastTime = DotaTime();
local sharpLocs = {};

function AbilityUsageThink()
	
	if bot:IsAlive() == false and #sharpLocs > 0 then
		sharpLocs = {};	
	end
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, targetQ = ConsiderQ();
	-- castWDesire, targetW = ConsiderW();
	castEDesire = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		if CheckNUpdateSharpLocation(targetQ) == true then 
			sharpCastTime = DotaTime();
			table.insert(sharpLocs, {t=DotaTime(), loc=targetQ})
			bot:Action_UseAbilityOnLocation(abilities[1], targetQ);		
			return
		end	
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility( abilities[3] );
		return
	end
	
end

function CheckNUpdateSharpLocation(loc)
	for k,v in pairs(sharpLocs) do
		if v ~= nil then
			-- print("loc1:"..tostring(loc).."loc2:"..tostring(v.loc)..tostring(utils.GetDistance(loc, v.loc)).."><"..tostring(1.5*sharpRadius))
			if utils.GetDistance(loc, v.loc) <= 1.75*sharpRadius then
				return false;
			end
			if DotaTime() > v.t + sharpDuration then
				table.remove(sharpLocs, k);
			end	
		end
	end
	return true;
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) or DotaTime() <= sharpCastTime + sharpDelay then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastRange2 = abilities[1]:GetCastRange();
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	sharpRadius   = abilities[1]:GetSpecialValueInt( "radius" );
	sharpDelay   = abilities[1]:GetSpecialValueFloat( "damage_delay" ) + nCastPoint;
	sharpDuration   = abilities[1]:GetSpecialValueInt( "duration" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
		end
	end
	
	local modIdx = bot:GetModifierByName("modifier_sniper_shrapnel_charge_counter")
	local sharpCharge = 0;
	if modIdx > -1 then
		sharpCharge = bot:GetModifierStackCount(modIdx);
	end	
	
	if bot:GetActiveMode() == BOT_MODE_LANING and sharpCharge > 2 and mutils.CanSpamSpell(bot, manaCost)then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, sharpRadius, 0, 0 );
		if ( locationAoE.count >= 4 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, sharpRadius, locationAoE.targetloc, bot);
			if target ~= nil and target:HasModifier('modifier_sniper_shrapnel_slow') == false then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, sharpRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, sharpRadius, locationAoE.targetloc, bot);
			if target ~= nil and target:HasModifier('modifier_sniper_shrapnel_slow') == false then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and sharpCharge > 2 and mutils.CanSpamSpell(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, sharpRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = mutils.GetVulnerableUnitNearLoc(false, true, nCastRange, sharpRadius, locationAoE.targetloc, bot);
			if target ~= nil and target:HasModifier('modifier_sniper_shrapnel_slow') == false then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
			and target:HasModifier('modifier_sniper_shrapnel_slow') == false
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	

	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRange = bot:GetAttackRange();
	local nRange2 = abilities[3]:GetSpecialValueInt('bonus_attack_range');
	
	
	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.IsInRange(npcTarget, bot, nRange) == false and mutils.IsInRange(npcTarget, bot, nRange+nRange2) == true  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastRange2 = abilities[4]:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nDamage  = abilities[4]:GetAbilityDamage();
	local nDamageType  = abilities[4]:GetDamageType();
	local nRadius   = abilities[4]:GetSpecialValueInt( "jump_range" );
	
	if DotaTime() > lastCheck + 1.0 then
		local enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for i=0, #enemies do
			if mutils.IsValidTarget(enemies[i]) and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and mutils.IsInRange(enemies[i], bot, nCastRange) == false and mutils.IsInRange(enemies[i], bot, nCastRange2)
				and mutils.CanKillTarget(enemies[i], nDamage, nDamageType)
			then
				return BOT_ACTION_DESIRE_HIGH, enemies[i];
			end
		end
		lastCheck = DotaTime();
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange) == false and mutils.IsInRange(target, bot, nCastRange2)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	