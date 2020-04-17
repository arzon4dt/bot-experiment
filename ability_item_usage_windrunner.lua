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
	local nRadius    = abilities[1]:GetSpecialValueInt('shackle_distance') - 125;
	local nCastRange    = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		for i=1, #enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
				and mutils.IsDisabled(true, enemies[i]) == false
			then	
				local starget = mutils.GetShackleTarget(bot, enemies[i], nRadius, GetUnitToUnitDistance(enemies[i], bot))
				if starget ~= nil then
					return BOT_ACTION_DESIRE_MODERATE, starget;
				end
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange+nRadius)
			and mutils.IsDisabled(true, target) == false
		then
			local starget = mutils.GetShackleTarget(bot, target, nRadius, GetUnitToUnitDistance(target, bot))
			if starget ~= nil then
				return BOT_ACTION_DESIRE_MODERATE, starget;
			end
		end
	end
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	for i=1, #enemies do
		if mutils.IsValidTarget(enemies[i]) == true 
			and mutils.CanCastOnNonMagicImmune(enemies[i]) == true 
			and ( enemies[i]:IsChanneling()
			or enemies[i]:HasModifier('modifier_teleporting') )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i];
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
	local nRadius    = abilities[2]:GetSpecialValueInt('arrow_width');
	local speed    = abilities[2]:GetSpecialValueInt('arrow_speed');
	local nCastRange    = 1600;
	local nCastRange2    = 2600;
	local nAttackRange    = bot:GetAttackRange();
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE, creeps[i]:GetLocation();
				end	
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and GetUnitToLocationDistance(bot,  locationAoE.targetloc) > 0.5*nAttackRange ) then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, 0.5*nAttackRange) == false
			and mutils.IsInRange(bot, target, nCastRange2-600) == true
		then
			local distance = GetUnitToUnitDistance(target, bot)
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

local function ConsiderE()
	if  mutils.CanBeCast(abilities[3]) == false or bot:HasModifier('modifier_windrunner_windrun') == true then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = bot:GetAttackRange();
	
	if ( mutils.IsRetreating(bot) and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) ) )
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnMagicImmune(target) 
		then
			local enemies = target:GetNearbyHeroes(800, false, BOT_MODE_NONE);
			local allies = target:GetNearbyHeroes(800, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutils.IsValidTarget(enemies[i])
					and mutils.CanCastOnMagicImmune(enemies[i])
					and mutils.IsInRange(bot, enemies[i], 600)
					and ( enemies[i]:GetAttackTarget() == bot or enemies[i]:GetTarget() == bot )
					and enemies[i]:IsFacingLocation(bot:GetLocation(), 10) 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end	
			end
			
			if  mutils.IsInRange(target, bot, 1.25*nCastRange) == false
				and mutils.IsInRange(target, bot, 2*nCastRange) == true
				and enemies ~= nil and allies ~= nil and  #enemies < #allies 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

local function ConsiderR()
	if  mutils.CanBeCast(abilities[4]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange    = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nBonusAttackSpeed = abilities[4]:GetSpecialValueInt('bonus_attack_speed');
	local nDamageReduction = abilities[4]:GetSpecialValueInt('focusfire_damage_reduction');
	local nDamage = bot:GetAttackDamage();
	
	if ( mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
		and  ( mutils.CanBeCast(abilities[3]) == true or bot:HasModifier('modifier_windrunner_windrun') ) )
	then
		local enemies = bot:GetNearbyHeroes(0.65*nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemies do
			if mutils.IsValidTarget(enemies[i])
				and mutils.CanCastOnMagicImmune(enemies[i])
				and enemies[i]:GetAttackRange() < 325
				and ( enemies[i]:GetAttackTarget() == bot or enemies[i]:GetTarget() == bot
				or enemies[i]:IsFacingLocation(bot:GetLocation(), 10) )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i];
			end	
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(bot, target, nCastRange) 
			and target:GetHealth() > 0.25*target:GetMaxHealth() 
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function AbilityUsageThink()
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castEDesire          = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_ClearActions(true);
		bot:Action_UseAbilityOnLocation(abilities[2], wTarget);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], rTarget);		
		return
	end
	
end