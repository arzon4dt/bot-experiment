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

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,3,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, targetQ = ConsiderQ();
	castWDesire, targetW = ConsiderW();
	castEDesire, targetE  = ConsiderE();
	castRDesire, targetR = ConsiderR();
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[4], targetR);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbility(abilities[1]);		
		return
	end
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], targetW);		
		return
	end
	
	if castEDesire > 0 then
		local typeAOE = mutils.CheckFlag(abilities[3]:GetBehavior(), ABILITY_BEHAVIOR_POINT);
		if typeAOE == true then
			bot:Action_UseAbilityOnLocation( abilities[3], targetE:GetLocation() );
		else
			bot:Action_UseAbilityOnEntity( abilities[3], targetE );
		end	
		return
	end
	
end

function ConsiderQ()
	if not mutils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "blade_fury_radius" );
	local nDuration   = abilities[1]:GetSpecialValueFloat( "duration" );
	local nDamage   = abilities[1]:GetSpecialValueInt( "blade_fury_damage" );
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		local incProj = bot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(bot, p.location) <= 350 and p.is_attack == false then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		local enemy = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemy > 0 then
		    return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if ( mutils.IsPushing(bot) or mutils.IsDefending(bot) ) and mutils.CanSpamSpell(bot, manaCost)
	then
		local enemy = bot:GetNearbyLaneCreeps(nRadius, true);
		if #enemy >= 4 then
		    return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300) 
	then
		local enemy = bot:GetNearbyHeroes(2*nRadius, true, BOT_MODE_NONE);
		local nAEnemy = 0;
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and bot:WasRecentlyDamagedByHero(enemy[i], 2.0)
			then
				nAEnemy = nAEnemy + 1;
			end
		end
		if nAEnemy >= 2 then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) 
		then
			local incProj = bot:GetIncomingTrackingProjectiles()
			for _,p in pairs(incProj)
			do
				if GetUnitToLocationDistance(bot, p.location) <= 350 and p.is_attack == false then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end
			if mutils.IsInRange(target, bot, nRadius) and target:GetHealth() <= nDuration * nDamage then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[2]:GetCastRange());
	local nCastRange2 = bot:GetAttackRange();
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "healing_ward_aura_radius" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(5.0) and bot:GetHealth() <= 0.45 * bot:GetMaxHealth()
	then
		return BOT_ACTION_DESIRE_LOW, bot:GetLocation()+RandomVector(200);
	end
	
	if mutils.IsInTeamFight(bot, 1300) 
	then
		local ally = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
		local nLowHP = 0;
		for i=1, #ally do
			if ally[i]:GetHealth() <= 0.5 * ally[i]:GetMaxHealth() then
				nLowHP = nLowHP + 1;
			end
		end
		if nLowHP >=2 then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation()+RandomVector(200);
		end
	end
	
	if mutils.IsGoingOnSomeone(bot) and bot:GetHealth() <= 0.45 * bot:GetMaxHealth()
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.IsInRange(target, bot, 3*nCastRange2)
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()+RandomVector(200);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end	

function ConsiderE()
	if not mutils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[3]:GetCastRange());
	local nCastPoint = abilities[3]:GetCastPoint();
	local manaCost  = abilities[3]:GetManaCost();
	local manaCost2  = abilities[1]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "omni_slash_radius" );
	local nDuration = abilities[3]:GetSpecialValueFloat( "duration" );
	local nRate = abilities[4]:GetSpecialValueFloat( "attack_rate_multiplier" );
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = nAttackDamage + abilities[4]:GetSpecialValueFloat( "bonus_damage" );
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) and bot:GetHealth() < 0.35*bot:GetMaxHealth()
		and bot:GetMana() >= manaCost + manaCost2 and abilities[1]:GetCooldownTimeRemaining() <= nDuration
	then
		local enemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and mutils.CanCastOnNonMagicImmune(enemy[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, enemy[i];
			end
		end
	end
	
	-- if mutils.IsInTeamFight(bot, 1300)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		-- if ( locationAoE.count >= 2 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target;
			-- end
		-- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local attr = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
			local aps = (((100+attr)*0.01)/1.7)*nRate;
			local nTotalDamage = nDuration * aps * nDamage;
			
			--print(tostring(abilities[4]:GetEstimatedDamageToTarget(target, nDuration, DAMAGE_TYPE_PHYSICAL)))
			local enemies = target:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target;
			else
				if target:GetHealth() > 0.25*nTotalDamage and target:GetHealth() < nTotalDamage then
					return BOT_ACTION_DESIRE_HIGH, target;
				end	
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end		

function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[4]:GetCastRange());
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local manaCost2  = abilities[1]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "omni_slash_radius" );
	local nDuration = abilities[4]:GetSpecialValueFloat( "duration" );
	local nRate = abilities[4]:GetSpecialValueFloat( "attack_rate_multiplier" );
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = nAttackDamage + abilities[4]:GetSpecialValueFloat( "bonus_damage" );
	
	-- if bot:HasScepter() then
		-- nDuration = abilities[4]:GetSpecialValueFloat( "duration_scepter" );
	-- end
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0) and bot:GetHealth() < 0.45*bot:GetMaxHealth()
		and bot:GetMana() >= manaCost + manaCost2 and abilities[1]:GetCooldownTimeRemaining() <= nDuration
	then
		local enemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		for i=1, #enemy do
			if mutils.IsValidTarget(enemy[i]) and mutils.CanCastOnNonMagicImmune(enemy[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, enemy[i];
			end
		end
	end
	
	-- if mutils.IsInTeamFight(bot, 1300)
	-- then
		-- local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		-- if ( locationAoE.count >= 2 ) then
			-- local target = mutils.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			-- if target ~= nil then
				-- return BOT_ACTION_DESIRE_HIGH, target;
			-- end
		-- end
	-- end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutils.IsValidTarget(target) and mutils.CanCastOnNonMagicImmune(target) and mutils.IsInRange(target, bot, nCastRange)
		then
			local attr = bot:GetAttributeValue(ATTRIBUTE_AGILITY);
			local aps = (((100+attr)*0.01)/1.7)*nRate;
			local nTotalDamage = nDuration * aps * nDamage;
			
			--print(tostring(abilities[4]:GetEstimatedDamageToTarget(target, nDuration, DAMAGE_TYPE_PHYSICAL)))
			local enemies = target:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			local nInvUnit = mutils.CountInvUnits(false, enemies);
			if nInvUnit >= 2 then
				return BOT_ACTION_DESIRE_HIGH, target;
			else
				if target:GetHealth() > 0.3*nTotalDamage and target:GetHealth() < nTotalDamage then
					return BOT_ACTION_DESIRE_HIGH, target;
				end	
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end
	