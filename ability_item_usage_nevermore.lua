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

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nRadius    = abilities[1]:GetSpecialValueInt('shadowraze_radius') - 50;
	local nCastRange    = abilities[1]:GetSpecialValueInt('shadowraze_range');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
		or ( bot:GetActiveMode() == BOT_MODE_LANING and abilities[3]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+nRadius, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and bot:IsFacingLocation(enemies[i]:GetLocation(),10) 
				and GetUnitToUnitDistance(enemies[i], bot) > nCastRange - nRadius
				and GetUnitToUnitDistance(enemies[i], bot) < nCastRange + nRadius  
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange+nRadius, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and bot:IsFacingLocation(creeps[i]:GetLocation(),10) == true
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),10) 
			and GetUnitToUnitDistance(target, bot) > nCastRange - nRadius
			and GetUnitToUnitDistance(target, bot) < nCastRange + nRadius  
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
	local nRadius    = abilities[2]:GetSpecialValueInt('shadowraze_radius') - 50;
	local nCastRange    = abilities[2]:GetSpecialValueInt('shadowraze_range');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
		or ( bot:GetActiveMode() == BOT_MODE_LANING and abilities[3]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+nRadius, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and bot:IsFacingLocation(enemies[i]:GetLocation(),10) 
				and GetUnitToUnitDistance(enemies[i], bot) > nCastRange - nRadius
				and GetUnitToUnitDistance(enemies[i], bot) < nCastRange + nRadius  
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange+nRadius, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and bot:IsFacingLocation(creeps[i]:GetLocation(),10) == true
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),10) 
			and GetUnitToUnitDistance(target, bot) > nCastRange - nRadius
			and GetUnitToUnitDistance(target, bot) < nCastRange + nRadius  
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
	local nRadius    = abilities[3]:GetSpecialValueInt('shadowraze_radius') - 50;
	local nCastRange    = abilities[3]:GetSpecialValueInt('shadowraze_range');
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
		or ( bot:GetActiveMode() == BOT_MODE_LANING and abilities[3]:GetLevel() >= 2 and mutils.CanSpamSpell(bot, manaCost) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+nRadius, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and bot:IsFacingLocation(enemies[i]:GetLocation(),10) 
				and GetUnitToUnitDistance(enemies[i], bot) > nCastRange - nRadius
				and GetUnitToUnitDistance(enemies[i], bot) < nCastRange + nRadius  
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange+nRadius, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and bot:IsFacingLocation(creeps[i]:GetLocation(),10) == true
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),10) 
			and GetUnitToUnitDistance(target, bot) > nCastRange - nRadius
			and GetUnitToUnitDistance(target, bot) < nCastRange + nRadius  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilities[4]:GetSpecialValueInt('requiem_radius');
	local max_soul = abilities[5]:GetSpecialValueInt('necromastery_max_souls');
	local soul = bot:GetModifierStackCount(bot:GetModifierByName('modifier_nevermore_necromastery'));
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) and soul >= 0.5*max_soul )
	then
		local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK);
		local enemies = bot:GetNearbyHeroes(0.75*nRadius, true, BOT_MODE_NONE);
		if #allies >= #enemies and #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) and soul >= 0.5*max_soul then
		local enemies = bot:GetNearbyHeroes(0.75*nRadius, true, BOT_MODE_NONE);
		if #enemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and soul >= 0.5*max_soul
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
		then
			local enemies = bot:GetNearbyHeroes(0.75*nRadius, true, BOT_MODE_NONE);
			if #enemies >= 2 then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire		  	 = ConsiderQ();
	castWDesire			 = ConsiderW();
	castEDesire			 = ConsiderE();
	castRDesire	         = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbility(abilities[1]);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbility(abilities[2]);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
end