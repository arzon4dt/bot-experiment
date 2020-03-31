if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

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

local bot = GetBot();
--[[
"Ability1"		"dark_willow_bramble_maze"
"Ability2"		"dark_willow_shadow_realm"
"Ability3"		"dark_willow_cursed_crown"
"Ability4"		"dark_willow_bedlam"
"Ability5"		"dark_willow_terrorize"
]]--
local abilities = {};

local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire = 0;
local castR2Time = 0;

function AbilityUsageThink()
	
	if #abilities == 0 then abilities = mutils.InitiateAbilities(bot, {0,1,2,3,5}) end
	
	if mutils.CantUseAbility(bot) then return end
	
	castQDesire, QLoc    = ConsiderQ();
	castWDesire          = ConsiderW();
	castEDesire, ETarget = ConsiderE();
	castRDesire          = ConsiderR();
	castR2Desire, R2Loc  = ConsiderR2();
	
	if castWDesire > 0 then
		bot:Action_UseAbility(abilities[2]);		
		return
	end

	if castR2Desire > 0 then
		castR2Time = DotaTime();
		bot:Action_UseAbilityOnLocation(abilities[5], R2Loc);		
		return
	end
	
	if castRDesire > 0 then
		bot:Action_UseAbility(abilities[4]);		
		return
	end
	
	if castQDesire > 0 then
		bot:Action_UseAbilityOnLocation(abilities[1], QLoc);		
		return
	end
	
	
	if castEDesire > 0 then
		bot:Action_UseAbilityOnEntity(abilities[3], ETarget);		
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
	local nRadius   = abilities[1]:GetSpecialValueInt( "placement_range" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
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

function ConsiderW()
	if not mutils.CanBeCast(abilities[2]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = bot:GetAttackRange() + abilities[2]:GetSpecialValueInt("attack_range_bonus");
	local nCastPoint = abilities[2]:GetCastPoint();
	local manaCost  = abilities[2]:GetManaCost();
	local nDamage   = abilities[2]:GetSpecialValueInt( "damage" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,unit in pairs(tableNearbyEnemyHeroes) do
			if unit:GetAttackTarget() == bot then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) 
		   and mutils.IsInRange(npcTarget, bot, nCastRange/2) == false and mutils.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_HIGH;
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
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and mutils.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	if mutils.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( mutils.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	-- If we're going after someone
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end


function ConsiderR()
	if not mutils.CanBeCast(abilities[4]) or DotaTime() < castR2Time + 2.0 then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilities[4]:GetSpecialValueInt("attack_radius") + abilities[4]:GetSpecialValueInt("roaming_radius");
	local nCastPoint = abilities[4]:GetCastPoint();
	local manaCost  = abilities[4]:GetManaCost();
	
	
	if mutils.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsInTeamFight(bot, 1300)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if ( #tableNearbyEnemyHeroes > 0 ) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if mutils.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if mutils.IsValidTarget(npcTarget) and mutils.CanCastOnNonMagicImmune(npcTarget) and mutils.IsInRange(npcTarget, bot, nRadius) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function ConsiderR2()
	if not mutils.CanBeCast(abilities[5]) then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = mutils.GetProperCastRange(false, bot, abilities[1]:GetCastRange());
	local nCastPoint = abilities[5]:GetCastPoint();
	local manaCost  = abilities[5]:GetManaCost();
	local nRadius   = abilities[5]:GetSpecialValueInt( "destination_radius" );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if mutils.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes >= 2 ) 
		then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if mutils.IsInTeamFight(bot, 1200)
	then
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE );
		local nDisabledAllies = 0;
		for _,unit in pairs(tableNearbyAllyHeroes) do
			if mutils.IsDisabled(false, unit) then
				nDisabledAllies = nDisabledAllies + 1;
			end
		end
		if nDisabledAllies >= 2 then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end