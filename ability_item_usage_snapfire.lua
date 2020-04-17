if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
local abUtils = require(GetScriptDirectory() ..  "/AbilityItemUsageUtility")
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

local bot = GetBot();

local abilities = {};
local gobled_unit = nil;

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castDDesire = 0;
local castD2Desire = 0;
local castRDesire = 0;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = abUtils.InitiateAbilities(bot, {0,1,2,5,3,4}) end
	
	if abUtils.CantUseAbility(bot) then return end
	
	castQDesire, castQLoc = ConsiderQ();
	castWDesire, castWLoc = ConsiderW();
	castEDesire, ETarget  = ConsiderE();
	castDDesire, DTarget  = ConsiderD();
	castD2Desire, D2Target  = ConsiderD2();
	castRDesire, castRLoc = ConsiderR();
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[2], castWLoc);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[4], castRLoc);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], castQLoc);		
		return
	end
	
	if castEDesire > 0 then
		bot:Action_UseAbility(abilities[3]);		
		return
	end
	
	if castDDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[5], DTarget);		
		return
	end
	
	if castD2Desire > 0 then
		gobled_unit = nil;
		bot:Action_UseAbilityOnLocation(abilities[6], D2Target);		
		return
	end
	
end

function ConsiderQ()
	if not abUtils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	local castPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "blast_width_end" );
	local nRadius2   = abilities[1]:GetSpecialValueInt( "blast_width_initial" );
	local nDuration = 1
	local nSpeed    = abilities[1]:GetSpecialValueInt('blast_speed');
	local nDamage   = abilities[1]:GetSpecialValueInt('damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius2, 0, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius2, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderW()
	if not abUtils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[2]);
	local castPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nRadius   = abilities[2]:GetSpecialValueInt( "impact_radius" );
	local nDelay    = abilities[2]:GetSpecialValueFloat('self_cast_delay');
	local nDamage   = abilities[2]:GetSpecialValueInt('impact_damage');
	local nJumpDistance   = abilities[2]:GetSpecialValueInt('jump_horizontal_distance');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(nJumpDistance, true, BOT_MODE_NONE);
	local allies = bot:GetNearbyHeroes(castRange, false, BOT_MODE_NONE);

	for _,enemy in pairs(enemies)
	do
		if enemy:IsChanneling() and mutils.CanCastOnNonMagicImmune(enemy) and bot:IsFacingUnit(enemy, 10) then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	for i=1, #allies 
	do
		if allies[i] ~= bot 
			and mutils.CanCastOnNonMagicImmune(allies[i]) == true
			and allies[i]:WasRecentlyDamagedByAnyHero(3.0) == true
			and allies[i]:GetHealth() < 0.35 * allies[i]:GetMaxHealth() 
		then
			local loc = mutils.GetEscapeLoc2(allies[i]);
			local mode2 = allies[i]:GetActiveMode();
			if  ( mode2 == BOT_MODE_RETREAT  
				or allies[i]:GetAttackTarget() == nil 
				or allies[i]:GetTarget() == nil )
				and utils.IsFacingLocation(allies[i], loc, 15)
			then	
				return BOT_ACTION_DESIRE_HIGH, allies[i];
			end
		end
	end
	
	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) 
		then
			local loc = mutils.GetEscapeLoc2(bot);
			if  utils.IsFacingLocation(bot, loc, 15) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end	
	
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nJumpDistance, nRadius, nDelay+castPoint, 0 );
		local unitCount = abUtils.CountNotStunnedUnits(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) and utils.IsFacingLocation(bot, locationAoE.targetloc, 10)
		then
			return BOT_ACTION_DESIRE_LOW, bot;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, nJumpDistance+castRange) and not abUtils.IsDisabled(true, target)
		then
			local allies = bot:GetNearbyHeroes(castRange, false, BOT_MODE_ATTACK);
			for i=1, #allies do
				if mutils.IsValidTarget(allies[i])
					and mutils.CanCastOnNonMagicImmune(allies[i])
					and mutils.IsInRange(allies[i], target, 0.25*nJumpDistance) == false
					and mutils.IsInRange(allies[i], target, nJumpDistance) == true
					and allies[i]:IsFacingUnit(target, 15)
				then
					return BOT_ACTION_DESIRE_HIGH, allies[i];
				end	
			end
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderE()
	if not abUtils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nRange    = abilities[3]:GetSpecialValueInt( "attack_range_bonus" );
	local castRange = bot:GetAttackRange()+nRange-100;
	
	local target  = bot:GetTarget(); 
	local aTarget = bot:GetAttackTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if aTarget ~= nil and aTarget:IsBuilding() then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) 
	then
		local towers = bot:GetNearbyTowers(castRange, true);
		if #towers > 0 and towers[1] ~= nil and not towers[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_HIGH;
		end
		local barracks = bot:GetNearbyBarracks(castRange, true);
		if #barracks > 0 and barracks[1] ~= nil and not barracks[1]:IsInvulnerable() then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	if target ~= nil and target:GetUnitName() == "npc_dota_roshan" and abUtils.IsInRange(target, bot, 350)  then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderD()
	if not abUtils.CanBeCast(abilities[5]) or bot:HasScepter() == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[5]);
	local castRange2 = abUtils.GetProperCastRange(false, bot, abilities[6]);
	
	if abUtils.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if abUtils.IsValidTarget(target) 
			and abUtils.CanCastOnNonMagicImmune(target)
			and abUtils.IsInRange(target, bot, castRange2) 
		then
			local ecreeps = bot:GetNearbyLaneCreeps(castRange, true)
			local acreeps = bot:GetNearbyLaneCreeps(castRange, false)
			if #ecreeps ~= nil and #ecreeps > 0 and ecreeps[1] ~= nil then
				gobled_unit = 'creep'
				return BOT_ACTION_DESIRE_HIGH, ecreeps[1];
			end
			if #acreeps ~= nil and #acreeps > 0 and acreeps[1] ~= nil then
				gobled_unit = 'creep'
				return BOT_ACTION_DESIRE_HIGH, acreeps[1];
			end
		end	
	end

	local allies=bot:GetNearbyHeroes(castRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and abUtils.CanCastOnNonMagicImmune(allies[i]) == true
			and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
		then
			local mode2 = allies[i]:GetActiveMode();
			if  mode2 == BOT_MODE_RETREAT 
					or ( allies[i]:GetHealth() < 0.15 * allies[i]:GetMaxHealth() 
						and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) 
			then	
				gobled_unit = 'hero'
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i];
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderD2()
	if not abUtils.CanBeCast(abilities[6]) or bot:HasScepter() == false then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = 2500;
	local nRadius   = abilities[6]:GetSpecialValueInt( "impact_radius" );
	
	if abUtils.IsGoingOnSomeone(bot) and gobled_unit == 'creep'
	then
		local target  = bot:GetTarget(); 
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end

	if gobled_unit == 'hero' then
		local loc = mutils.GetEscapeLoc();
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, castRange );
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderR()
	if not abUtils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = 1500;
	local castPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "impact_radius" );
	local nDamage   = abilities[4]:GetSpecialValueInt('damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	
	if ( abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, castPoint, 0 );
		local unitCount = abUtils.CountVulnerableUnit(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange) 
		then
			local targetAllies = target:GetNearbyHeroes(2*nRadius, false, BOT_MODE_NONE);
			if #targetAllies >= 1 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			end
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

