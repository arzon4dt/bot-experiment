local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot()
local farmLoc = nil;

function GetDesire()
	--if ( bot:GetUnitName() == "npc_dota_hero_faceless_void" or bot:GetUnitName() == "npc_dota_hero_nevermore" ) and bot:GetLevel() >= 1 then
	if ( bot:GetAssignedLane() == LANE_MID ) then
		local closest_d = 100000;
		local closest = nil;
		for i = 1, 3 do
			local is = 2;
			local aFLoc = GetLaneFrontLocation(GetTeam(), is, 0);
			local dist = GetUnitToLocationDistance(bot, aFLoc);
			if dist < closest_d then
				closest_d = dist;
				closest = aFLoc;
			end
		end
		if closest ~= nil then
			farmLoc = closest;
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	end
end

function OnStart()

end

function OnEnd()

end

function GetWeakestCreep(creeps)
	local weakest = nil;
	local minHP = 100000;
	for _,creep in pairs(creeps) do
		local hp = creep:GetHealth();
		if hp < minHP then
			weakest = creep;
			minHP = hp;
		end
	end
	return weakest, minHP;
end

function GetCreepDamage(creeps, target)
	local sumDamage = 0;
	for _,creep in pairs(creeps) do
		if creep:GetAttackTarget() == target then
			local damage = creep:GetEstimatedDamageToTarget(true, target, creep:GetSecondsPerAttack(), DAMAGE_TYPE_PHYSICAL);
			sumDamage = sumDamage + damage;
		end
	end
	return 0;
end

function Think()

	local ecreeps = bot:GetNearbyLaneCreeps(1000, true);
	local acreeps = bot:GetNearbyLaneCreeps(1000, false);
	local tower = bot:GetNearbyTowers(1200, true);

	if GetUnitToLocationDistance(bot, farmLoc) > 600 then
		bot:Action_MoveToLocation(farmLoc)
		return
	else
		if #ecreeps > 0 then
			local etarget, ehp = GetWeakestCreep(ecreeps);
			if etarget ~= nil then
				local t = bot:GetSecondsPerAttack()+GetUnitToUnitDistance(etarget, bot)/bot:GetCurrentMovementSpeed();
				if bot:GetAttackRange() > 320 then
					t = bot:GetSecondsPerAttack()+GetUnitToUnitDistance(etarget, bot)/bot:GetAttackProjectileSpeed();
				end
				if not bot:IsFacingLocation(etarget:GetLocation(), 45) then
					t = t + 0.5;
				end
				--local cDamage = GetCreepDamage(acreeps, etarget);
				--print(tostring(cDamage))
				if bot:WasRecentlyDamagedByCreep(1.5) then
					bot:Action_MoveToLocation(GetAncient(GetTeam()):GetLocation());
					return	
				elseif #tower > 0 and ( tower[1]:GetAttackTarget() == bot or bot:WasRecentlyDamagedByTower(3.0) ) then
					bot:Action_MoveToLocation(GetAncient(GetTeam()):GetLocation());
					return	
				elseif bot:GetEstimatedDamageToTarget( true, etarget, t, DAMAGE_TYPE_PHYSICAL )  >= ehp then
					bot:Action_AttackUnit(etarget, true);
					return
				else	
					bot:Action_MoveToLocation(utils.VectorTowards(farmLoc, GetAncient(GetTeam()):GetLocation(), 300));
					return
				end
			else
				bot:Action_MoveToLocation(farmLoc);
				return
			end
		else
			bot:Action_MoveToLocation(farmLoc);
			return
		end
	end
end