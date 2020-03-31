if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )
local utils = require(GetScriptDirectory() ..  "/util")
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

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = abUtils.InitiateAbilities(bot, {0,1,2,5}) end
	
	if abUtils.CantUseAbility(bot) then return end
	
	castQDesire, castQLoc = ConsiderQ();
	castWDesire, castWLoc = ConsiderW();
	castEDesire, ETarget  = ConsiderE();
	castRDesire, castRLoc = ConsiderR();
	
	if castWDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[2], castWLoc);		
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
	
end

function ConsiderQ()
	if not abUtils.CanBeCast(abilities[1]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[1]);
	local castPoint = abilities[1]:GetCastPoint();
	local manaCost  = abilities[1]:GetManaCost();
	local nRadius   = abilities[1]:GetSpecialValueInt( "spear_width" );
	local nDuration = 1;
	local nSpeed    = abilities[1]:GetSpecialValueInt('spear_speed');
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
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, 0, 0 );
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
			return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, (GetUnitToUnitDistance(bot, target)/nSpeed)+castPoint );
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
	local nRadius   = abilities[2]:GetSpecialValueInt( "radius" );
	local nDamage   = bot:GetAttackDamage()*abilities[2]:GetSpecialValueInt('crit_mult')/100;
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if abUtils.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemy = abUtils.GetLowestHPUnit(enemies, false);
			if enemy ~= nil and not abUtils.IsDisabled(true, enemy) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
			end	
		end
	end	
	
	if ( abUtils.IsPushing(bot) or abUtils.IsDefending(bot) ) and abUtils.AllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if abUtils.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange-150, nRadius/2, castPoint, 0 );
		local unitCount = abUtils.CountNotStunnedUnits(enemies, locationAoE, nRadius, 2);
		if ( unitCount >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if abUtils.IsGoingOnSomeone(bot)
	then
		if abUtils.IsValidTarget(target) and abUtils.CanCastOnNonMagicImmune(target) and abUtils.IsInRange(target, bot, castRange-200) and not abUtils.IsDisabled(true, target)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function ConsiderE()
	if not abUtils.CanBeCast(abilities[3]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if abUtils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3.0) and abilities[3]:GetToggleState( ) == false
	then
		local allies = bot:GetNearbyHeroes(1300, false, BOT_MODE_ATTACK)
		if #allies > 1 then
			local num_facing = 0;
			local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
			for i=1, #enemies do
				if abUtils.IsValidTarget(enemies[i])
					and abUtils.CanCastOnMagicImmune(enemies[i])
					and bot:WasRecentlyDamagedByHero(enemies[i], 3.5)
					and bot:IsFacingLocation(enemies[i]:GetLocation(), 20) 
				then
					num_facing = num_facing + 1;
				end	
			end
			if num_facing >= 1 then
				return BOT_ACTION_DESIRE_HIGH, nil;
			end
		end
	end	
	
	if abUtils.IsGoingOnSomeone(bot) and abilities[3]:GetToggleState( ) == true then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
	if #enemies == 0 and abilities[3]:GetToggleState( ) == true then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


function ConsiderR()
	if not abUtils.CanBeCast(abilities[4]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local castRange = abUtils.GetProperCastRange(false, bot, abilities[4]);
	local castPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	local nRadius   = abilities[4]:GetSpecialValueInt( "radius" );
	local nDamage   = abilities[4]:GetSpecialValueInt('spear_damage');
	
	local target  = bot:GetTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	if abUtils.IsRetreating(bot)
	then
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if #enemies > 0 and  #tableNearbyAllyHeroes >= 2 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
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
			if #targetAllies >= 2 then
				return BOT_ACTION_DESIRE_HIGH, abUtils.GetProperLocation( target, castPoint );
			end
		end
	end

	
	return BOT_ACTION_DESIRE_NONE, nil;
end

