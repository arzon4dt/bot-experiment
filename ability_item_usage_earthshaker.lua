if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local mutils = require(GetScriptDirectory() ..  "/MyUtility")
--local nutils = require(GetScriptDirectory() ..  "/NewUtility")

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end

local bot = GetBot();
--[[
"Ability1"		"earthshaker_fissure"
"Ability2"		"earthshaker_enchant_totem"
"Ability3"		"earthshaker_aftershock"
"Ability4"		"earthshaker_echo_slam"
]]--
local abilities = {};

local castQDesire = 0;
local castWDesire = 0;
local castRDesire = 0;

local function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt( "fissure_radius" );
	
	if mutils.IsRetreating(bot)
	then
		if bot.data.enemies ~= nil and #bot.data.enemies > 0 then
			for i=1,#bot.data.enemies do
				if bot.data.enemies[i] ~= nil and bot.data.enemies[i]:CanBeSeen() and bot:WasRecentlyDamagedByHero(bot.data.enemies[i],2.0) then
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
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local function ConsiderW()
	return BOT_ACTION_DESIRE_NONE;
end

local function ConsiderR()
	return BOT_ACTION_DESIRE_NONE;
end

function AbilityUsageThinks()
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,3}) end
	if mutils.CantUseAbility(bot) then return end
	castQDesire, QLoc  = ConsiderQ();
	castWDesire        = ConsiderW();
	castRDesire        = ConsiderR();
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end
end