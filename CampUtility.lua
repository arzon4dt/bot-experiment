X = {}


--[[ CAMP LIST
TEAM_RADIANT wait move time
[VScript] 2basic_0 --Large Camp Near Bot Shrine (-763.000000 -3267.000000 0.000000) (-642.000000 -4132.000000 0.000000) 55
[VScript] 2basic_1 --Medium Camp Closest To Base (-1822.000000 -4123.000000 0.000000) (-1871.000000 -2936.000000 0.000000) 55
[VScript] 2basic_2 --Medium Camp In Front Bot Ancient (595.000000 -4392.000000 0.000000) (801.000000 -3146.000000 0.000000) 55
[VScript] 2basic_3 --Large Camp Near Top Shrine (-4615.000000 -337.000000 0.000000) (-3481.000000 -1122.000000 0.000000) 55
[VScript] 2basic_4 --Large Camp Near Bot Side Shop (4818.000000 -4135.000000 0.000000) (5773.000000 -3071.000000 0.000000) 55
[VScript] 2basic_5 --Small Camp (3250.000000 -4575.000000 0.000000) (3570.000000 -5963.000000 0.000000) 54
[VScript] 2ancient_0 --Ancient Near Roshan (-2753.000000 -124.000000 0.000000) (-1872.000000 1141.000000 0.000000) 55
[VScript] 2basic_enemy_0
[VScript] 2basic_enemy_1
[VScript] 2basic_enemy_2
[VScript] 2basic_enemy_3
[VScript] 2basic_enemy_4
[VScript] 2basic_enemy_5
[VScript] 2basic_enemy_6
[VScript] 2basic_enemy_7
[VScript] 2ancient_enemy_0
[VScript] 2ancient_enemy_1
[VScript] 2ancient_enemy_2
TEAM_DIRE wait move time
[VScript] 3basic_0 --Large Camp Near Top Shrine (-357.000000 3535.000000 0.000000) (586.000000 4456.000000 0.000000) 55
[VScript] 3basic_1 --Small Camp (-3030.000000 5023.000000 0.000000) (-3457.000000 6297.000000 0.000000) 55
[VScript] 3basic_2 --Medium Camp Near Small Camp (-1601.000000 4160.000000 0.000000) (-955.000000 5121.000000 0.000000) 54
[VScript] 3basic_3 --Large Camp Near Top Side Shop (-4284.000000 3782.000000 0.000000) (-3050.000000 3434.000000 0.000000) 55
[VScript] 3basic_4 --Large Camp Near Bot Shrine (4138.000000 845.000000 0.000000) (3473.000000 1870.000000 0.000000) 55
[VScript] 3basic_5 --Medium Camp Closest To Base (1352.000000 3574.000000 0.000000) (2474.000000 5051.000000 0.000000) 55
[VScript] 3basic_6 --Medium Camp Near Bot Shrine (2885.000000 27.000000 0.000000) (3036.000000 -1168.000000 0.000000) 55
[VScript] 3basic_7 --Radiant Medium Camp Near Radiant Top Shrine ** (-3953.000000 721.000000 0.000000) (-5374.000000 446.000000 0.000000) 55
[VScript] 3ancient_0 --Ancient Near Roshan (-543.000000 2350.000000 0.000000) (957.000000 2295.000000 0.000000) 55
[VScript] 3ancient_1 --Radiant Ancient Near Radiant Bot Shrine ** (376.000000 -2122.000000 0.000000) (801.000000 -3146.000000 0.000000) 55
[VScript] 3ancient_2 --Ancient Near Bot Shrine (3784.000000 -876.000000 0.000000) (4071.000000 -2013.000000 0.000000) 55
[VScript] 3basic_enemy_0
[VScript] 3basic_enemy_1
[VScript] 3basic_enemy_2
[VScript] 3basic_enemy_3
[VScript] 3basic_enemy_4
[VScript] 3basic_enemy_5
[VScript] 3ancient_enemy_0
]]--


local RCStackTime = {54,55,55,55,55,54,55,55,55,54,55,55,55,55,55,55,55,55}
local RCStackLoc = {
	Vector(-642.000000,  -4132.000000, 0.000000),
	Vector(-1871.000000, -2936.000000, 0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(-3481.000000, -1122.000000, 0.000000),
	Vector(5773.000000,  -3071.000000, 0.000000),
	Vector(3570.000000,  -5963.000000, 0.000000),
	Vector(-1872.000000, 1141.000000,  0.000000),
	Vector(586.000000,   4456.000000,  0.000000),
	Vector(-3457.000000, 6297.000000,  0.000000),
	Vector(-955.000000,  5121.000000,  0.000000),
	Vector(-3050.000000, 3434.000000,  0.000000),
	Vector(3473.000000,  1870.000000,  0.000000),
	Vector(2474.000000,  5051.000000,  0.000000),
	Vector(3036.000000,  -1168.000000, 0.000000),
	Vector(-5374.000000, 446.000000,   0.000000),
	Vector(957.000000,   2295.000000,  0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(4071.000000,  -2013.000000, 0.000000)
}
local DCStackTime = {55,55,54,55,55,55,55,55,55,55,55,54,55,55,55,55,54,55}
local DCStackLoc = {
	Vector(586.000000,   4456.000000,  0.000000),
	Vector(-3457.000000, 6297.000000,  0.000000),
	Vector(-955.000000,  5121.000000,  0.000000),
	Vector(-3050.000000, 3434.000000,  0.000000),
	Vector(3473.000000,  1870.000000,  0.000000),
	Vector(2474.000000,  5051.000000,  0.000000),
	Vector(3036.000000,  -1168.000000, 0.000000),
	Vector(-5374.000000, 446.000000,   0.000000),
	Vector(957.000000,   2295.000000,  0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(4071.000000,  -2013.000000, 0.000000),
	Vector(-642.000000,  -4132.000000, 0.000000),
	Vector(-1871.000000, -2936.000000, 0.000000),
	Vector(801.000000,   -3146.000000, 0.000000),
	Vector(-3481.000000, -1122.000000, 0.000000),
	Vector(5773.000000,  -3071.000000, 0.000000),
	Vector(3570.000000,  -5963.000000, 0.000000),
	Vector(-1872.000000, 1141.000000,  0.000000)
}

function X.GetCampMoveToStack(team, id)
	if team == TEAM_RADIANT then
		return RCStackLoc[id];
	else
		return DCStackLoc[id];
	end
end

function X.GetCampStackTime(team, id)
	if team == TEAM_RADIANT then
		return RCStackTime[id];
	else
		return DCStackTime[id];
	end
end

return X