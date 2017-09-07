local X = {}

local team =  GetTeam();
local CStackTime = {55,55,55,55,55,54,55,55,55,55,55,55,55,55,55,55,55,55}
local CStackLoc = {
	Vector(-800.000000,  -5000.000000, 0.000000),
	Vector(-1871.000000, -2936.000000, 0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(-3481.000000, -1122.000000, 0.000000),
	Vector(5773.000000,  -3071.000000, 0.000000),
	Vector(3570.000000,  -5963.000000, 0.000000),
	Vector(-5374.000000, 446.000000,   0.000000),
	Vector(-1872.000000, 1141.000000,  0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(586.000000,   4456.000000,  0.000000),
	Vector(-3457.000000, 6297.000000,  0.000000),
	Vector(-955.000000,  5121.000000,  0.000000),
	Vector(-3050.000000, 3434.000000,  0.000000),
	Vector(3473.000000,  1870.000000,  0.000000),
	Vector(2474.000000,  5051.000000,  0.000000),
	Vector(3036.000000,  -1168.000000, 0.000000),
	Vector(957.000000,   2295.000000,  0.000000),
	Vector(4071.000000,  -2013.000000, 0.000000)
}

--test hero
local jungler = {
	'npc_dota_hero_alchemist',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_legion_commander',
	'npc_dota_hero_life_stealer'
	--'npc_dota_hero_skeleton_king',
	--'npc_dota_hero_ursa'
}

function X.GetCampMoveToStack(id)
	return CStackLoc[id]
end

function X.GetCampStackTime(camp)
	if camp.cattr.speed == "fast" then
		return 55;
	elseif camp.cattr.speed == "slow" then
		return 54;
	else
		return 55;
	end
end

function X.IsEnemyCamp(camp)
	return camp.team ~= GetTeam();
end

function X.IsAncientCamp(camp)
	return camp.type == "ancient";
end

function X.IsSmallCamp(camp)
	return camp.type == "small";
end

function X.IsMediumCamp(camp)
	return camp.type == "medium";
end

function X.IsLargeCamp(camp)
	return camp.type == "large";
end

function X.RefreshCamp(bot)
	local camps = GetNeutralSpawners();
	local AllCamps = {};
	for k,camp in pairs(camps) do
		if bot:GetLevel() <= 6 then
			if not X.IsEnemyCamp(camp) and not X.IsLargeCamp(camp) and not X.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		elseif bot:GetLevel() <= 10 then
			if not X.IsEnemyCamp(camp) and not X.IsAncientCamp(camp)
			then
				table.insert(AllCamps, {idx=k, cattr=camp});
			end
		else
			table.insert(AllCamps, {idx=k, cattr=camp});
		end
	end
	local nCamps = #AllCamps;
	return AllCamps, nCamps;
end

function X.IsStrongJungler(bot)
	local name = bot:GetUnitName();
	for _,n in pairs(jungler)
	do
		if name == n then
			return true;
		end
	end	
	return false;
end

function X.GetClosestNeutralSpwan(bot, AvailableCamp)
	local minDist = 10000;
	local pCamp = nil;
	for _,camp in pairs(AvailableCamp)
	do
	   local dist = GetUnitToLocationDistance(bot, camp.cattr.location);
	   if X.IsTheClosestOne(bot, dist, camp.cattr.location) and dist < minDist then
			minDist = dist;
			pCamp = camp;
	   end
	end
	return pCamp
end

function X.IsTheClosestOne(bot, bDis, loc)
	local dis = bDis;
	local closest = bot;
	for k,v in pairs(GetTeamPlayers(GetTeam()))
	do	
		local member = GetTeamMember(k);
		if  member ~= nil and not member:IsIllusion() and member:IsAlive() and member:GetActiveMode() == BOT_MODE_FARM then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist < dis then
				dis = dist;
				closest = member;
			end
		end
	end
	return closest:GetUnitName() == bot:GetUnitName();
end

function X.FindFarmedTarget(Creeps)
	local minHP = 10000;
	local target = nil;
	for _,creep in pairs(Creeps)
	do
		local hp = creep:GetHealth(); 
		--if team == TEAM_DIRE then print(tostring(creep:CanBeSeen())) end
		if creep ~= nil and not creep:IsNull() and creep:IsAlive() and hp < minHP then
			minHP = hp;
			target = creep;
		end
	end
	return target
end

function X.IsSuitableToFarm(bot)
	local mode = bot:GetActiveMode();
	if mode == BOT_MODE_RUNE
	   or mode == BOT_MODE_DEFEND_TOWER_TOP
	   or mode == BOT_MODE_DEFEND_TOWER_MID
	   or mode == BOT_MODE_DEFEND_TOWER_BOT
	   or mode == BOT_MODE_ATTACK
	then
		return false;
	end
	return true;
end

function X.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp)
	if preferedCamp ~= nil then
		for i = 1, #AvailableCamp
		do
			if AvailableCamp[i].cattr.location == preferedCamp.cattr.location or GetUnitToLocationDistance(bot,  AvailableCamp[i].cattr.location) < 300 then
				table.remove(AvailableCamp, i);
				--print("Updating available camp : "..tostring(#AvailableCamp))
				preferedCamp = nil;	
				return AvailableCamp, preferedCamp;
			end
		end
	end
end


return X

--[[
--RADIANT CAMP
[VScript] =======================
[VScript] max:Vector 00000000005D3140 [-29.500122 -2992.000000 639.999939]
[VScript] team:2
[VScript] location:Vector 0000000000258AD0 [-371.000000 -3374.000000 265.000000]
[VScript] type:large
[VScript] min:Vector 00000000005D3048 [-1204.000000 -3598.000000 -384.000000]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 000000000072F370 [-1472.000000 -3784.000000 608.000061]
[VScript] team:2
[VScript] location:Vector 00000000005D31B8 [-1806.244507 -4485.535156 256.000000]
[VScript] type:medium
[VScript] min:Vector 00000000005D31E8 [-2187.000000 -4640.000000 -384.000000]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 000000000072F4F0 [1112.000000 -4128.000000 512.000061]
[VScript] team:2
[VScript] location:Vector 000000000072F3C8 [384.000000 -4672.000000 519.999939]
[VScript] type:medium
[VScript] min:Vector 000000000072F3F8 [178.999939 -5093.500000 -384.000000]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 00000000009A19C8 [-4272.000000 96.000000 1096.000000]
[VScript] team:2
[VScript] location:Vector 00000000005D2FE0 [-4873.000000 -512.500000 263.999756]
[VScript] type:large
[VScript] min:Vector 00000000005D3010 [-5165.500000 -640.000000 112.500000]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 00000000009A1B90 [-3962.000000 4224.000000 384.500061]
[VScript] team:2
[VScript] location:Vector 00000000009A19F8 [-4448.000000 3456.000000 470.714874]
[VScript] type:large
[VScript] min:Vector 00000000009A1A28 [-4784.000000 3328.000244 -384.000000]
[VScript] speed:slow
[VScript] =======================
[VScript] max:Vector 00000000002FBA50 [3800.000000 -4048.000000 608.000000]
[VScript] team:2
[VScript] location:Vector 00000000009A1BC0 [2849.953857 -4557.562012 263.999878]
[VScript] type:small
[VScript] min:Vector 00000000005D3280 [2784.000000 -4912.000000 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 00000000002FBBA8 [-3474.999756 1088.000000 768.000061]
[VScript] team:2
[VScript] location:Vector 00000000002FBA80 [-3685.870605 871.857666 263.999939]
[VScript] type:medium
[VScript] min:Vector 00000000002FBAB0 [-4319.999512 192.000000 -383.999817]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 0000000000290EC0 [-2277.000000 207.999939 928.000000]
[VScript] team:2
[VScript] location:Vector 00000000002FBC00 [-3077.500000 -199.000000 393.000000]
[VScript] type:ancient
[VScript] min:Vector 00000000002FBC30 [-3203.500000 -643.500061 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 0000000000291018 [516.000000 -1593.750000 704.000000]
[VScript] team:2
[VScript] location:Vector 0000000000290EF0 [69.066162 -1851.600098 392.000000]
[VScript] type:ancient
[VScript] min:Vector 0000000000290F20 [-356.000000 -2292.000000 280.500000]
[VScript] speed:normal
--DIRE CAMP
[VScript] =======================
[VScript] max:Vector 00000000005D3248 [113.500000 3645.500000 735.000000]
[VScript] team:3
[VScript] location:Vector 00000000009A1A88 [-108.500000 3339.500000 393.000000]
[VScript] type:large
[VScript] min:Vector 00000000005D3218 [-768.000000 3232.000000 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 000000000028F0E8 [-2524.000244 5199.250000 512.000061]
[VScript] team:3
[VScript] location:Vector 000000000028EF50 [-2816.000000 4736.000000 393.000000]
[VScript] type:small
[VScript] min:Vector 000000000028EF80 [-3620.000244 4424.000000 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 0000000000260268 [-1264.000000 4302.000000 540.500061]
[VScript] team:3
[VScript] location:Vector 000000000028EFB8 [-1952.000000 4128.000000 280.000000]
[VScript] type:medium
[VScript] min:Vector 000000000028EFE8 [-2096.000000 3680.000000 77.000061]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 0000000000260458 [4738.593750 1088.000000 944.000000]
[VScript] team:3
[VScript] location:Vector 00000000002602C0 [4452.000000 840.000000 391.999878]
[VScript] type:large
[VScript] min:Vector 00000000002602F0 [4032.000000 511.999878 384.000000]
[VScript] speed:fast
[VScript] =======================
[VScript] max:Vector 0000000000765398 [4992.000000 -3872.000000 800.000000]
[VScript] team:3
[VScript] location:Vector 0000000000260350 [4804.000000 -4472.000000 264.000000]
[VScript] type:large
[VScript] min:Vector 00000000007652A0 [4016.000000 -4640.000000 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 0000000000765238 [1584.500000 3920.000000 1152.000000]
[VScript] team:3
[VScript] location:Vector 00000000007653F0 [1346.833252 3289.285156 391.999878]
[VScript] type:medium
[VScript] min:Vector 0000000000765420 [607.999939 3128.500000 -384.000000]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 00000000005DBBB0 [3284.000000 424.000000 448.000000]
[VScript] team:3
[VScript] location:Vector 00000000002B7B40 [2548.799561 92.937256 391.999878]
[VScript] type:medium
[VScript] min:Vector 00000000005DBAB8 [2320.000000 -160.000000 -384.000122]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 00000000002B7B70 [-288.000000 2752.000000 1144.500000]
[VScript] team:3
[VScript] location:Vector 00000000005DBC08 [-948.000000 2268.500000 391.999756]
[VScript] type:ancient
[VScript] min:Vector 00000000005DBC38 [-1034.875000 1967.999878 383.999756]
[VScript] speed:normal
[VScript] =======================
[VScript] max:Vector 0000000000803520 [4176.000000 -384.000000 400.000000]
[VScript] team:3
[VScript] location:Vector 00000000005DBA78 [3936.000000 -576.000000 295.644104]
[VScript] type:ancient
[VScript] min:Vector 0000000000291048 [3192.000000 -976.000000 -384.000000]
[VScript] speed:normal
]]--