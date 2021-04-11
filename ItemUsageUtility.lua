local mutil = require(GetScriptDirectory() ..  "/MyUtility");
local utils = require(GetScriptDirectory() ..  "/util");
local role = require(GetScriptDirectory() .. "/RoleUtility");

ItemUsageModule = {}

ItemUsageModule.Use = {};

local myTeam = GetTeam();
local opTeam = GetOpposingTeam();

local RadiantFountain = Vector(-7166.000000, -6659.000000, 0.000000);
local DireFountain = Vector(7024.000000, 6448.000000, 0.000000);

local giveTime = -90;

local teamT1Top = nil;
local teamT1Mid = nil;
local teamT1Bot = nil;
local enemyT1Top = nil;
local enemyT1Mid = nil;
local enemyT1Bot = nil;

if myTeam == TEAM_DIRE then
	teamT1Top = GetTower(myTeam,TOWER_TOP_1) == nil and Vector(-4693, 5998) or GetTower(myTeam,TOWER_TOP_1):GetLocation();
	teamT1Mid = GetTower(myTeam,TOWER_MID_1) == nil and Vector(530, 657) or GetTower(myTeam,TOWER_MID_1):GetLocation();
	teamT1Bot = GetTower(myTeam,TOWER_BOT_1) == nil and Vector(6262, -1687) or GetTower(myTeam,TOWER_BOT_1):GetLocation();
	enemyT1Top = GetTower(opTeam,TOWER_TOP_1) == nil and Vector(-6262, 1815) or GetTower(opTeam,TOWER_TOP_1):GetLocation();
	enemyT1Mid = GetTower(opTeam,TOWER_MID_1) == nil and Vector(-1530, -1412) or GetTower(opTeam,TOWER_MID_1):GetLocation();
	enemyT1Bot = GetTower(opTeam,TOWER_BOT_1) == nil and Vector(4949, -6130) or GetTower(opTeam,TOWER_BOT_1):GetLocation();
else
	teamT1Top = GetTower(myTeam,TOWER_TOP_1) == nil and Vector(-6262, 1815) or GetTower(myTeam,TOWER_TOP_1):GetLocation();
	teamT1Mid = GetTower(myTeam,TOWER_MID_1) == nil and Vector(-1530, -1412) or GetTower(myTeam,TOWER_MID_1):GetLocation();
	teamT1Bot = GetTower(myTeam,TOWER_BOT_1) == nil and Vector(4949, -6130) or GetTower(myTeam,TOWER_BOT_1):GetLocation();
	enemyT1Top = GetTower(opTeam,TOWER_TOP_1) == nil and Vector(-4693, 5998) or GetTower(opTeam,TOWER_TOP_1):GetLocation();
	enemyT1Mid = GetTower(opTeam,TOWER_MID_1) == nil and Vector(530, 657) or GetTower(opTeam,TOWER_MID_1):GetLocation();
	enemyT1Bot = GetTower(opTeam,TOWER_BOT_1) == nil and Vector(6262, -1687) or GetTower(opTeam,TOWER_BOT_1):GetLocation();
end

function ItemUsageModule.IsHPHealing(bot)
	return bot:HasModifier('modifier_flask_healing') 
		or bot:HasModifier('modifier_tango_heal') 
		or bot:HasModifier('modifier_fountain_aura') 
		or bot:HasModifier("modifier_filler_heal")
		or bot:HasModifier("modifier_item_urn_heal")
		or bot:HasModifier("modifier_item_spirit_vessel_heal")
		or bot:HasModifier("modifier_bottle_regeneration")
end

function ItemUsageModule.IsManaHealing(bot)
	return bot:HasModifier('modifier_clarity_potion') 
		or bot:HasModifier('modifier_fountain_aura') 
end

function ItemUsageModule.IsForceStafed(target)
	return target:HasModifier('modifier_item_forcestaff_active') == true 
		or target:HasModifier('modifier_item_hurricane_pike_active') == true 
		or target:HasModifier('modifier_item_hurricane_pike_active_alternate') == true 
		or target:HasModifier('modifier_force_boots_active') == true 
end

function ItemUsageModule.CanCastItem(item)
	return item~=nil and item:IsFullyCastable(); 
end 

function ItemUsageModule.CanDodgeProjectile(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_dodgeable 
			and p.is_attack == false
			and GetUnitToLocationDistance(bot, p.location) <= range 
		then
			return true;
		end
	end
	return false;
end

function ItemUsageModule.CanSwitchPTStat(bot, pt)
	local pt_stat = pt:GetPowerTreadsStat();
	if bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and pt_stat ~= ATTRIBUTE_STRENGTH then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY  and pt_stat ~= ATTRIBUTE_INTELLECT then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and pt_stat ~= ATTRIBUTE_AGILITY then
		return true;
	end 
	return false;
end

function ItemUsageModule.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function ItemUsageModule.HasInvisCounterBuff(bot)
	return bot:HasModifier('modifier_item_dustofappearance') == true
		or bot:HasModifier('modifier_bounty_hunter_track') == true
		or bot:HasModifier('modifier_slardar_amplify_damage') == true
end

function ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange)

	local units = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local strongest_unit = nil;
	local maxPower = 0;
	for i=1, #units do
		if mutil.IsValidTarget(units[i]) == true
		   and mutil.CanCastOnNonMagicImmune(units[i]) == true 
		   and mutil.IsDisabled(true, units[i]) == false
		then
			local power = units[i]:GetEstimatedDamageToTarget( true, bot, 3.0, DAMAGE_TYPE_ALL );
			if power > maxPower then
				maxPower = power;
				strongest_unit = units[i];
			end
		end
	end
		
	return strongest_unit;

end

local enemyPids = nil;
local tpThreshold = 4500;

function ItemUsageModule.GetDefendTPLocation(nLane)
	return GetLaneFrontLocation(opTeam,nLane,-1600)
end

function ItemUsageModule.GetPushTPLocation(nLane)
	return GetLaneFrontLocation(myTeam,nLane,0)
end

function ItemUsageModule.CanJuke(bot)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	local heroHG = GetHeightLevel(bot:GetLocation())
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.5  
				and GetUnitToLocationDistance(bot,dInfo.location) < 1500 
				and GetHeightLevel(dInfo.location) <= heroHG + 1   
			then
				return false;
			end
		end	
	end
	return true;
end	

function ItemUsageModule.GetLaningTPLocation(nLane)
	if nLane == LANE_TOP then
		return teamT1Top
	elseif nLane == LANE_MID then
		return teamT1Mid
	elseif nLane == LANE_BOT then
		return teamT1Bot			
	end	
	return teamT1Mid
end	

function ItemUsageModule.GetNumHeroWithinRange(bot, nRange)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	local cHeroes = 0;
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  
				and GetUnitToLocationDistance(bot,dInfo.location) < nRange 
			then
				cHeroes = cHeroes + 1;
			end
		end	
	end
	return cHeroes;
end	

function ItemUsageModule.ShouldTP(bot)
    local stuckTP = false;
	local tpLoc = nil;
	local mode = bot:GetActiveMode();
	local modDesire = bot:GetActiveModeDesire();
	local botLoc = bot:GetLocation();
	local enemies = ItemUsageModule.GetNumHeroWithinRange(bot, 1600);
	if mutil.IsStuck(bot) and enemies == 0 then
		bot:ActionImmediate_Chat("I'm using tp while stuck.", true);
		tpLoc = GetAncient(GetTeam()):GetLocation()
	elseif mode == BOT_MODE_LANING and enemies == 0 then
		local assignedLane = bot:GetAssignedLane();
		if assignedLane == LANE_TOP  then
			local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = ItemUsageModule.GetLaningTPLocation(LANE_TOP)
			end	
		elseif assignedLane == LANE_MID then
			local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = ItemUsageModule.GetLaningTPLocation(LANE_MID)
			end	
		elseif assignedLane == LANE_BOT then
			local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = ItemUsageModule.GetLaningTPLocation(LANE_BOT)
			end	
		end
	elseif mode == BOT_MODE_DEFEND_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetDefendTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetDefendTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then	
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetDefendTPLocation(LANE_BOT)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetPushTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetPushTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = ItemUsageModule.GetPushTPLocation(LANE_BOT)
		end	
	elseif mode == BOT_MODE_DEFEND_ALLY and modDesire >= BOT_MODE_DESIRE_MODERATE and role.CanBeSupport(bot:GetUnitName()) == true and enemies == 0 then
		local target = bot:GetTarget()
		if target ~= nil and target:IsHero() then
			local nearbyTower = target:GetNearbyTowers(1300, true)
			if nearbyTower ~= nil and #nearbyTower > 0 and bot:GetMana() >  0.25*bot:GetMaxMana()  then
				tpLoc = nearbyTower[1]:GetLocation()
			end
		end
	elseif mode == BOT_MODE_RETREAT and modDesire >= BOT_MODE_DESIRE_HIGH 
	then
		if bot:GetHealth() < 0.15*bot:GetMaxHealth() and bot:WasRecentlyDamagedByAnyHero(2.0) and enemies == 0 then
			tpLoc = mutil.GetTeamFountain();
		elseif bot:GetHealth() < 0.25*bot:GetMaxHealth() and bot:WasRecentlyDamagedByAnyHero(3.0) and ItemUsageModule.CanJuke(bot) == true then
			-- print(bot:GetUnitName().." JUKE TP")
			tpLoc = mutil.GetTeamFountain();	
		end
	elseif bot:HasModifier('modifier_bloodseeker_rupture') and enemies <= 1 then
		local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
		if #allies <= 1 then
			tpLoc = mutil.GetTeamFountain();
		end
	end	
	if ( stuckTP == true and tpLoc ~= nil ) or ( stuckTP == false and tpLoc ~= nil and GetUnitToLocationDistance(bot, tpLoc) > 2000 ) then
		return true, tpLoc;
	end
	return false, nil;
end

function ItemUsageModule.GetItemCount(unit, item_name)
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end

function ItemUsageModule.GiveToMidLaner(bot)
	local teamPlayers = GetTeamPlayers(GetTeam())
	local target = nil;
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and member ~= bot and not member:IsIllusion() and member:IsAlive() then
			local num_stg = ItemUsageModule.GetItemCount(member, "item_tango_single"); 
			local num_ff = ItemUsageModule.GetItemCount(member, "item_faerie_fire"); 
			if num_ff > 0 and num_stg < 2 then
				return member;
			end
		end
	end
	return nil;
end

function ItemUsageModule.IsInventoryFull(bot)
	for i = 6, 8 do
		local item = bot:GetItemInSlot(i);
		if item == nil then
			return false;
		end	
	end	
	return true;
end

function ItemUsageModule.IsUnitWillGoInvisible(unit)
	return unit:HasModifier('modifier_sandking_sand_storm') == true
		or unit:HasModifier('modifier_bounty_hunter_wind_walk') == true
		or unit:HasModifier('modifier_clinkz_wind_walk') == true
		or unit:HasModifier('modifier_weaver_shukuchi') == true
		or ( unit:HasModifier('modifier_oracle_false_promise') == true and unit:HasModifier('modifier_oracle_false_promise_invis') == true )
		or ( unit:HasModifier('modifier_windrunner_windrun') == true and unit:HasModifier('modifier_windrunner_windrun_invis') == true )
		or unit:HasModifier('modifier_item_invisibility_edge') == true
		or unit:HasModifier('modifier_item_invisibility_edge_windwalk') == true
		or unit:HasModifier('modifier_item_silver_edge') == true
		or unit:HasModifier('modifier_item_silver_edge_windwalk') == true
		or unit:HasModifier('modifier_item_glimmer_cape_fade') == true
		or unit:HasModifier('modifier_item_glimmer_cape') == true
		or unit:HasModifier('modifier_item_shadow_amulet') == true
		or unit:HasModifier('modifier_item_shadow_amulet_fade') == true
		
end

function ItemUsageModule.GetXUnitsTowardsLocation( iLoc, tLoc, nUnits)
    local direction = (tLoc - iLoc):Normalized()
    return iLoc + direction * nUnits;
end

local allyPids = nil;
function ItemUsageModule.IsClosestToDustLocation(bot, loc)
	if allyPids == nil then
		allyPids = GetTeamPlayers(myTeam)
	end	
	local closest = nil;
	local closest_dist = 100000;
	for i=1, #allyPids
	do
		local member = GetTeamMember(allyPids[i]);
		if member ~= nil 
			and not member:IsIllusion() 
			and member:IsAlive() 
			and member:GetItemSlotType(member:FindItemSlot('item_dust')) == ITEM_SLOT_TYPE_MAIN
			and member:GetItemInSlot(member:FindItemSlot('item_dust')):IsFullyCastable() == true
		then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist <= closest_dist then
				closest = member;
				closest_dist = dist;
			end
		end
	end
	return closest == bot;
end

-------ITEM USAGE---------
local enemyPids = nil;
local castDustTime = -90;
--item_dust
ItemUsageModule.Use['item_dust'] = function(item, bot, mode, extra_range)
	
	-- if DotaTime() < castDustTime + 0.5 then return BOT_ACTION_DESIRE_NONE end
	
	local nRadius = 1050;
	
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if IsHeroAlive(enemyPids[i]) == true and info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil 
				and dInfo.time_since_seen > 0.20 
				and dInfo.time_since_seen < 0.50 
				and GetUnitToLocationDistance(bot, dInfo.location) + 150 <  nRadius 
				and ItemUsageModule.IsClosestToDustLocation(bot, dInfo.location)
			then	
				local front_loc = ItemUsageModule.GetXUnitsTowardsLocation( dInfo.location, DireFountain, 200)
				if myTeam == TEAM_DIRE then
					front_loc = ItemUsageModule.GetXUnitsTowardsLocation( dInfo.location, RadiantFountain, 200)
				end
				if IsLocationVisible(front_loc) == true and IsLocationPassable(front_loc) == true then
					-- print('sec 1')
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end	
	end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	if #enemies == 0 then
		if bot:HasModifier('modifier_item_radiance_debuff') 
			or bot:HasModifier('modifier_sandking_sand_storm_slow') 
			or bot:HasModifier('modifier_sandking_sand_storm_slow_aura_thinker') 
		then
			-- print('sec 2')
			castDustTime = DotaTime();
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		for i = 1, #enemyPids do
			if IsHeroAlive(enemyPids[i]) == true 
				and bot:WasRecentlyDamagedByPlayer(enemyPids[i], 0.5) == true  
			then
				-- print('sec 3')
				local info = GetHeroLastSeenInfo(enemyPids[i])	
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(bot, dInfo.location) < nRadius 
				then
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end
	else
		for i=1, #enemies do
			if mutil.IsValidTarget(enemies[i])
				and ItemUsageModule.HasInvisCounterBuff(enemies[i]) == false
				and ItemUsageModule.IsUnitWillGoInvisible(enemies[i]) == true
				and ItemUsageModule.IsClosestToDustLocation(bot, enemies[i]:GetLocation())
			then
				local towers = enemies[i]:GetNearbyTowers(750, true);
				if towers == nil or #towers == 0 then
					-- print('sec 4')
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

--item_tpscroll
ItemUsageModule.Use['item_tpscroll'] = function(item, bot, mode, extra_range)
	
	local tpLoc = nil
	local shouldTP = false
	shouldTP, tpLoc = ItemUsageModule.ShouldTP(bot)
	if shouldTP then
		return BOT_ACTION_DESIRE_ABSOLUTE, tpLoc, 'point';
	end	
	
	return BOT_ACTION_DESIRE_NONE;
	
end

--item_tango
ItemUsageModule.Use['item_tango'] = function(item, bot, mode, extra_range)
	
	local tCharge = item:GetCurrentCharges()
	if DotaTime() > -80 and DotaTime() < 0 and bot:DistanceFromFountain() == 0 and role.CanBeSupport(bot:GetUnitName())
	   and bot:GetAssignedLane() ~= LANE_MID and tCharge > 2 and DotaTime() > giveTime + 2.0 then
		local target = ItemUsageModule.GiveToMidLaner(bot)
		if target ~= nil then
			giveTime = DotaTime();
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	elseif bot:GetActiveMode() == BOT_MODE_LANING and role.CanBeSupport(bot:GetUnitName()) and tCharge > 1 and DotaTime() > giveTime + 2.0 then
		local allies = bot:GetNearbyHeroes(600, false, BOT_MODE_NONE)
		for _,ally in pairs(allies)
		do
			local tangoSlot = ally:FindItemSlot('item_tango');
			local single_tangoSlot = ally:FindItemSlot('item_tango_single');
			if ally:GetUnitName() ~= bot:GetUnitName() and not ally:IsIllusion() 
			   and tangoSlot == -1 and single_tangoSlot == -1
			then
				giveTime = DotaTime();
				return BOT_ACTION_DESIRE_ABSOLUTE, ally, 'unit';
			end
		end
	end

	return ItemUsageModule.Use['item_tango_single'](item, bot, mode, extra_range);
end

--item_tango_single
ItemUsageModule.Use['item_tango_single'] = function(item, bot, mode, extra_range)

	if bot:DistanceFromFountain() < 2500 or ItemUsageModule.IsHPHealing(bot) == true then return BOT_ACTION_DESIRE_NONE end
	
	local health_regen = 7.0;
	local duration = 16;
	local total_heal = ( bot:GetHealthRegen() + health_regen ) * duration;
	
	if bot:GetHealth() + total_heal <= bot:GetMaxHealth() then
		local trees = bot:GetNearbyTrees(600);
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		local closest_enemy = enemies[1];
		local towers = bot:GetNearbyTowers(1300, true);
		local closest_tower = towers[1];
		for i=1, #trees do
			local tree_loc = GetTreeLocation(trees[i]);
			if IsLocationVisible(tree_loc)
				and IsLocationPassable(tree_loc)
				and ( #enemies == 0 or GetUnitToLocationDistance(bot, tree_loc) * 1.5 <  GetUnitToUnitDistance(bot, closest_enemy) )
				and ( #towers == 0 or GetUnitToLocationDistance(closest_tower, tree_loc) > 750 )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, trees[i], 'tree';
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_flask
ItemUsageModule.Use['item_flask'] = function(item, bot, mode, extra_range)

	if ItemUsageModule.IsHPHealing(bot) == true then return BOT_ACTION_DESIRE_NONE end

	local health_regen = 50;
	local duration = 8;
	local total_heal = ( bot:GetHealthRegen() + health_regen ) * duration;
	
	if bot:GetHealth() + total_heal <= bot:GetMaxHealth() 
	and bot:WasRecentlyDamagedByAnyHero(3.1) == false 
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_clarity
ItemUsageModule.Use['item_clarity'] = function(item, bot, mode, extra_range)

	if ItemUsageModule.IsManaHealing(bot) == true then return BOT_ACTION_DESIRE_NONE end

	local mana_regen = 6;
	local duration = 30;
	local total_mana = ( bot:GetManaRegen() + mana_regen ) * duration;
	
	if bot:GetMana() + total_mana <= bot:GetMaxMana() 
	and bot:WasRecentlyDamagedByAnyHero(3.1) == false 
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_faerie_fire
ItemUsageModule.Use['item_faerie_fire'] = function(item, bot, mode, extra_range)
	
	if ( mutil.IsRetreating(bot) and
		( bot:GetHealth() / bot:GetMaxHealth() ) < 0.15 ) 
		or DotaTime() > 10*60
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	if ItemUsageModule.IsInventoryFull(bot) == true then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_enchanted_mango
ItemUsageModule.Use['item_enchanted_mango'] = function(item, bot, mode, extra_range)
	
	if bot:GetMana() < 0.10*bot:GetMaxMana() 
		and mode == BOT_MODE_ATTACK 
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_tome_of_knowledge
ItemUsageModule.Use['item_tome_of_knowledge'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
end

--item_bottle
--RUNE_INVALID -1
--RUNE_DOUBLEDAMAGE 0
--RUNE_HASTE 1
--RUNE_ILLUSION 2
--RUNE_INVISIBILITY 3
--RUNE_REGENERATION 4
--RUNE_BOUNTY 5
--RUNE_ARCANE 6
ItemUsageModule.Use['item_bottle'] = function(item, bot, mode, extra_range)

	local nCastRange = 350 + extra_range;
	local charges = item:GetCurrentCharges();
	
	local nHP = 125;
	local nMP = 75;
	local duration = 2.5;
	
	if bot:DistanceFromFountain() == 0 
		and bot.RuneType == RUNE_INVALID
		and bot:HasModifier('modifier_bottle_regeneration') == false 
		and ( bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana() ) 
	then
		bot.RuneType = RUNE_INVALID;
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end

	if charges > 0 then
		if bot:WasRecentlyDamagedByAnyHero(3.15) == false 
			and bot:HasModifier('modifier_bottle_regeneration') == false 
			and  ( bot:GetHealth() + nHP*duration < 0.75*bot:GetMaxHealth() 
			or bot:GetMana() + nMP*duration < 0.5*bot:GetMaxMana() )
		then
			bot.RuneType = RUNE_INVALID;
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		
		if bot.RuneType == RUNE_BOUNTY then
			bot.RuneType = RUNE_INVALID;
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		elseif bot.RuneType == RUNE_DOUBLEDAMAGE or bot.RuneType == RUNE_ARCANE then
			if 	mutil.IsGoingOnSomeone(bot)
			then
				local target = bot:GetTarget();
				if  mutil.IsValidTarget(target) 
					and mutil.IsInRange(target, bot, 1000) == true
				then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		elseif bot.RuneType == RUNE_ILLUSION or bot.RuneType == RUNE_HASTE then
			if 	mutil.IsGoingOnSomeone(bot)
			then
				local target = bot:GetTarget();
				if  mutil.IsValidTarget(target) 
					and mutil.IsInRange(target, bot, 1000) == true
				then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
			if mutil.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(2.5) 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies > 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end		
		elseif bot.RuneType == RUNE_INVISIBILITY then
			if mutil.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(2.5) 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies > 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		elseif bot.RuneType == RUNE_REGENERATION then
			if mutil.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(3.15) == false 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies == 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end		
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_quelling_blade
ItemUsageModule.Use['item_quelling_blade'] = function(item, bot, mode, extra_range)
	if bot:GetUnitName() ~= 'npc_dota_hero_monkey_king' 
		and ( mutil.IsGoingOnSomeone(bot) == true 
		or ( mutil.IsRetreating(bot) == true and bot:IsInvisible() == false ) )
	then	
		local nCastRange = 300 + extra_range;
		local trees = bot:GetNearbyTrees(nCastRange);
		for i=1,#trees do
			if bot:IsFacingLocation(GetTreeLocation(trees[i]), 5) then
				return BOT_ACTION_DESIRE_ABSOLUTE, trees[i], 'tree';
			end
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_magic_stick
ItemUsageModule.Use['item_magic_stick'] = function(item, bot, mode, extra_range)

	local charges = item:GetCurrentCharges();
	local hp_ratio = bot:GetHealth() / bot:GetMaxHealth();
	local mp_ratio = bot:GetMana() / bot:GetMaxMana();
	
	if charges > 5 
		and mutil.IsGoingOnSomeone(bot)
		and hp_ratio < 0.55 and mp_ratio < 0.25
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	elseif charges > 1 
		and mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	

	return BOT_ACTION_DESIRE_NONE;
end

--item_shadow_amulet
ItemUsageModule.Use['item_shadow_amulet'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 600 + extra_range;
	
	if bot:IsInvisible() == false
		and bot:HasModifier('modifier_item_glimmer_cape') == false
		and bot:HasModifier('modifier_item_shadow_amulet_fade') == false
		and ItemUsageModule.HasInvisCounterBuff(bot) == false
		and DotaTime() + bot.castAmuletTime + 1.275
	then	
	
		local towers = bot:GetNearbyTowers(750,true);
		if #towers == 0 then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					bot.castAmuletTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
				end	
			end
			
			if bot:IsSilenced() == true and #enemies > 0
			then
				bot.castAmuletTime = DotaTime();
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';	
			end
		end
	end
	
	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i = 1, #allies
	do
		local towers = allies[i]:GetNearbyTowers(750,true);
		if #towers == 0 then
			if mutil.IsValidTarget(allies[i])
			   and allies[i] ~= bot
			   and allies[i]:IsIllusion() == false
			   and mutil.CanCastOnNonMagicImmune(allies[i])
			   and allies[i]:IsInvisible() == false
			   and allies[i]:HasModifier('modifier_item_glimmer_cape') == false
			   and allies[i]:HasModifier('modifier_item_shadow_amulet_fade') == false
			   and ItemUsageModule.HasInvisCounterBuff(allies[i]) == false
			   and ( allies[i]:IsStunned() == true or allies[i]:IsSilenced() == true or allies[i]:IsNightmared() == true )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
			end
		end	
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_ghost
ItemUsageModule.Use['item_ghost'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) 
		and ( bot:WasRecentlyDamagedByAnyHero(2.5) == true or bot:WasRecentlyDamagedByTower(3.0) == true ) 
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_blink
ItemUsageModule.Use['item_blink'] = function(item, bot, mode, extra_range)

	if bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1200 + extra_range;
	if mutil.IsStuck(bot) == true 
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
	end
	
	if mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(5.0) == true or bot:WasRecentlyDamagedByTower(5.0) == true )
	then	
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
		if #enemies > 0 then
			local loc = mutil.GetEscapeLoc();
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
		end
		
		if ItemUsageModule.CanDodgeProjectile(bot, 250) == true 
		then
			local loc = mutil.GetEscapeLoc();
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
		end
		
	end	
	
	if 	mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 200) == false 
			and mutil.IsInRange(target, bot, nCastRange) == true
		then
			local allies = target:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
			local enemies = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
			if ( enemies ~= nil and allies ~= nil and #allies >= #enemies ) or bot:GetStunDuration(true) > 0.5 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation()+RandomVector(150), 'point';
			end
		end
		if ItemUsageModule.CanDodgeProjectile(bot, 250) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetLocation()+RandomVector(250), 'point';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_magic_wand
ItemUsageModule.Use['item_magic_wand'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_magic_stick'](item, bot, mode, extra_range);
end

--item_soul_ring
ItemUsageModule.Use['item_soul_ring'] = function(item, bot, mode, extra_range)
	if  mutil.IsGoingOnSomeone(bot) and bot:GetHealth() - 150 > 0.25 * bot:GetMaxHealth() and bot:GetMana() < 0.5 * bot:GetMaxMana() then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 250) 
		then	
			local skillslot = {0,1,2,3,4,5};
			for i=1, #skillslot do
				local ability = bot:GetAbilityInSlot(skillslot[i]);
				if ability ~= nil 
					and ability:IsTrained() == true
					and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
					and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
					and ( ( ability:GetCooldownTimeRemaining() == 0 and ability:IsFullyCastable() == false ) or ability:IsFullyCastable() )
					
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end		
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_power_treads
ItemUsageModule.Use['item_power_treads'] = function(item, bot, mode, extra_range)
	local tread_stat = item:GetPowerTreadsStat();
	if mutil.IsRetreating(bot) == true and tread_stat ~= ATTRIBUTE_STRENGTH and bot:WasRecentlyDamagedByAnyHero(5.0) == true then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	elseif mutil.IsRetreating(bot) == false and ItemUsageModule.IsHPHealing(bot) == true and bot:GetHealth() < 0.95*bot:GetMaxHealth() and tread_stat == ATTRIBUTE_STRENGTH then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';	
	elseif ItemUsageModule.IsHPHealing(bot) == false and bot:WasRecentlyDamagedByAnyHero(3.0) == false and mutil.IsRetreating(bot) == false then
		local enemies = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if #enemies == 0 and ItemUsageModule.CanSwitchPTStat(bot, item) == true  then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_mask_of_madness
ItemUsageModule.Use['item_mask_of_madness'] = function(item, bot, mode, extra_range)
	local skillslot = {0,1,2,3,4,5};
	local n_ability = 0;
	for i=1, #skillslot do
		local ability = bot:GetAbilityInSlot(skillslot[i]);
		if ability ~= nil 
			and ability:IsTrained() == true
			and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
			and ItemUsageModule.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
		then
			n_ability = n_ability + 1;
			if ability:IsFullyCastable() == false then
				n_ability = n_ability - 1;
			end
		end
	end
	if  n_ability <= 0 and mutil.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 200) 
		then	
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end		
	end
	if mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(6.0) == true or bot:WasRecentlyDamagedByTower(6.0) == true )
	then	
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil,  'no_target';
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_moon_shard
ItemUsageModule.Use['item_moon_shard'] = function(item, bot, mode, extra_range)
	if bot:HasModifier("modifier_item_moon_shard_consumed") == false
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
	end
end

--item_phase_boots
ItemUsageModule.Use['item_phase_boots'] = function(item, bot, mode, extra_range)
	if mutil.IsGoingOnSomeone(bot) == true 
	then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange()) == false
		then	
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end		
	end
	if mutil.IsRetreating(bot) == true and bot:IsInvisible() == false 
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_helm_of_the_dominator
ItemUsageModule.Use['item_helm_of_the_dominator'] = function(item, bot, mode, extra_range)
	local nCastRange = 700 + extra_range;
	local neutrals = bot:GetNearbyNeutralCreeps(nCastRange);
	for _,u in pairs(neutrals) do
		if mutil.CanBeDominatedCreeps(u:GetUnitName()) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, u, 'unit';
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_hand_of_midas
ItemUsageModule.Use['item_hand_of_midas'] = function(item, bot, mode, extra_range)
	local nCastRange = 600 + extra_range;
	local creeps = bot:GetNearbyCreeps(nCastRange, true);
	for _,u in pairs(creeps) do
		if u:IsAncientCreep() == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, u, 'unit';
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_pipe
ItemUsageModule.Use['item_pipe'] = function(item, bot, mode, extra_range)
	
	local nRadius = 1200;
	
	if mutil.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300) then
		local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
		if #allies > 1 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	
	
	if mutil.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.CanCastOnMagicImmune(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 500)  
		then
			local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if #allies > 1 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end		
	end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if #enemies > 0 then
		local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_RETREAT);
		if #allies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_medallion_of_courage
ItemUsageModule.Use['item_medallion_of_courage'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 1000 + extra_range;
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
		   and target:HasModifier('modifier_item_solar_crest_armor_reduction') == false
		   and target:HasModifier('modifier_item_medallion_of_courage_armor_reduction') == false
		   and mutil.CanCastOnNonMagicImmune(target) == true
		   and mutil.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and allies[i]:HasModifier('modifier_item_solar_crest_armor_addition') == false
			and allies[i]:HasModifier('modifier_item_medallion_of_courage_armor_addition') == false
			and ( ( allies[i]:GetHealth()/allies[i]:GetMaxHealth() < 0.35 and allies[i]:WasRecentlyDamagedByAnyHero(2.5) and mutil.CanCastOnNonMagicImmune(allies[i]) ) 
				or ( mutil.IsDisabled(false, allies[i]) and mutil.CanCastOnNonMagicImmune(allies[i]) ) )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_mekansm
ItemUsageModule.Use['item_mekansm'] = function(item, bot, mode, extra_range)

	local nRadius = 1200;
	local nHeal = 275;
	
	if mutil.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 and bot:GetHealth() + nHeal <= 0.5*bot:GetMaxHealth() then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300) then
		local n_low_hp = 0;
		local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i]:GetHealth() + nHeal <= 0.5*allies[i]:GetMaxHealth() then
				n_low_hp = n_low_hp + 1;
			end
		end
		if n_low_hp > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	
	
	if mutil.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if  mutil.IsValidTarget(target) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 500) 
		then
			local n_low_hp = 0;
			local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			for i=1, #allies do
				if allies[i]:GetHealth() + nHeal <= 0.5*allies[i]:GetMaxHealth() then
					n_low_hp = n_low_hp + 1;
				end
			end
			if n_low_hp > 0 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end		
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_guardian_greaves
ItemUsageModule.Use['item_guardian_greaves'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_mekansm'](item, bot, mode, extra_range);
end

--item_arcane_boots
ItemUsageModule.Use['item_arcane_boots'] = function(item, bot, mode, extra_range)
	local nRadius = 1200;
	local n_low_mp = 0;
	local n_mana = 160;
	if item:GetName() == 'item_arcane_ring' then
		n_mana = 75;
	end
	local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetMana() + n_mana <= 0.75*allies[i]:GetMaxMana() then
			n_low_mp = n_low_mp + 1;
		end
	end
	if n_low_mp > 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	if bot:GetMana() < 0.25 * bot:GetMaxMana() then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_holy_locket
ItemUsageModule.Use['item_holy_locket'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges();
	local hp_ratio = bot:GetHealth() / bot:GetMaxHealth();
	local mp_ratio = bot:GetMana() / bot:GetMaxMana();
	local nCastRange = 500 + extra_range;
	
	if charges > 5 
		and mutil.IsGoingOnSomeone(bot)
		and hp_ratio < 0.55 and mp_ratio < 0.25
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	elseif charges > 1 
		and mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end	
	
	if charges >= 10 then
		local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i]:GetUnitName() ~= bot:GetUnitName() 
				and mutil.CanCastOnNonMagicImmune(allies[i]) == true
				and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
			then
				local mode2 = allies[i]:GetActiveMode();
				if  ( ( mode2 == BOT_MODE_RETREAT and allies[i]:GetHealth() < 0.15 * allies[i]:GetMaxHealth() ) 
						or ( allies[i]:GetHealth() < 0.25 * allies[i]:GetMaxHealth() 
							and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) )
				then	
					return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_urn_of_shadows
ItemUsageModule.Use['item_urn_of_shadows'] = function(item, bot, mode, extra_range)
	
	local charges = item:GetCurrentCharges();
	local nCastRange = 950 + extra_range;
	local nRegen = 30;
	local nDuration = 8;
	local nDamage = 25 * nDuration;

	if mutil.IsGoingOnSomeone(bot) and charges > 1
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
			and mutil.CanCastOnNonMagicImmune(target) 
			and mutil.IsInRange(target, bot, nCastRange) 
		    and target:HasModifier("modifier_item_spirit_vessel_damage") == false 
		    and target:HasModifier('modifier_item_urn_damage') == false 
			and (( item:GetName() == 'item_urn_of_shadows' and target:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_MAGICAL  ) > target:GetHealth() ) 
				or ( item:GetName() == 'item_spirit_vessel' and target:GetHealth() < 0.75*bot:GetMaxHealth() ) )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	if charges > 0 then
		local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
		for i=1, #allies do
			if 	mutil.IsValidTarget(allies[i])
				and allies[i]:WasRecentlyDamagedByAnyHero(3.25) == false 
				and allies[i]:HasModifier('modifier_item_spirit_vessel_heal') == false 
				and allies[i]:HasModifier('modifier_item_urn_heal') == false 
				and mutil.CanCastOnNonMagicImmune(allies[i]) 
				and allies[i]:GetHealth() + ( allies[i]:GetHealthRegen() + nRegen ) * nDuration < 0.65 * allies[i]:GetMaxHealth()   
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_ancient_janggo
ItemUsageModule.Use['item_ancient_janggo'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges();
	if charges == 0 then return BOT_ACTION_DESIRE_NONE; end
	return ItemUsageModule.Use['item_pipe'](item, bot, mode, extra_range);
end

--item_spirit_vessel
ItemUsageModule.Use['item_spirit_vessel'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_urn_of_shadows'](item, bot, mode, extra_range);
end

--item_glimmer_cape
ItemUsageModule.Use['item_glimmer_cape'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_shadow_amulet'](item, bot, mode, extra_range);
end

--item_necronomicon
ItemUsageModule.Use['item_necronomicon'] = function(item, bot, mode, extra_range)

	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
		   and mutil.CanCastOnMagicImmune(target) == true
		   and mutil.IsInRange(target, bot, bot:GetAttackRange() + 250) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_necronomicon_2
ItemUsageModule.Use['item_necronomicon_2'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_necronomicon_3
ItemUsageModule.Use['item_necronomicon_3'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_solar_crest
ItemUsageModule.Use['item_solar_crest'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_medallion_of_courage'](item, bot, mode, extra_range);
end

--item_refresher
ItemUsageModule.Use['item_refresher'] = function(item, bot, mode, extra_range)
	if mutil.IsGoingOnSomeone(bot) and mutil.CanUseRefresherOrb(bot)  
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
		   and mutil.IsInRange(target, bot, bot:GetAttackRange() + 200) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_veil_of_discord
ItemUsageModule.Use['item_veil_of_discord'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 1000 + extra_range;
	local nRadius = 600;

	if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = mutil.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, bot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
			end
		end
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_dagon
ItemUsageModule.Use['item_dagon'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 600 + extra_range;
	local nDamage = 400;
	
	if item:GetName() == "item_dagon_2" then 
		nCastRange = 650;
		nDamage = 500;
	elseif item:GetName() == "item_dagon_3" then
		nCastRange = 700;
		nDamage = 600;
	elseif item:GetName() == "item_dagon_4" then
		nCastRange = 750;
		nDamage = 700;
	elseif item:GetName() == "item_dagon_5" then
		nCastRange = 800;
		nDamage = 800;
	end
	
	if mutil.IsRetreating(bot) then
		local target = mutil.GetVulnerableWeakestUnit(true, true, nCastRange, bot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
		   and mutil.CanCastOnNonMagicImmune(target) == true
		   and mutil.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_dagon_2
ItemUsageModule.Use['item_dagon_2'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_3
ItemUsageModule.Use['item_dagon_3'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_4
ItemUsageModule.Use['item_dagon_4'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_5
ItemUsageModule.Use['item_dagon_5'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_orchid
ItemUsageModule.Use['item_orchid'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 900 + extra_range;
	
	if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300)
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true 
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsInRange(target, bot, nCastRange) == true 
			and mutil.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	for i=1, #enemies do
		if mutil.IsValidTarget(enemies[i]) == true 
			and mutil.CanCastOnNonMagicImmune(enemies[i]) == true 
			and enemies[i]:IsChanneling()
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_sheepstick
ItemUsageModule.Use['item_sheepstick'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_orchid'](item, bot, mode, extra_range);
end

--item_force_staff
ItemUsageModule.Use['item_force_staff'] = function(item, bot, mode, extra_range)
	
	local aCastRange = 550;
	local eCastRange = 850;
	
	if item:GetName() == 'item_hurricane_pike' then
		eCastRange = 400;
	elseif item:GetName() == 'item_force_boots' then
		aCastRange = 750
		eCastRange = 750
	end
	
	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		if item:GetName() == 'item_hurricane_pike' then
			local loc = mutil.GetEscapeLoc2(bot);
			local bot_dist = GetUnitToLocationDistance(bot, loc);
			local enemies = bot:GetNearbyHeroes(eCastRange, true, BOT_MODE_NONE)
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and mutil.CanCastOnNonMagicImmune(enemies[i])
					and GetUnitToLocationDistance(enemies[i], loc) > bot_dist + 50 
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
				end				
			end
		end
		local loc = mutil.GetEscapeLoc();
		if bot:IsFacingLocation(loc,15) then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true 
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsInRange(target, bot, eCastRange) == true 
			and ItemUsageModule.IsForceStafed(target) == false
		then
			if item:GetName() == 'item_hurricane_pike' then
				local loc = mutil.GetEscapeLoc2(bot);
				local bot_dist = GetUnitToLocationDistance(bot, loc);
				local target_dist = GetUnitToLocationDistance(target, loc);
				if target_dist > bot_dist + 50 
					and ( target:IsFacingUnit(bot, 15) == true or target:GetAttackTarget() == bot )  
					and mutil.IsInRange(bot, target, eCastRange) == true  
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
				end
			end
			if item:GetName() == 'item_force_staff' and target:IsFacingUnit(bot, 15) then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		elseif mutil.IsValidTarget(target) == true 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() - 200) == false 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 300) == true 
			and ItemUsageModule.IsForceStafed(bot) == false
			and bot:IsFacingUnit(target, 15)
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = target:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
			end
		end
	end
	
	local allies=bot:GetNearbyHeroes(aCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and mutil.CanCastOnNonMagicImmune(allies[i]) == true
			and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
		then
			local mode2 = allies[i]:GetActiveMode();
			local loc = mutil.GetEscapeLoc2(allies[i]);
			if  allies[i]:IsFacingLocation(loc,15)
				and ( ( mode2 == BOT_MODE_RETREAT ) 
					or ( allies[i]:GetHealth() < 0.25 * allies[i]:GetMaxHealth() 
						and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) )
			then	
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_cyclone
ItemUsageModule.Use['item_cyclone'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 550 + extra_range;
	
	if item:GetName() == 'item_rod_of_atos' then
		nCastRange = 1100 + extra_range;
	end
	
	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true
		or bot:WasRecentlyDamagedByTower(2.0) == true )
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nCastRange) == true
			and mutil.CanCastOnNonMagicImmune(target) == true
			and target:WasRecentlyDamagedByAnyHero(3.5) == false
			and mutil.IsDisabled(true, target) == false
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
			local allies2 = target:GetNearbyHeroes(500, true, BOT_MODE_NONE);
			if enemies ~= nil and #enemies == 1 
				and allies ~= nil and #allies > 1 
				and allies2 ~= nil and #allies2 <= 1 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		end
	end
	
	if item:GetName() == 'item_cyclone' then
		if ( bot:IsSilenced() == true or bot:IsRooted( ) == true )
			and bot:WasRecentlyDamagedByAnyHero(3.0) == true 
			and bot:GetHealth() < 0.65*bot:GetMaxHealth() 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	for i=1, #enemies do
		if mutil.IsValidTarget(enemies[i]) == true 
			and mutil.CanCastOnNonMagicImmune(enemies[i]) == true 
			and ( enemies[i]:IsChanneling()
			or enemies[i]:HasModifier('modifier_teleporting') or enemies[i]:HasModifier('modifier_abaddon_borrowed_time') )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_rod_of_atos
ItemUsageModule.Use['item_rod_of_atos'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_cyclone'](item, bot, mode, extra_range);
end

--item_nullifier
ItemUsageModule.Use['item_nullifier'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 900 + extra_range;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nCastRange) == true
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_hood_of_defiance
ItemUsageModule.Use['item_hood_of_defiance'] = function(item, bot, mode, extra_range)

	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and mutil.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end	
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_hurricane_pike
ItemUsageModule.Use['item_hurricane_pike'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_force_staff'](item, bot, mode, extra_range);
end

--item_sphere
ItemUsageModule.Use['item_sphere'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end

--item_crimson_guard
ItemUsageModule.Use['item_crimson_guard'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_pipe'](item, bot, mode, extra_range);
end

--item_shivas_guard
ItemUsageModule.Use['item_shivas_guard'] = function(item, bot, mode, extra_range)
	
	local nRadius = 900;
	local manaCost = 100;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300) then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies > 1 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	
	
	if ( mutil.IsPushing(bot) or mutil.IsDefending(bot) ) and mutil.CanSpamSpell(bot, manaCost)
	then
		local creeps = bot:GetNearbyCreeps(nRadius, true);
		if #creeps > 4 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nRadius - 200) == true
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_blade_mail
ItemUsageModule.Use['item_blade_mail'] = function(item, bot, mode, extra_range)

	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and mutil.CanCastOnMagicImmune(enemies[i])
					and mutil.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end	
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_lotus_orb
ItemUsageModule.Use['item_lotus_orb'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 900 + extra_range;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
		if ItemUsageModule.CanDodgeProjectile(bot, 250) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and mutil.CanCastOnMagicImmune(enemies[i])
					and mutil.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
				end	
			end
			if ItemUsageModule.CanDodgeProjectile(bot, 250) == true 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, bo, 'unit';
			end
		end
	end
	
	if bot:IsSilenced() or bot:IsRooted() then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
	end
	
	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i = 1, #allies
	do
		if mutil.IsValidTarget(allies[i])
		   and allies[i] ~= bot
		   and allies[i]:IsIllusion() == false
		   and allies[i]:HasModifier('modifier_item_lotus_orb_active') == false
		   and mutil.CanCastOnNonMagicImmune(allies[i])
		   and ( allies[i]:IsStunned() == true or allies[i]:IsSilenced() == true or allies[i]:IsNightmared() == true )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_manta
ItemUsageModule.Use['item_manta'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		if ItemUsageModule.CanDodgeProjectile(bot, 175) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if mutil.IsValidTarget(enemies[i])
					and mutil.CanCastOnMagicImmune(enemies[i])
					and mutil.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end	
			end
			if ItemUsageModule.CanDodgeProjectile(bot, 175) == true 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	
	if bot:IsSilenced() or bot:IsRooted() then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_black_king_bar
ItemUsageModule.Use['item_black_king_bar'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
		and bot:GetHealth() > 0.25 * bot:GetMaxHealth()
		and bot:GetHealth() < 0.65 * bot:GetMaxHealth()
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		if ItemUsageModule.CanDodgeProjectile(bot, 175) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true 
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_ATTACK);
			if #enemies >= #allies then
				for i=1, #enemies do
					if mutil.IsValidTarget(enemies[i])
						and mutil.CanCastOnMagicImmune(enemies[i])
						and mutil.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
						and ( enemies[i]:GetAttackTarget() == bot or enemies[i]:GetTarget() == bot
						or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
					then
						return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
					end	
				end
			end
			if ItemUsageModule.CanDodgeProjectile(bot, 175) == true 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	
	if bot:IsSilenced() or bot:IsRooted() then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_bloodstone
ItemUsageModule.Use['item_bloodstone'] = function(item, bot, mode, extra_range)
	if  mutil.IsRetreating(bot)
		and bot:GetHealth() < 0.25*bot:GetMaxHealth()  
		and bot:GetMana() > 0.6*bot:GetMaxMana() 
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_radiance
ItemUsageModule.Use['item_radiance'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end


--item_armlet
ItemUsageModule.Use['item_armlet'] = function(item, bot, mode, extra_range)
		if mutil.IsRetreating(bot) == true
			and bot:WasRecentlyDamagedByAnyHero(2.0) == true
			and item:GetToggleState( ) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		
		if mutil.IsGoingOnSomeone(bot) 
		then
			local target = bot:GetTarget();
			if mutil.IsValidTarget(target) == true
				and mutil.IsInRange(bot, target, bot:GetAttackRange() + 150) == true
				and item:GetToggleState( ) == false
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies == 0 and item:GetToggleState( ) == true then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	
	-- local projectiles = bot:GetIncomingTrackingProjectiles();
	-- local nearestprojectile = nil;
	-- local lowest_distance = 9999;
	-- for k, projectile in pairs(projectiles) do
		-- if (GetUnitToLocationDistance( bot, projectile.location) < lowest_distance 
			-- and projectile.caster ~= nil 
			-- and projectile.playerid ~= nil 
			-- and GetTeamForPlayer( projectile.playerid ) ~= GetTeam() ) 
		-- then
			-- lowest_distance = GetUnitToLocationDistance( bot, projectile.location);
			-- nearestprojectile = projectile.ability;
		-- end
	-- end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_abyssal_blade
ItemUsageModule.Use['item_abyssal_blade'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 200 + extra_range;
	
	if mutil.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and bot:WasRecentlyDamagedByAnyHero(3.0) then
			local loc = mutil.GetEscapeLoc();
			local furthestUnit = mutil.GetClosestEnemyUnitToLocation(bot, nCastRange, loc);
			if furthestUnit ~= nil and GetUnitToUnitDistance(furthestUnit, bot) >= 0.5*nCastRange  
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, furthestUnit, 'unit';
			end
		elseif tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes == 1 
			and mutil.IsValidTarget(tableNearbyEnemyHeroes[1])  == true
			and mutil.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1]) == true
			and mutil.IsDisabled(true, tableNearbyEnemyHeroes[1]) == false
		then	
			return BOT_ACTION_DESIRE_ABSOLUTE, furthestUnit, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
			and mutil.CanCastOnNonMagicImmune(target)
			and mutil.IsInRange(target, bot, nCastRange) 
			and mutil.IsDisabled(true, target) == false
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
			if enemies ~= nil and allies ~= nil and #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_meteor_hammer
ItemUsageModule.Use['item_meteor_hammer'] = function(item, bot, mode, extra_range)

	local nCastRange = 600 + extra_range;
	
	if item:GetName() == 'item_fallen_sky' then
		nCastRange = 1600;
	end

	if mutil.IsPushing(bot) then
		local towers = bot:GetNearbyTowers(800, true);
		if #towers > 0 and towers[1] ~= nil and  towers[1]:IsInvulnerable() == false then 
			return BOT_ACTION_DESIRE_ABSOLUTE, towers[1]:GetLocation(), 'point';
		end
	elseif  mutil.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 600, 300, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, locationAoE.targetloc, 'point';
		end
	elseif mutil.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, bot, nCastRange) 
		then
			if item:GetName() == 'item_meteor_hammer' and mutil.IsDisabled(true, target) == true	 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
			end
			if item:GetName() == 'item_fallen_sky' then
				local allies = target:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
				local enemies = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
				if ( enemies ~= nil and allies ~= nil and #allies >= #enemies ) 
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_bfury
ItemUsageModule.Use['item_bfury'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_quelling_blade'](item, bot, mode, extra_range);
end

--item_invis_sword
ItemUsageModule.Use['item_invis_sword'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_ethereal_blade
ItemUsageModule.Use['item_ethereal_blade'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 800 + extra_range;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsInTeamFight(bot, 1300)
	then
		local enemies =  bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		if #enemies > 1 then
			local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
			if target ~= nil then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_silver_edge
ItemUsageModule.Use['item_silver_edge'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_invis_sword'](item, bot, mode, extra_range);
end

--item_bloodthorn
ItemUsageModule.Use['item_bloodthorn'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_orchid'](item, bot, mode, extra_range);
end

--item_satanic
ItemUsageModule.Use['item_satanic'] = function(item, bot, mode, extra_range)

	if mutil.IsGoingOnSomeone(bot) and bot:IsDisarmed() == false
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, bot:GetAttackRange()+150) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_diffusal_blade
ItemUsageModule.Use['item_diffusal_blade'] = function(item, bot, mode, extra_range)
	local nCastRange = 600 + extra_range;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nCastRange) == true
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsDisabled(true, target) == false
			and target:GetCurrentMovementSpeed() > 200
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_mjollnir
ItemUsageModule.Use['item_mjollnir'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 800;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nCastRange) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_heavens_halberd
ItemUsageModule.Use['item_heavens_halberd'] = function(item, bot, mode, extra_range)
	local nCastRange = 600 + extra_range;
	
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(bot, target, nCastRange) == true
			and mutil.CanCastOnNonMagicImmune(target) == true
			and mutil.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

----------NEUTRAL ITEM------------

--item_iron_talon
ItemUsageModule.Use['item_iron_talon'] = function(item, bot, mode, extra_range)
	if bot:GetActiveMode() == BOT_MODE_FARM or mutil.IsDefending(bot) or mutil.IsPushing(bot) 
	then
		local neutrals = bot:GetNearbyCreeps(350, true);
		local maxHP = 0;
		local target = nil;
		for _,c in pairs(neutrals) do
			local cHP = c:GetHealth();
			if cHP > maxHP and not c:IsAncientCreep() then
				maxHP = cHP;
				target = c;
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_ironwood_tree
ItemUsageModule.Use['item_ironwood_tree'] = function(item, bot, mode, extra_range)
	local nCastRange = 600;
	if mutil.IsRetreating(bot)
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		if #enemies > 0 and enemies[1] ~= nil and GetUnitToUnitDistance(bot, enemies[1]) > 150 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation(enemies[1]:GetLocation(), 75), 'point';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_royal_jelly
ItemUsageModule.Use['item_royal_jelly'] = function(item, bot, mode, extra_range)
	local nCastRange = 250 + 200;
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:HasModifier("modifier_royal_jelly") == false
			and mutil.CanCastOnNonMagicImmune(allies[i]) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_mango_tree
ItemUsageModule.Use['item_mango_tree'] = function(item, bot, mode, extra_range)
	local nCastRange = 200;
	return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetLocation() + RandomVector(nCastRange), 'point';
end

--item_trusty_shovel
ItemUsageModule.Use['item_trusty_shovel'] = function(item, bot, mode, extra_range)
	local nCastRange = 250;
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if #enemies == 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetLocation() + RandomVector(nCastRange), 'point';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_arcane_ring
ItemUsageModule.Use['item_arcane_ring'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_arcane_boots'](item, bot, mode, extra_range);
end

--item_essence_ring
ItemUsageModule.Use['item_essence_ring'] = function(item, bot, mode, extra_range)
	local hpRes = 425;
	if mutil.IsRetreating(bot)
		and bot:GetHealth() < 0.35 * bot:GetMaxHealth()  
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_vambrace
ItemUsageModule.Use['item_vambrace'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end

--item_clumsy_net
ItemUsageModule.Use['item_clumsy_net'] = function(item, bot, mode, extra_range)
	local nCastRange = 650;
	
	if mutil.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.CanCastOnNonMagicImmune(target) == true 
			and mutil.IsInRange(target, bot, nCastRange) == true 
			and mutil.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_repair_kit
ItemUsageModule.Use['item_repair_kit'] = function(item, bot, mode, extra_range)
	local nCastRange = 600;
	local towers = bot:GetNearbyTowers(nCastRange, false);
	for i=1, #towers do
		if towers[i]:GetHealth() <= 0.6 * towers[i]:GetMaxHealth() and towers[i]:HasModifier("modifier_repair_kit") == false then
			return BOT_ACTION_DESIRE_ABSOLUTE, towers[i], 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_greater_faerie_fire
ItemUsageModule.Use['item_greater_faerie_fire'] = function(item, bot, mode, extra_range)
	local hpRes = 500;
	if mutil.IsRetreating(bot) == true
		and bot:DistanceFromFountain() > 0 == true 
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
		and bot:GetHealth() < 0.25 * bot:GetMaxHealth()   
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_spider_legs
ItemUsageModule.Use['item_spider_legs'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	if mutil.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 200) == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_flicker
ItemUsageModule.Use['item_flicker'] = function(item, bot, mode, extra_range)
	if bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	if  mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
		and bot:IsRooted() == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	return BOT_ACTION_DESIRE_NONE;
end

--item_ninja_gear
ItemUsageModule.Use['item_ninja_gear'] = function(item, bot, mode, extra_range)
	local nCastRange = 1025
	if mutil.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.IsInRange(target, bot, nCastRange+600) == false 
		and mutil.IsInRange(target, bot, 2500) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+150, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_illusionsts_cape
ItemUsageModule.Use['item_illusionsts_cape'] = function(item, bot, mode, extra_range)
	local nCastRange = bot:GetAttackRange();
	local target = bot:GetTarget();
	if mutil.IsGoingOnSomeone(bot)
	then	
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) 
			and mutil.IsInRange(target, bot, nCastRange+200) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if mutil.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_havoc_hammer
ItemUsageModule.Use['item_havoc_hammer'] = function(item, bot, mode, extra_range)
	local nRadius = 300;
	if mutil.IsRetreating(bot)
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies >= 1 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if mutil.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.IsInRange(target, bot, bot:GetAttackRange()+200) == true
		then
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			if #enemies >= 1 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_minotaur_horn
ItemUsageModule.Use['item_minotaur_horn'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_black_king_bar'](item, bot, mode, extra_range);
end

--item_force_boots
ItemUsageModule.Use['item_force_boots'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_force_staff'](item, bot, mode, extra_range);
end

--item_force_boots_old
ItemUsageModule.Use['item_force_boots_old'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local loc = mutil.GetEscapeLoc();
		if bot:IsFacingLocation(loc,15) then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if mutil.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) == true 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() - 200) == false 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 300) == true 
			and ItemUsageModule.IsForceStafed(bot) == false
			and bot:IsFacingUnit(target, 15)
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = target:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_woodland_striders
ItemUsageModule.Use['item_woodland_striders'] = function(item, bot, mode, extra_range)
	if mutil.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(0.5) == true
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_demonicon
ItemUsageModule.Use['item_demonicon'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_fallen_sky
ItemUsageModule.Use['item_fallen_sky'] = function(item, bot, mode, extra_range)
	local nCastRange = 1600;
	if mutil.IsStuck(bot)
	then
		local loc = mutil.GetEscapeLoc();
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
	elseif mutil.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = mutil.GetEscapeLoc();
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
		end	
	end
	return ItemUsageModule.Use['item_meteor_hammer'](item, bot, mode, extra_range);
end

--item_ex_machina
ItemUsageModule.Use['item_ex_machina'] = function(item, bot, mode, extra_range)
	local nCastRange = bot:GetAttackRange()
	local target = bot:GetTarget();
	if mutil.IsGoingOnSomeone(bot)
	then	
		if mutil.IsValidTarget(target) and mutil.IsInRange(target, bot, nCastRange+200) == true
		then
			local nCdItem = 0;
			for i=0, 5 do
				local cdIt = bot:GetItemInSlot(i);
				if cdIt ~= nil and cdIt:GetCooldownTimeRemaining() > 10 then
					nCdItem = nCdItem + 1;
				end
			end
			if nCdItem >= 2 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(1.0) 
	then
		local nCdItem = 0;
		for i=0, 5 do
			local cdIt = bot:GetItemInSlot(i);
			if cdIt ~= nil and cdIt:GetCooldownTimeRemaining() > 10 then
				nCdItem = nCdItem + 1;
			end
		end
		if nCdItem >= 2 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--------ROSHAN DROP------
--item_refresher_shard
ItemUsageModule.Use['item_refresher_shard'] = function(item, bot, mode, extra_range)
	if mutil.IsGoingOnSomeone(bot) and mutil.CanUseRefresherShard(bot)  
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end
--item_cheese
ItemUsageModule.Use['item_cheese'] = function(item, bot, mode, extra_range)
	local maxHP = 2500;
	local maxMP = 1500;
	
	if bot:GetHealth()+0.5*maxHP < bot:GetMaxHealth() 
		or bot:GetMana()+0.5*maxMP < bot:GetMaxMana()
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--------- PATCH 7.28 -----------
--item_gungir
ItemUsageModule.Use['item_gungir'] = function(item, bot, mode, extra_range)
	local nCastRange = 1100 + extra_range;
	
	if  mutil.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, 300, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, locationAoE.targetloc, 'point';
		end
	elseif mutil.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) and mutil.CanCastOnNonMagicImmune(target) and mutil.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_eternal_shroud
ItemUsageModule.Use['item_eternal_shroud'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_hood_of_defiance'](item, bot, mode, extra_range);
end
--item_helm_of_the_dominator_2
ItemUsageModule.Use['item_helm_of_the_dominator_2'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_helm_of_the_dominator'](item, bot, mode, extra_range);
end
--item_overwhelming_blink
ItemUsageModule.Use['item_overwhelming_blink'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_blink'](item, bot, mode, extra_range);
end
--item_swift_blink
ItemUsageModule.Use['item_swift_blink'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_blink'](item, bot, mode, extra_range);
end
--item_arcane_blink
ItemUsageModule.Use['item_arcane_blink'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_blink'](item, bot, mode, extra_range);
end
--item_wind_waker
ItemUsageModule.Use['item_wind_waker'] = function(item, bot, mode, extra_range)
	return ItemUsageModule.Use['item_cyclone'](item, bot, mode, extra_range);
end
--item_bullwhip
ItemUsageModule.Use['item_bullwhip'] = function(item, bot, mode, extra_range)
	local nCastRange = 850 + extra_range;

	if mutil.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target) 
			and mutil.CanCastOnNonMagicImmune(bot) 
			and mutil.IsInRange(target, bot, bot:GetAttackRange()) == false 
			and mutil.IsInRange(target, bot, bot:GetAttackRange() + 200) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_RETREAT);
	for i = 1, #allies
	do
		if mutil.IsValidTarget(allies[i])
		   and allies[i]:IsIllusion() == false
		   and mutil.CanCastOnNonMagicImmune(allies[i])
		   and allies[i]:WasRecentlyDamagedByAnyHero(1.0)
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_ATTACK);
	for i = 1, #allies
	do
		if mutil.IsValidTarget(allies[i])
		   and allies[i]:IsIllusion() == false
		   and mutil.CanCastOnNonMagicImmune(allies[i])
		   and allies[i]:GetAttackRange() < 325
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_psychic_headband
ItemUsageModule.Use['item_psychic_headband'] = function(item, bot, mode, extra_range)
	local nCastRange = 800 + extra_range;

	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true
		or bot:WasRecentlyDamagedByTower(2.0) == true )
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_stormcrafter
ItemUsageModule.Use['item_stormcrafter'] = function(item, bot, mode, extra_range)
	
	if ( bot:IsSilenced() == true or bot:IsRooted( ) == true )
		and bot:WasRecentlyDamagedByAnyHero(3.0) == true 
		and bot:GetHealth() < 0.65*bot:GetMaxHealth() 
		and mutil.CanCastOnNonMagicImmune(bot)
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
--item_trickster_cloak
ItemUsageModule.Use['item_trickster_cloak'] = function(item, bot, mode, extra_range)
	
	if mutil.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
--item_book_of_shadows
ItemUsageModule.Use['item_book_of_shadows'] = function(item, bot, mode, extra_range)
	local nCastRange = 700 + extra_range
	if mutil.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = ItemUsageModule.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	if mutil.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if mutil.IsValidTarget(target)
		then
			local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			if #enemies > 1 then
				for i=1, #enemies do
					if enemies[i] ~= target and mutil.CanCastOnNonMagicImmune(enemies[i]) then
						return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
					end
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

return ItemUsageModule;