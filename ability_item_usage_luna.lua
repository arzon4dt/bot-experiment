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
local castSwapTime = DotaTime();
local ancient = GetAncient(GetTeam());
local eancient = GetAncient(GetOpposingTeam());
local castSwapForSaveCheck = DotaTime();
local castSwapForChanelling = DotaTime();

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, targetQ = ConsiderQ();
	-- castWDesire, targetW = ConsiderW();
	-- castEDesire, targetE  = ConsiderE();
	castRDesire, targetR, typeR = ConsiderR();
	
	if castRDesire > 0 then
		castSwapTime = DotaTime();
		if typeR == 'entity' then
			bot:Action_UseAbilityOnEntity( abilities[4], targetR );
		elseif typeR == 'loc' then
			bot:Action_UseAbilityOnLocation( abilities[4], targetR );
		else
			bot:Action_UseAbility( abilities[4] );
		end		
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], targetQ);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility( abilities[3] );
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	
	if mutils.CanBeCast(abilities[4]) and bot:GetMana() - manaCost <= abilities[4]:GetManaCost() + 50 then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and mutils.CanSpamSpell(bot, manaCost)  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( mutils.IsRoshan(npcTarget) and mutils.CanCastOnMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange) 
            and not mutils.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	if mutils.IsDefending(bot) and mutils.CanSpamSpell(bot, manaCost)
	then
		local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
		target = mutils.GetVulnerableWeakestUnit(false, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
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
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	local hitCount = abilities[4]:GetSpecialValueInt( "hit_count" );
	local nDamage = abilities[1]:GetSpecialValueInt( "beam_damage" );
	
	if bot:HasScepter() then
		hitCount = abilities[4]:GetSpecialValueInt( "hit_count_scepter" );
		local nTotalDamage = nDamage * hitCount;
		local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetSpecialValueInt('cast_range_tooltip_scepter'));
		
		if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local  enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			local  creeps = bot:GetNearbyCreeps(nRadius, true);
			if #enemies > 0 and #creeps <= 2 then
				return BOT_ACTION_DESIRE_HIGH, bot, 'entity';
			end
		end
		
		if mutils.IsInTeamFight(bot, 1300)
		then
			local nInvUnit = mutils.FindNumInvUnitInLoc(false, bot, nRadius, nRadius, bot:GetLocation());
			local creeps = bot:GetNearbyCreeps(nRadius, true);
			if mutils.IsGoingOnSomeone(bot) and nInvUnit >= 2 and #creeps <= 3 then
				return BOT_ACTION_DESIRE_HIGH, bot, 'entity';
			end
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
			if ( locationAoE.count >= 2 ) then
				local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), 'loc';
				end
			end
		end
		
		if mutils.IsGoingOnSomeone(bot)
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
				and mutils.IsInRange(target, bot, nCastRange) == true 
			then
				local nInvUnit = mutils.FindNumInvUnitInLoc(false, target, nRadius, nRadius, target:GetLocation());
				local  creeps = target:GetNearbyCreeps(nRadius, false);
				if nInvUnit >= 2 and #creeps <= 3 then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation(), 'loc';
				end
			end
		end
	else
		local nTotalDamage = nDamage * hitCount;
		if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
		then
			local  enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			local  creeps = bot:GetNearbyCreeps(nRadius, true);
			if #enemies > 0 and #creeps <= 2 then
				return BOT_ACTION_DESIRE_HIGH, nil, 'notarget';
			end
		end
		
		if mutils.IsGoingOnSomeone(bot)
		then
			local target = bot:GetTarget();
			if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
				and mutils.IsInRange(target, bot, nRadius) == true 
			then
				local  enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
				local  creeps = bot:GetNearbyCreeps(nRadius, true);
				if #enemies >= 2 and #creeps <= 2 then
					return BOT_ACTION_DESIRE_HIGH, nil, 'notarget';
				end
			end
		end
	end
	
	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	