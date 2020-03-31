if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")
local nutils = require(GetScriptDirectory() ..  "/NewUtility")

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
--[[ Skill Slot
"Ability1"		"earthshaker_fissure"
"Ability2"		"earthshaker_enchant_totem"
"Ability3"		"earthshaker_aftershock"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"earthshaker_echo_slam"
]]--
--[[ Related Modifier
modifier_earthshaker_fissure_stun
modifier_earthshaker_fissure
modifier_fissure_rooted
modifier_earthshaker_enchant_totem_leap
modifier_earthshaker_enchant_totem
modifier_earthshaker_aftershock
]]
local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;

local function IsValidObject(object)
	return object ~= nil and object:IsNull() == false and object:CanBeSeen() == true;
end

local function GetUnitCountWithinRadius(tUnits, radius)
	local count = 0;
	if tUnits ~= nil and #tUnits > 0 then
		for i=1,#tUnits do
			if IsValidObject(tUnits[i]) and GetUnitToUnitDistance(bot, tUnits[i]) <= radius then
				count = count + 1;
			end
		end	
	end
	return count;
end

local function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange()-200);
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt( "fissure_radius" );
	
	if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
		for i=1,#bot.data.enemies do
			if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange and bot.data.enemies[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i]:GetLocation();
			end
		end
	end
	
	if mutils.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			for i=1,#bot.data.enemies do
				if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nCastRange then
					return BOT_ACTION_DESIRE_HIGH, bot.data.enemies[i]:GetLocation();
				end
			end
		end
	end
	
	if nutils.IsInTeamFight(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end

	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderW()
	
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, "", nil;
	end
	local nCastRange = 0;
	if bot:HasScepter() == true then
		nCastRange = abilities[2]:GetSpecialValueInt("distance_scepter");
	end
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost   = abilities[2]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt( "aftershock_range" );
	
	if bot:HasScepter() and mutils.IsStuck(bot)
	then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, "loc", bot:GetXUnitsTowardsLocation( loc, nCastRange );
	end
	
	if mutils.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			if bot:HasScepter() then
				local loc = mutils.GetEscapeLoc();
				return BOT_ACTION_DESIRE_HIGH, "loc", bot:GetXUnitsTowardsLocation( loc, nCastRange );
			else
				for i=1,#bot.data.enemies do
					if IsValidObject(bot.data.enemies[i]) and GetUnitToUnitDistance(bot, bot.data.enemies[i]) < nRadius then
						return BOT_ACTION_DESIRE_HIGH, "", nil;
					end
				end
			end
		end
	end
	
	if nutils.IsInTeamFight(bot) and GetUnitCountWithinRadius(bot.data.enemies, nRadius) >= 2 
	then
		if bot:HasScepter() then
			return BOT_ACTION_DESIRE_HIGH, "unit", bot;
		else
			return BOT_ACTION_DESIRE_HIGH, "", nil;
		end	
	end

	if ( mutils.IsDefending(bot) or mutils.IsPushing(bot) ) and mutils.CanSpamSpell(bot, manaCost) 
	   and bot:HasModifier("modifier_earthshaker_enchant_totem") == false and GetUnitCountWithinRadius(bot.data.e_creeps, nRadius) >= 3 
	then
		if bot:HasScepter() then
			return BOT_ACTION_DESIRE_HIGH, "unit", bot;
		else
			return BOT_ACTION_DESIRE_HIGH, "", nil;
		end	
	end
	
	if mutils.IsGoingOnSomeone(bot) and bot:HasModifier("modifier_earthshaker_enchant_totem") == false
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) 
		then
			if bot:HasScepter() == false and mutils.IsInRange(npcTarget, bot, nRadius) then
				return BOT_ACTION_DESIRE_HIGH, "", nil;
			elseif bot:HasScepter() then
				if mutils.IsInRange(npcTarget, bot, nRadius) == false and mutils.IsInRange(npcTarget, bot, nCastRange) then
					return BOT_ACTION_DESIRE_HIGH, "loc", npcTarget:GetLocation();
				elseif mutils.IsInRange(npcTarget, bot, nRadius) then
					return BOT_ACTION_DESIRE_HIGH, "unit", bot;				
				end
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, "", nil;
end

local function ConsiderR()
	
	if not mutils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE;
	end
	local nCastRange = 0;
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost   = abilities[3]:GetManaCost();
	local nRadius    = abilities[2]:GetSpecialValueInt( "aftershock_range" ) + 50;
	
	if nutils.IsInTeamFight(bot) and GetUnitCountWithinRadius(bot.data.enemies, nRadius) >= 2
	then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return BOT_ACTION_DESIRE_NONE;
end

function AbilityUsageThink()
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,5}) end
	if mutils.CantUseAbility(bot) then return end
	castQDesire, QLoc  			 = ConsiderQ();
	castWDesire, targetType, tgt = ConsiderW();
	castRDesire        			 = ConsiderR();
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	if castWDesire > 0 then
		if targetType == "loc" then
			bot:Action_UseAbilityOnLocation(abilities[2], tgt);
		elseif targetType == "unit" then
			bot:Action_UseAbilityOnEntity(abilities[2], tgt);
		else
			bot:Action_UseAbility(abilities[2]);
		end	
		return
	end
end