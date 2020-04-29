local role = require(GetScriptDirectory() .. "/RoleUtility");
local utils = require(GetScriptDirectory() ..  "/util")
local campUtils = require(GetScriptDirectory() ..  "/CampUtility")
local bot = GetBot();
local unit_name = bot:GetUnitName();
local dotaTime = 0;
local minute = 0;
local sec = 0;
local lanes = {LANE_TOP, LANE_MID, LANE_BOT};
local preferedCamp = nil;
local AvailableCamp = {};
local LaneCreeps = {};
local numCamp = 18;
local farmState = 0;
bot.farmLaneLocation = nil;
local dfarmLaneLocation = 0;
local lfarmLaneLocation = -1;

local myTeam = GetTeam();
local teamPlayer = GetTeamPlayers(myTeam)
local enemyTeam = GetOpposingTeam();
local enemyPlayer = GetTeamPlayers(enemyTeam)
local tAncient = GetAncient(myTeam);
local eAncient = GetAncient(enemyTeam);
local state = nil;

function GetDesire()	
	
	if bot:IsAlive() == false then
		return BOT_MODE_DESIRE_NONE
	end
	
	dotaTime = DotaTime();
	minute = math.floor(dotaTime / 60)
	sec = dotaTime % 60
	
	if #AvailableCamp < numCamp 
		and ( ( dotaTime > 61 and sec <= 1 ) or ( dotaTime >= 60 and dotaTime < 61 ) )
	then
		print('refresh camp '..tostring(dotaTime));
		AvailableCamp, numCamp = campUtils.RefreshCamp(bot);
	end
	
	if ( unit_name == 'npc_dota_hero_antimage' or unit_name == 'npc_dota_hero_luna' ) and bot:GetLevel() > 6 then
		bot.farmLaneLocation, dfarmLaneLocation, lfarmLaneLocation = GetClosestSafeLaneToFarm();
		if bot.farmLaneLocation ~= nil then
			local hpPct = bot:GetHealth() / bot:GetMaxHealth();
			return RemapValClamped(hpPct, 0, 0.5, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_ABSOLUTE)
		end
	end
	
	return BOT_MODE_DESIRE_NONE
	
end

function OnEnd()
	bot.farmLaneLocation = nil;
	dfarmLaneLocation = 0;
	lfarmLaneLocation = -1;
end

function Think()
	if bot:IsUsingAbility() or bot:IsChanneling() then 
		return;
	end
	
	local attackRange = bot:GetAttackRange();
	local tp = bot:GetItemInSlot(15);
	if bot.farmLaneLocation ~= nil then
		if tp ~= nil and tp:IsFullyCastable() 
			and GetUnitToLocationDistance(bot, bot.farmLaneLocation) > 4500 
			and GetNEnemyAroundLocation(bot:GetLocation(), 1600, 3.0) == 0
		then
			bot:Action_UseAbilityOnLocation(tp, bot.farmLaneLocation);
			return
		end
	end
	
	if bot.farmLaneLocation ~= nil then
		if ( attackRange < 175 and dfarmLaneLocation > 2*attackRange + 200 ) or ( attackRange > 350 and dfarmLaneLocation > attackRange+200 ) then
			printState('move to farm location');
			bot:Action_MoveToLocation(bot.farmLaneLocation);
			return;
		else
			local enemyCreeps = bot:GetNearbyLaneCreeps(1600, true);
			local allyCreeps = bot:GetNearbyLaneCreeps(1600, false);
			local enemyTowers = bot:GetNearbyTowers(1600, true);
			if #enemyCreeps == 0 and #enemyTowers == 0 then
				local target = GetTargetCreepToAttack(bot, enemyCreeps, allyCreeps, enemyTowers);
				if  target~=nil then
					printState('deny creep');
					bot:Action_AttackUnit(target, true);
					return
				else	
					printState('follow our lane creeps');
					bot:Action_MoveToLocation(bot.farmLaneLocation);
					return;
				end
			else
				local target = GetTargetCreepToAttack(bot, enemyCreeps, allyCreeps, enemyTowers);
				if  target~=nil then
					printState('last hit/deny creep');
					bot:Action_AttackUnit(target, true);
					return
				elseif IsTargetedByCreepOrTower(bot, enemyCreeps, enemyTowers) then
					if #allyCreeps >= 0 then
						printState('attacked by creep or tower move away');
						local loc = GetLaneFrontLocation(myTeam, lfarmLaneLocation, -700)
						bot:Action_MoveToLocation(loc);
						return	
					-- else
						-- print('attacked by tower or creep: attack ally')
						-- bot:Action_AttackUnit(allyCreeps[1], true);
						-- return;
					end	
				else	
					printState('waiting for last hit');
					bot:Action_MoveToLocation(bot.farmLaneLocation);
					return;
				end	
			end
		end
	end
end

function printState(cState)
	if state ~= cState then
		print(bot:GetUnitName().." "..cState);
		state = cState;
	end
end

function CanLastHitCreep(bot, creep)
	return creep:GetActualIncomingDamage(1.05*bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) >= creep:GetHealth()
end

function IsTargetedByCreepOrTower(bot, ecreeps, etowers)
	for i=1, #ecreeps do
		if ecreeps[i]:GetAttackTarget() == bot then
			return true;
		end
	end
	for i=1, #etowers do
		if etowers[i]:GetAttackTarget() == bot then
			return true;
		end
	end
	return false
end

function GetCreepToLastHit(bot, creeps, towers)
	for i=1, #creeps do
		if CanLastHitCreep(bot, creeps[i]) == true 
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetRangeCreeps(bot, creeps, towers)
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) and creeps[i]:GetAttackRange() > 150
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetRandomCreep(bot, creeps, towers)
	for i=1, #creeps do
		if (towers[1] == nil or (towers[1] ~= nil and GetUnitToUnitDistance(creeps[i], towers[1]) > 700) ) and creeps[i]:GetHealth() > 2*bot:GetAttackDamage()
		then
			return creeps[i];
		end
	end
	return nil;
end

function GetTargetCreepToAttack(bot, ecreeps, acreeps, etowers)
	local tgt = GetCreepToLastHit(bot, ecreeps, etowers)
	if tgt == nil then
		tgt = GetCreepToLastHit(bot, acreeps, etowers)
		if tgt == nil then
			tgt = GetRangeCreeps(bot, ecreeps, etowers)
			if tgt == nil and #ecreeps == 0 and etowers[1] ~= nil then
				tgt = etowers[1];
			end
		end
	end
	return tgt;
end

function GetClosestSafeLaneToFarm()
	local minDist = 100000;
	local loc = nil
	local lane = nil;
	for i=1, #lanes
	do
		local tFLoc = GetLaneFrontLocation(myTeam, lanes[i], -200);
		local eFLoc = GetLaneFrontLocation(enemyTeam, lanes[i], -200);
		local fDist = utils.GetDistance(tFLoc, eFLoc);
		local uDist = GetUnitToLocationDistance(bot, tFLoc);
		if ( fDist < 1000 or uDist < 1000 ) 
			and GetUnitToLocationDistance(eAncient, tFLoc) > 3000
			and uDist < minDist 
			and GetNEnemyAroundLocation(eFLoc, 1600, 10.0) == 0
		then
			minDist = uDist;
			loc = tFLoc;
			lane = lanes[i]
		end
	end
	return loc, minDist, lane;
end 

function GetSafeLocToFarmLane()
	local minDist = 100000;
	local loc = nil;
	for _,lane in pairs(lanes)
	do
		local tFLoc = GetLaneFrontLocation(myTeam, lane, 0);
		local eFLoc = GetLaneFrontLocation(enemyTeam, lane, 0);
		local fDist = utils.GetDistance(tFLoc, eFLoc);
		local uDist = GetUnitToLocationDistance(bot, tFLoc);
		if fDist <= 1000 
			and uDist < 3000
			and uDist < minDist 
			and GetNEnemyAroundLocation(eFLoc, 2000, 2.0) < 2 
		then
			minDist = uDist;
			loc = tFLoc;
		end
	end
	return loc, minDist;
end

function GetNEnemyAroundLocation(vLoc, nRadius, fTime)
	local nUnit = 0;
	for i,id in pairs(enemyPlayer) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil 
					and utils.GetDistance(vLoc, dInfo.location) <= nRadius 
					and dInfo.time_since_seen < fTime 
				then
					nUnit = nUnit + 1;
				end
			end
		end
	end
	return nUnit;
end

function GetWeakestUnit(units)
	local lowestHP = 10000;
	local lowestUnit = nil;
	for _,unit in pairs(units)
	do
		local hp = unit:GetHealth();
		if hp < lowestHP then
			lowestHP = hp;
			lowestUnit = unit;	
		end
	end
	return lowestUnit;
end

