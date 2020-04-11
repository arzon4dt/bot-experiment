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

local function GetAllyToSave(unit, nCastRange)
	local allies=unit:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= unit:GetUnitName() 
			and mutils.CanCastOnNonMagicImmune(allies[i]) == true
			and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
			and allies[i]:GetHealth() < 0.25 * allies[i]:GetMaxHealth() 
		then
			local mode2 = allies[i]:GetActiveMode();
			if  mode2 == BOT_MODE_RETREAT  
				or allies[i]:GetAttackTarget() == nil 
				or allies[i]:GetTarget() == nil 
			then	
				return allies[i];
			end
		end
	end
	return nil;
end

local function ConsiderQ()
	if  mutils.CanBeCast(abilities[1]) == false then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost   = abilities[1]:GetManaCost();
	local nDamage   = abilities[1]:GetSpecialValueInt('damage');
	local nRadius    = abilities[1]:GetSpecialValueInt('radius');
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if ( mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) )
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		for i=1,#enemies do
			if mutils.IsValidTarget(enemies[i]) 
				and mutils.CanCastOnNonMagicImmune(enemies[i]) 
			then
				return BOT_ACTION_DESIRE_MODERATE, bot, 0.5;
			end
		end
		if bot:GetCurrentMovementSpeed() < bot:GetBaseMovementSpeed() then
			return BOT_ACTION_DESIRE_MODERATE, bot, 0.1;
		end
		if #enemies == 0 then
			local enemies2 = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK);
			if #enemies2 <= #allies then 
				local target = mutils.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
				if target ~= nil then
					return BOT_ACTION_DESIRE_HIGH, target, 1.0;
				end
			end	
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and  mutils.CanSpamSpell(bot, manaCost) 
	then
		local creeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		for i=1, #creeps do
			if creeps[i] ~= nil 
				and CanCastOnCreep(creeps[i]) == true
			then	
				local n_creeps = GetNumEnemyCreepsAroundTarget(creeps[i], false, nRadius)
				if n_creeps >= 3 then
					return BOT_ACTION_DESIRE_MODERATE, creeps[i], 0.2;
				end	
			end
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and mutils.IsInRange(target, bot, nCastRange)
		then
			if mutils.CanKillTarget(target, nDamage, DAMAGE_TYPE_MAGICAL) == true or target:IsChanneling() then
				return BOT_ACTION_DESIRE_MODERATE, target, 0.1;
			elseif target:HasModifier('modifier_oracle_purifying_flames') == true then	
				return BOT_ACTION_DESIRE_MODERATE, target, 0.1;
			end
			local dist = GetUnitToUnitDistance(target, bot);
			if dist > 0.5*nCastRange then
				dist = 0.5*nCastRange;
			end
			return BOT_ACTION_DESIRE_MODERATE, target,  (dist/(0.5*nCastRange)) * 2.5;
		end
	end
	
	local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and mutils.CanCastOnNonMagicImmune(allies[i]) == true
			and mutils.IsDisabled(false, allies[i]) == true
		then
			return BOT_ACTION_DESIRE_MODERATE, allies[i], 0.1;
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
	local manaCostE   = abilities[3]:GetManaCost();
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
		and bot:GetHealth() < 0.5* bot:GetMaxHealth()
		and mutils.CanCastOnNonMagicImmune(bot) == true
		and mutils.CanBeCast(abilities[3]) == true
		and bot:GetMana() > manaCost + manaCostE
	then
		local enemies=bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
		if #enemies == 1 and enemies[1]~=nil and mutils.CanCastOnNonMagicImmune(enemies[1]) == true then
			return BOT_ACTION_DESIRE_MODERATE, enemies[1];
		end
		return BOT_ACTION_DESIRE_MODERATE, bot;
	end
	
	local enemies=bot:GetNearbyHeroes(1300,true,BOT_MODE_NONE); 
	
	local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and mutils.CanCastOnNonMagicImmune(allies[i]) == true
			and ( allies[i]:HasModifier('modifier_oracle_false_promise_timer') == true 
				or ( #enemies == 0 
					and allies[i]:GetHealth() < 0.5*allies[i]:GetMaxHealth() 
					and mutils.CanBeCast(abilities[3]) == true and bot:GetMana() > manaCost + manaCostE ) )
		then
			return BOT_ACTION_DESIRE_MODERATE, allies[i];
		end
	end
	
	if #enemies == 0 
		and bot:GetHealth() < 0.5*bot:GetMaxHealth()
		and mutils.CanBeCast(abilities[3]) == true 
		and bot:GetMana() > manaCost + manaCostE	
	then
		return BOT_ACTION_DESIRE_MODERATE, bot;
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.IsInRange(target, bot, nCastRange)
			and mutils.CanCastOnNonMagicImmune(target) 
			and target:IsFacingLocation(bot:GetLocation(),10) 
			and ( target:GetAttackTarget() == bot or target:GetTarget() == bot ) 	
		then
			return BOT_ACTION_DESIRE_MODERATE, target;
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
	local nCastRange2 = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	
	if  ( bot:HasModifier('modifier_oracle_fates_edict') 
			or bot:HasModifier('modifier_oracle_false_promise_timer') )
		and mutils.CanCastOnNonMagicImmune(bot) == true	
	then
		return BOT_ACTION_DESIRE_MODERATE, bot;
	end
	
	local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		-- print(allies[i]:GetUnitName()..tostring(mutils.CanCastOnNonMagicImmune(allies[i]))..tostring(allies[i]:HasModifier('modifier_oracle_fates_edict'))..tostring(allies[i]:HasModifier('modifier_oracle_false_promise')))
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and mutils.IsValidTarget(allies[i])
			and mutils.CanCastOnNonMagicImmune(allies[i]) == true
			and ( allies[i]:HasModifier('modifier_oracle_fates_edict') 
				or allies[i]:HasModifier('modifier_oracle_false_promise_timer') )
		then
			return BOT_ACTION_DESIRE_MODERATE, allies[i];
		end
	end
	
	local enemies=bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	for i=1, #enemies do
		if mutils.IsValidTarget(enemies[i]) 
			and mutils.CanCastOnNonMagicImmune(enemies[i]) == true
			and enemies[i]:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL) > enemies[i]:GetHealth()
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i];
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) 
			and mutils.CanCastOnNonMagicImmune(target) 
			and bot:IsFacingLocation(target:GetLocation(),10) 
			and mutils.IsInRange(target, bot, nCastRange2-200)
			and mutils.CanBeCast(abilities[1]) == true
			and target:HasModifier('modifier_oracle_fates_edict') == false
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
	
	if  mutils.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(4.0) 
		and bot:GetHealth() < 0.25* bot:GetMaxHealth()
		and mutils.CanCastOnNonMagicImmune(bot) == true
	then
		return BOT_ACTION_DESIRE_MODERATE, bot;
	end
	
	local ally_to_save = GetAllyToSave(bot, nCastRange);
	if ally_to_save ~= nil then
		return BOT_ACTION_DESIRE_MODERATE, ally_to_save;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

local IsCastingQ = false;
local castQTime = -90;
local chTime = 0;

function AbilityUsageThink()
	
	if IsCastingQ == true then
		if DotaTime() > castQTime + chTime or bot:IsAlive() == false then
			bot:Action_ClearActions(true);
			IsCastingQ = false;
			return
		end
		if bot:GetHealth() < 0.25 * bot:GetMaxHealth() then
			local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
			for i=1, #enemies do
				if mutils.IsValidTarget(enemies[i])
					and ( enemies[i]:GetAttackTarget() == bot or enemies[i]:GetTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 10) )
				then
					bot:Action_ClearActions(true);
					IsCastingQ = false;
					return
				end	
			end
		end
		local ally_to_save = GetAllyToSave(bot, 1000);
		if ally_to_save ~= nil then
			bot:Action_ClearActions(true);
			IsCastingQ = false;
			return
		end
	end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, qTarget, cTime = ConsiderQ();
	castWDesire, wTarget = ConsiderW();
	castEDesire, eTarget = ConsiderE();
	castRDesire, rTarget = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], rTarget);	
		return
	end
	
	if castQDesire > 0 then	
		bot:Action_UseAbilityOnEntity(abilities[1], qTarget);
		IsCastingQ = true;
		castQTime = DotaTime();	
		chTime = cTime;
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], wTarget);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[3], eTarget);		
		return
	end
	
end