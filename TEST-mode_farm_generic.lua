local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot()
local minute = 0;
local sec = 0;

function GetDesire()
	
	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	if string.find(bot:GetUnitName(), "bloodseeker") then
		return BOT_MODE_DESIRE_HIGH;
	end
	
	return 0.0
end

function Think()
	
	if DotaTime() < 30 then
		bot:Action_MoveToLocation(Vector(3500, -5200));
		return
	else
		local camp = GetClosestNeutralSpwan()
		if GetUnitToLocationDistance(bot, camp) > 400 then
			bot:Action_MoveToLocation(camp);
			return
		else
			local farmTarget = FindFarmedTarget()
			if farmTarget ~= nil then
				if sec >= 55 then
					bot:Action_MoveToLocation(VectorAway(bot:GetLocation(), camp, 800));
					return
				else
					bot:Action_AttackUnit(farmTarget, true);
					return
				end
			end
		end
	end
	
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function VectorAway(start, towards, distance)
    local facing = start - towards
    local direction = facing / GetDistance(facing, Vector(0,0)) --normalized
    return start + (direction * distance)
end

function FindFarmedTarget()
	local minHP = 10000;
	local target = nil;
	local neutralCreeps = bot:GetNearbyNeutralCreeps(400);
	for _,creep in pairs(neutralCreeps)
	do
		local hp = creep:GetHealth(); 
		if hp < minHP then
			minHP = hp;
			target = creep;
		end
	end
	return target
end

function GetClosestNeutralSpwan()
	local minDist = 10000;
	local pCamp = nil;
	local neutralSpawn  = GetNeutralSpawners();
	for _,camp in pairs(neutralSpawn)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.location);
	   if dist < minDist then
			minDist = dist;
			pCamp = camp.location;
	   end
	end
	return pCamp
end