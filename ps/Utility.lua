------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

Utility={}

Utility.Lanes={[1]=LANE_BOT,[2]=LANE_MID,[3]=LANE_TOP};

Utility.Locations = {
["TopRune"]= Vector(-1767,1233),
["BotRune"]= Vector(2597,-2014),
["Rosh"]= Vector(-2328,1765),
["RadiantShop"]= Vector(-4739,1263),
["DireShop"]= Vector(4559,-1554),
["BotShop"]= Vector(7253,-4128),
["TopShop"]= Vector(-7236,4444),
["DireAncient"]= Vector(5517,4981),
["RadiantAncient"]= Vector(-5860,-5328),

["RadiantBase"]= Vector(-7200,-6666),
["RBT1"]= Vector(4896,-6140),
["RBT2"]= Vector(-128,-6244),
["RBT3"]= Vector(-3966,-6110),
["RMT1"]= Vector(-1663,-1510),
["RMT2"]= Vector(-3559,-2783),
["RMT3"]= Vector(-4647,-4135),
["RTT1"]= Vector(-6202,1831),
["RTT2"]= Vector(-6157,-860),
["RTT3"]= Vector(-6591,-3397),
["RadiantTopShrine"]= Vector(-4229,1299),
["RadiantBotShrine"]= Vector(622,-2555),
["RadiantBotRune"]= Vector(1276,-4129),
["RadiantTopRune"]= Vector(-4351,200),

["DireBase"]= Vector(7137,6548),
["DBT1"]= Vector(6215,-1639),
["DBT2"]= Vector(6242,400),
["DBT3"]= Vector(-6307,3043),
["DMT1"]= Vector(1002,330),
["DMT2"]= Vector(2477,2114),
["DMT3"]= Vector(4197,3756),
["DTT1"]= Vector(-4714,6016),
["DTT2"]= Vector(0,6020),
["DTT3"]= Vector(3512,5778),
["DireTopShrine"]= Vector(-139,2533),
["DireBotShrine"]= Vector(4173,-1613),
["DireBotRune"]= Vector(3471,295),
["DireTopRune"]= Vector(-2821,4147),

["RadiantEasyAndMedium"]={
Vector(3197,-4647),
Vector(680,-4420),
Vector(-1728,-3928)
},
["RadiantHard"]={
Vector(-780,-3291),
Vector(4527,-4259)
},
["DireEasyAndMedium"]={
Vector(-3082,5169),
Vector(-1617,4056),
Vector(1061,3489)
},
["DireHard"]={
Vector(-382,3572),
Vector(-4377,3825)
}
};

------------------------------
-- SOME OTHER LOCATIONS:
-- SHOPS:
------------------------------
Utility.SIDE_SHOP_TOP = Vector(-7220,4430);
Utility.SIDE_SHOP_BOT = Vector(7249,-4113);
Utility.SECRET_SHOP_RADIANT = Vector(-4766,1316);
Utility.SECRET_SHOP_DIRE = Vector(4635,-1480);
Utility.ROSHAN = Vector(-2450, 1880);

Utility.RuneSpots={
RUNE_POWERUP_1,
RUNE_POWERUP_2,
RUNE_BOUNTY_1,
RUNE_BOUNTY_2,
RUNE_BOUNTY_3,
RUNE_BOUNTY_4
};

Utility.Shrines={SHRINE_BASE_1, SHRINE_BASE_2, SHRINE_BASE_3, SHRINE_BASE_4, SHRINE_BASE_5, SHRINE_JUNGLE_1, SHRINE_JUNGLE_2};

function Utility.GetDistance(s,t)
	return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

function Utility.VectorTowards(s,t,d)
	local f=t-s;
	f=f / Utility.GetDistance(f,Vector(0,0));
	return s+(f*d);
end

function Utility.GetTowerLocation(side,lane,n) --0 radiant 1 dire
	if (side==0) then
		if (lane==LANE_TOP) then
			if (n==1) then
				return Utility.Locations["RTT1"];
			elseif (n==2) then
				return Utility.Locations["RTT2"];
			elseif (n==3) then
				return Utility.Locations["RTT3"];
			end
		elseif (lane==LANE_MID) then
			if (n==1) then
				return Utility.Locations["RMT1"];
			elseif (n==2) then
				return Utility.Locations["RMT2"];
			elseif (n==3) then
				return Utility.Locations["RMT3"];
			end
		elseif (lane==LANE_BOT) then
			if (n==1) then
				return Utility.Locations["RBT1"];
			elseif (n==2) then
				return Utility.Locations["RBT2"];
			elseif (n==3) then
				return Utility.Locations["RBT3"];
			end
		end
	elseif(side==1) then
		if (lane==LANE_TOP) then
			if (n==1) then
				return Utility.Locations["DTT1"];
			elseif (n==2) then
				return Utility.Locations["DTT2"];
			elseif (n==3) then
				return Utility.Locations["DTT3"];
			end
		elseif (lane==LANE_MID) then
			if (n==1) then
				return Utility.Locations["DMT1"];
			elseif (n==2) then
				return Utility.Locations["DMT2"];
			elseif (n==3) then
				return Utility.Locations["DMT3"];
			end
		elseif (lane==LANE_BOT) then
			if (n==1) then
				return Utility.Locations["DBT1"];
			elseif (n==2) then
				return Utility.Locations["DBT2"];
			elseif (n==3) then
				return Utility.Locations["DBT3"];
			end
		end
	end
	return nil;
end



Utility.RadiantSafeSpots={
	Vector(4088,-3919),
	Vector(5153,-3784),
	Vector(2810,-5053),
	Vector(2645,-3814),
	Vector(724,-3003),
	Vector(1037,-5629),
	Vector(1271,-4128),
	Vector(-989,-5559),
	Vector(-780,-3919),
	Vector(-128,-2523),
	Vector(-2640,-2200),
	Vector(-1284,-962),
	Vector(-2032,364),
	Vector(-3545,-892),
	Vector(-5518,-1450),
	Vector(-4301,377),
	Vector(-5483,1633),
	Vector(-6152,-5664),
	Vector(-6622,-3666),
	Vector(-6413,-1651),
	Vector(-4814,-4242),
	Vector(-3379,-3073),
	Vector(-4283,-6091),
	Vector(-2441,-6056),
	Vector(5722,-2602),
	Vector(4595,-1540)
}

Utility.DireSafeSpots={
	Vector(-1912,2412),--
	Vector(-4405,4735),
	Vector(-2840,4194),
	Vector(-1319,4735),
	Vector(-980,3330),
	Vector(776,4229),
	Vector(11,2405),
	Vector(324,670),
	Vector(1480,1760),
	Vector(2236,3217),
	Vector(3079,1812),
	Vector(1958,-116),
	Vector(3375,242),
	Vector(3636,-1023),
	Vector(4957,1812),
	Vector(4914,434),
	Vector(5487,-1729),
	Vector(6026,5585),
	Vector(6339,3631),
	Vector(6113,1782),
	Vector(4653,4154),
	Vector(3219,2916),
	Vector(4070,5821),
	Vector(2036,5637),
	Vector(-3715,2246)
}


function Utility.Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

function Utility.GetWardingSpot(lane)
	team=GetTeam();
	
	local t1=Utility.GetLaneTower(Utility.GetOtherTeam(),lane,1);
	local t2=Utility.GetLaneTower(Utility.GetOtherTeam(),lane,2);
	if team==TEAM_RADIANT then
		if lane==LANE_BOT then
			if Utility.NotNilOrDead(t1) then
				return Vector(6250,-2659);
			elseif Utility.NotNilOrDead(t2) then
				return Vector(5070,-750);
			else
				return Vector(5077,785);
			end
		elseif lane==LANE_MID then
			if Utility.NotNilOrDead(t1) then
				return Vector(-465,310);
			else
				return Vector(-93,1812)
			end
		elseif lane==LANE_TOP then
			if Utility.NotNilOrDead(t1) then
				return Vector(-2825,3921);
			else
				return Vector(-1263,4704);
			end
		end
	else
		if lane==LANE_BOT then
			if Utility.NotNilOrDead(t1) then
				return Vector(5362,-4813);
			elseif not Utility.NotNilOrDead(Utility.GetLaneTower(Utility.GetOtherTeam(),LANE_MID,1)) then
				return Vector(-1045,-4581);
			else
				return Vector(2206,-3535);
			end
		elseif lane==LANE_MID then
--			if Utility.NotNilOrDead(t1) then
				return Vector(-695,-903);
--			else
--				return Vector(-173,-1069);
--			end
		elseif lane==LANE_TOP then
			if Utility.NotNilOrDead(t1) then
				return Vector(-6180,3624);
			elseif Utility.NotNilOrDead(t2) then
				return Vector(-5128,2065);
			else
				return Vector(-4386,-1245);
			end
		end
	end
end

function Utility.NotNilOrDead(unit)
	if unit==nil or unit:IsNull() then
		return false;
	end
	if unit:IsAlive() then
		return true;
	end
	return false;
end

function Utility.IsFacingLocation(hero,loc,delta)
	
	local face=hero:GetFacing();
	local move = loc - hero:GetLocation();
	
	move = move / (Utility.GetDistance(Vector(0,0),move));

	local moveAngle=math.atan2(move.y,move.x)/math.pi * 180;

	if moveAngle<0 then
		moveAngle=360+moveAngle;
	end
	local face=(face+360)%360;
	
	if (math.abs(moveAngle-face)<delta or math.abs(moveAngle+360-face)<delta or math.abs(moveAngle-360-face)<delta) then
		return true;
	end
	return false;
end

function Utility.GetSecretShop()
	local npcBot=GetBot();
	
	if GetTeam()==TEAM_RADIANT then
		local safeTower=Utility.GetLaneTower(Utility.GetOtherTeam(),LANE_BOT,1);
		
		if Utility.NotNilOrDead(safeTower) then
			return Utility.SECRET_SHOP_RADIANT;
		end
	else
		local safeTower=Utility.GetLaneTower(Utility.GetOtherTeam(),LANE_TOP,1);
		
		if Utility.NotNilOrDead(safeTower) then
			return Utility.SECRET_SHOP_DIRE;
		end
	end
	
	local loc=nil;
	if GetUnitToLocationDistance(npcBot,Utility.SECRET_SHOP_DIRE) < GetUnitToLocationDistance(npcBot,Utility.SECRET_SHOP_RADIANT) then
		return Utility.SECRET_SHOP_DIRE;
	else
		return Utility.SECRET_SHOP_RADIANT;
	end
end

function Utility.DropJunks()
	local npcBot=GetBot();

	if Utility.NumberOfItems()<=5 or npcBot:IsChanneling() then
		return;
	end
	
	item=Utility.IsItemAvailable("item_tpscroll");
	if npcBot:GetActiveMode()~=BOT_MODE_EVASIVE_MANEUVERS and item~=nil and (not item:IsFullyCastable()) then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
	
	item=Utility.IsItemAvailable("item_flask");
	if item~=nil then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
	
	item=Utility.IsItemAvailable("item_clarity");
	if item~=nil then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
	
	local item=Utility.IsItemAvailable("item_quelling_blade");
	if item~=nil then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
	
	item=Utility.IsItemAvailable("item_null_talisman");
	if item~=nil then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
	
	item=Utility.IsItemAvailable("item_poor_mans_shield");
	if item~=nil then
		npcBot:ActionImmediate_SellItem(item);
		return;
	end
end

function Utility.InitPathFinding()
	local npcBot=GetBot();
	-- use this only once for each hero

	-- keeps the path for my pathfinding
	npcBot.NextHop={};
	npcBot.PathfindingWasInitiated=false;
	-- creating the graph

	local SafeDist=2000;
	local safeSpots={};
	if GetTeam()==TEAM_RADIANT then
		safeSpots=Utility.RadiantSafeSpots;
	else
		safeSpots=Utility.DireSafeSpots;
	end
	
	
	--initialization
	local inf=100000;
	local dist={};
	npcBot.NextHop={}
	
	print("INits are done");
	for u,uv in pairs(safeSpots) do
		local q=true;
		dist[u]={};
		npcBot.NextHop[u]={};
		for v,vv in pairs(safeSpots) do
			if Utility.GetDistance(uv,vv)>SafeDist then
				dist[u][v]=inf;
			else
				q=false;
				dist[u][v]=Utility.GetDistance(uv,vv);
			end
			npcBot.NextHop[u][v]=v;
		end
		if q then
			print("There is an isolated vertex in safespots");
		end
	end
	
	--floyd algorithm (path is saved in NextHop)
	for k,_ in pairs(safeSpots) do
		for u,_ in pairs(safeSpots) do
			for v,_ in pairs(safeSpots) do
				if dist[u][v]>dist[u][k]+dist[k][v] then
					dist[u][v]=dist[u][k]+dist[k][v];
					npcBot.NextHop[u][v]=npcBot.NextHop[u][k];
				end
			end
		end
	end

	npcBot.PathfindingWasInitiated=true;
end

function Utility.InitPath()
	local npcBot=GetBot();
	npcBot.FinalHop=false;
	npcBot.LastHop=nil;
end

function Utility.MoveSafelyToLocation(dest)
	local npcBot=GetBot();


	if npcBot.NextHop==nil or #(npcBot.NextHop)==0 or npcBot.PathfindingWasInitiated==nil or (not npcBot.PathfindingWasInitiated) then
		--print(npcBot.NextHop,npcBot.PathfindingWasInitiated);
		Utility.InitPathFinding();
		npcBot:ActionImmediate_Chat("Path finding has been initiated",false);
	end
	
	local safeSpots=nil;
	local safeDist=2000;
	if dest==nil then
		print("PathFinding: No destination was specified");
		return;
	end

	if GetTeam()==TEAM_RADIANT then
		safeSpots=Utility.RadiantSafeSpots;
	else
		safeSpots=Utility.DireSafeSpots;
	end
	
	if npcBot.FinalHop==nil then
		npcBot.FinalHop=false;
	end
	
	
	local s=nil;
	local si=-1;
	local mindisS=100000;
	
	local t=nil;
	local ti=-1;
	local mindisT=100000;
	
	local CurLoc=npcBot:GetLocation();
	
	for i,spot in pairs(safeSpots) do
		if Utility.GetDistance(spot,CurLoc)<mindisS then
			s=spot;
			si=i;
			mindisS=Utility.GetDistance(spot,CurLoc);
		end
		
		if Utility.GetDistance(spot,dest)<mindisT then
			t=spot;
			ti=i;
			mindisT=Utility.GetDistance(spot,dest);
		end
	end
	
	if s==nil or t==nil then
		npcBot:ActionImmediate_Chat('Something is wrong with path finding.',true);
		return;
	end
	
	if GetUnitToLocationDistance(npcBot,dest)<safeDist or npcBot.FinalHop or mindisS+mindisT>GetUnitToLocationDistance(npcBot,dest) then
		npcBot:Action_MoveToLocation(dest);
		npcBot.FinalHop=true;
		return;
	end
	
	if si==ti then
		npcBot.FinalHop=true;
		npcBot:Action_MoveToLocation(dest);
		return;
	end

	
	if GetUnitToLocationDistance(npcBot,s)<500 and npcBot.LastHop==nil then
		npcBot.LastHop=si;
	end
	
	if mindisS>safeDist or npcBot.LastHop==nil then
		npcBot:Action_MoveToLocation(s);
		return;
	end
	
	if GetUnitToLocationDistance(npcBot,safeSpots[npcBot.NextHop[npcBot.LastHop][ti]])<500 then
		npcBot.LastHop=npcBot.NextHop[npcBot.LastHop][ti];
	end
	
	local newT=npcBot.NextHop[npcBot.LastHop][ti];
	
	npcBot:Action_MoveToLocation(safeSpots[newT]);
end

function Utility.NumberOfItems()
	local npcBot=GetBot();
	local n=0;
	
	for i = 0, 5, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			n=n+1;
		end
    end
	
	return n;
end

function Utility.GetOtherTeam()
	if GetTeam()==TEAM_RADIANT then
		return TEAM_DIRE;
	else
		return TEAM_RADIANT;
	end
	
end

function Utility.GetCenter(Heroes)
	if Heroes==nil or #Heroes==0 then
		return nil;
	end
	
	local sum=Vector(0.0,0.0);
	local hn=0.0;
	
	for _,hero in pairs(Heroes) do
		if hero~=nil and hero:IsAlive() then
			sum=sum+hero:GetLocation();
			hn=hn+1;
		end
	end
	return sum/hn;
end

function Utility.GetCenterOfCreeps(creeps)
	local center=Vector(0,0);
	local n=0.0;
	local meleeW=2;
	if creeps==nil or #creeps==0 then
		return nil;
	end
	
	for _,creep in pairs(creeps) do
		if (string.find(creep:GetUnitName(),"melee")~=nil) then
			center = center + (creep:GetLocation())*meleeW;
			n=n+meleeW;
		else
			n=n+1;
			center = center + creep:GetLocation();
		end
	end
	if n==0 then
		return nil;
	end
	center=center/n;
	
	return center;
end

function Utility.GetWeakestCreep(r)
	local npcBot = GetBot();
	
	local EnemyCreeps = npcBot:GetNearbyLaneCreeps(r,true);
	
	if EnemyCreeps==nil or #EnemyCreeps==0 then
		return nil,10000;
	end
	
	local WeakestCreep=nil;
	local LowestHealth=10000;
	
	for _,creep in pairs(EnemyCreeps) do
		if creep~=nil and creep:IsAlive() then
			if creep:GetHealth()<LowestHealth then
				LowestHealth=creep:GetHealth();
				WeakestCreep=creep;
			end
		end
	end
	
	return WeakestCreep,LowestHealth;
end


function Utility.GetOurEnemy()
	local npcBot=GetBot();
	
	local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_RETREAT);
	
	if Allies==nil or #Allies==0 then
		return nil;
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1300,true,BOT_MODE_NONE);
	
	if Enemies==nil or #Enemies==0 then
		return nil;
	end
	
	local Enemy=nil;
	local nTa=0;
	
	for _,enemy in pairs(Enemies) do
		local nt=0;
		for _,ally in pairs(Allies) do
			if ally:WasRecentlyDamagedByHero(enemy,3) then
				nt=nt+1;
			end
		end
		
		if nt>0 then
			local mydamage=npcBot:GetEstimatedDamageToTarget(true,enemy,4.5,DAMAGE_TYPE_ALL);
			if nTa<mydamage/enemy:GetHealth() then
				nTa=mydamage/enemy:GetHealth();
				Enemy=enemy;
			end
		end
	end
	
	return Enemy;
end

function Utility.GetLaneRacks(lane,bMelee)
	local i=0;
	if bMelee==true then
		i=i+1;
	end
	if lane==LANE_MID then
		i=i+2;
	end
	if lane==LANE_BOT then
		i=i+4;
	end
	return GetBarracks(Utility.GetOtherTeam(),i);
end

function Utility.GetWeakestHero(r)
	local npcBot = GetBot();
	
	local EnemyHeroes = npcBot:GetNearbyHeroes(r,true,BOT_MODE_NONE);
	
	if EnemyHeroes==nil or #EnemyHeroes==0 then
		return nil,10000;
	end
	
	local WeakestHero=nil;
	local LowestHealth=10000;
	
	for _,hero in pairs(EnemyHeroes) do
		if hero~=nil and hero:IsAlive() then
			if hero:GetHealth()<LowestHealth then
				LowestHealth=hero:GetHealth();
				WeakestHero=hero;
			end
		end
	end
	
	return WeakestHero,LowestHealth;
end

function Utility.GetHeroLevel()
    local npcBot = GetBot();
	return npcBot:GetLevel();
--    local respawnTable = {8, 10, 12, 14, 16, 26, 28, 30, 32, 34, 36, 46, 48, 50, 52, 54, 56, 66, 70, 74, 78,  82, 86, 90, 100};
--    local nRespawnTime = npcBot:GetRespawnTime() +1;
--    for k,v in pairs (respawnTable) do
--        if v == nRespawnTime then
--        return k;
--        end
--    end
end

function Utility.IsAvailable(unit)
    return unit == nil or not unit:IsAlive();
end

function Utility.TryToUpgradeAbility(AbilityName)
    local npcBot = GetBot();
    local ability = npcBot:GetAbilityByName(AbilityName);
    if ability:CanAbilityBeUpgraded() then
        ability:UpgradeAbility();
        return true;
    end
    return false;
end

function Utility.PositionAlongLane(lane)
	local npcBot=GetBot();
	
	local bestPos=0.0;
	local pos=0.0;
	local closest=0.0;
	local dis=20000.0;
	
	while (pos<1.0) do
		local thisPos = GetLocationAlongLane(lane,pos);
		if (Utility.GetDistance(thisPos,npcBot:GetLocation()) < dis) then
			dis=Utility.GetDistance(thisPos,npcBot:GetLocation());
			bestPos=pos;
		end
		pos = pos+0.01;
	end
	
	return bestPos;
end

function Utility.GetLaneTower(team,lane,i)
	if i>3 and i<6 then
		return GetTower(team,5+i);
	end
	local j=i-1;
	if lane==LANE_MID then
		j=j+3;
	elseif lane==LANE_BOT then
		j=j+6;
	end
	if (j<9 and j>-1 and (lane==LANE_BOT or lane==LANE_MID or lane==LANE_TOP)) then
		return GetTower(team,j);
	end
	
	return nil;
end

function Utility.NumberOfDeadTowers(team,lane)
	local s=0;
	for i=1,5,1 do
		local tower= Utility.GetLaneTower(team,lane,i);
		if not Utility.NotNilOrDead(tower) then
			s=s+1;
		end
	end
	return s;
end

function Utility.IsItemAvailable(item_name)
    local npcBot = GetBot();

    for i = 0, 5, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item:GetName() == item_name) then
				return item;
			end
		end
    end
    return nil;
end

--important items for delivery
function Utility.HasRecipe()
	 local npcBot = GetBot();

    for i = 6, 20, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if((string.find(item:GetName(),"recipe")~=nil) or (string.find(item:GetName(),"item_boots")~=nil)) then
				return true;
			end
			
			if(item:GetName()=="item_ward_observer" and item:GetCurrentCharges()>1) then
				return true;
			end
		end
    end
	
    return false;
end

function Utility.IsItemInInventory(item_name)
    local npcBot = GetBot();

    for i = 0, 5, 1 do
        local item = npcBot:GetItemInSlot(i);
		if (item~=nil) then
			if(item and item:GetName() == item_name) then
				return item;
			end
		end
    end
	
    return nil;
end

function Utility.IsInTowerRange(unit,enemy)
    local NearbyTowers = unit:GetNearbyTowers(900,enemy);
	local mindis=2000;
	local closesttower=nil;
    if(#NearbyTowers > 0) then
        for _,tower in pairs(NearbyTowers)
        do
            if(GetUnitToUnitDistance(tower,unit) < mindis) then
                closesttower=tower;
				mindis=GetUnitToUnitDistance(tower,unit);
            end
        end
    end
	
    return closesttower;
end

function Utility.GetTargetBuilding()
	local npcBot=GetBot();
	
	local WeakestRacks=nil;
	local LowestHealth=10000;
	
	for i=0,5,1 do
		local racks=GetBarracks(Utility.GetOtherTeam(),i);
		if racks~=nil and racks:IsAlive() and (not racks:IsInvulnerable()) and racks:CanBeSeen() and LowestHealth>racks:GetHealth() and GetUnitToUnitDistance(racks,npcBot)<850 then
			WeakestRacks=racks;
			LowestHealth=racks:GetHealth();
		end
	end
	
	if WeakestRacks~=nil then
		return WeakestRacks,LowestHealth;
	end
	
	LowestHealth=10000;
	
	local Towers=npcBot:GetNearbyTowers(900,true);
	if Towers~=nil and #Towers>0 then
		local Tower=nil;
		for _,tower in pairs(Towers) do
			if Utility.NotNilOrDead(tower) and (not tower:IsInvulnerable()) and tower:CanBeSeen() and tower:GetHealth()<LowestHealth then
				Tower=tower;
				LowestHealth=tower:GetHealth();
			end
		end
		
		if Tower~=nil then
			return Tower,LowestHealth;
		end
	end
	
	local ancient=GetAncient(Utility.GetOtherTeam());
	if ancient~=nil and GetUnitToUnitDistance(npcBot,ancient)<900 and (not ancient:IsInvulnerable()) and ancient:CanBeSeen() then
		return ancient,ancient:GetHealth();
	end
	
	LowestHealth=10000;
	local Shrine=nil;
	for _,i in pairs(Utility.Shrines) do
		local shrine=GetShrine(Utility.GetOtherTeam(),i);
		if Utility.NotNilOrDead(shrine) and GetUnitToUnitDistance(npcBot,shrine)<800 and shrine:CanBeSeen() and (not shrine:IsInvulnerable()) and shrine:GetHealth()<LowestHealth then
			Shrine=shrine;
			LowestHealth=shrine:GetHealth();
		end
	end
	
	if Shrine~=nil then
		return Shrine,LowestHealth;
	end

	return nil,10000;
end

Utility.Cores={
"npc_dota_hero_antimage",
"npc_dota_hero_juggernaut",
"npc_dota_hero_luna",
"npc_dota_hero_drow_ranger",
"npc_dota_hero_tiny",
"npc_dota_hero_nevermore",
"npc_dota_hero_mirana",
"npc_dota_hero_zuus",
"npc_dota_hero_furion",
"npc_dota_hero_obsidian_destroyer",
"npc_dota_hero_clinkz",
"npc_dota_hero_naga_siren",
"npc_dota_hero_morphling",
"npc_dota_hero_medusa",
"npc_dota_hero_juggernaut",
"npc_dota_hero_chaos_knight",
"npc_dota_hero_broodmother",
"npc_dota_hero_tinker",
"npc_dota_hero_silencer",
"npc_dota_hero_shredder",
"npc_dota_hero_alchemist",
"npc_dota_hero_arc_warden",
"npc_dota_hero_axe",
"npc_dota_hero_batrider",
"npc_dota_hero_beastmaster",
"npc_dota_hero_bloodseeker",
"npc_dota_hero_brewmaster",
"npc_dota_hero_centaur",
"npc_dota_hero_dark_seer",
"npc_dota_hero_death_prophet",
"npc_dota_hero_doom_bringer",
"npc_dota_hero_dragon_knight",
"npc_dota_hero_ember_spirit",
"npc_dota_hero_enchantress",
"npc_dota_hero_faceless_void",
"npc_dota_hero_gyrocopter",
"npc_dota_hero_huskar",
"npc_dota_hero_invoker",
"npc_dota_hero_kunkka",
"npc_dota_hero_legion_commander",
"npc_dota_hero_leshrac",
"npc_dota_hero_life_stealer",
"npc_dota_hero_luna",
"npc_dota_hero_lone_druid",
"npc_dota_hero_lycan",
"npc_dota_hero_magnataur",
"npc_dota_hero_medusa",
"npc_dota_hero_meepo",
"npc_dota_hero_monkey_king",
"npc_dota_hero_necrolyte",
"npc_dota_hero_night_stalker",
"npc_dota_hero_phantom_assassin",
"npc_dota_hero_phantom_lancer",
"npc_dota_hero_puck",
"npc_dota_hero_razor",
"npc_dota_hero_nevermore",
"npc_dota_hero_slardar",
"npc_dota_hero_slark",
"npc_dota_hero_sniper",
"npc_dota_hero_spectre",
"npc_dota_hero_storm_spirit",
"npc_dota_hero_sven",
"npc_dota_hero_templar_assassin",
"npc_dota_hero_terrorblade",
"npc_dota_hero_tidehunter",
"npc_dota_hero_troll_warlord",
"npc_dota_hero_ursa",
"npc_dota_hero_viper",
"npc_dota_hero_weaver",
"npc_dota_hero_windrunner",
"npc_dota_hero_skeleton_king"
}

function Utility.IsCore(hero)
	if hero.isCore~=nil then
		return hero.isCore;
	end
	name=hero:GetUnitName();
	for _,hn in pairs(Utility.Cores)
	do
		if name==hn then
			hero.isCore=true;
			return true;
		end
	end
	hero.isCore=false;
	return false;
end

function Utility.EnemiesNearLocation(loc,dist)
	if loc ==nil then
		return {};
	end
	
	local Enemies={};
	
	for _,enID in pairs(GetTeamPlayers(GetTeam())) do
		local enemyInfo=GetHeroLastSeenInfo(enID);
		
		if IsHeroAlive(enID) and Utility.GetDistance(enemyInfo['location'],loc)<=dist and enemyInfo['time']<30 then
			table.insert(Enemies,enemy);
		end
	end
	
	return Enemies;
end

function Utility.AreRacksUp(lane)
	return Utility.NotNilOrDead(Utility.GetLaneRacks(lane,false)) or Utility.NotNilOrDead(Utility.GetLaneRacks(lane,true));
end

function Utility.ConsiderChangingLane(CurLane)
	local npcBot=GetBot();
	local p=false;
	
	
	local MyLaneFront=Min(GetLaneFrontAmount(Utility.GetOtherTeam(),CurLane,true),GetLaneFrontAmount(GetTeam(),CurLane,true));
	if MyLaneFront<0.6 then
		return CurLane;
	end
	
	if not Utility.AreRacksUp(CurLane) then
		p=true;
		if Utility.AreRacksUp(LANE_MID) then
			print(npcBot:GetUnitName(),'is changing lane.');
			return LANE_MID;
		end
		
		for _,lane in pairs(Utility.Lanes) do
			if Utility.AreRacksUp(lane) then
				print(npcBot:GetUnitName(),'is changing lane.');
				return lane;
			end
		end
	end
	
	if (p) then
		return LANE_MID;
	end
	
	return CurLane; 
end

function Utility.UseItems()
	local npcBot = GetBot();
	
	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() then
		return -1;
	end
	
	local courier=Utility.IsItemAvailable("item_courier");
	if courier~=nil and courier:IsFullyCastable() then
		npcBot:Action_UseAbility(courier);
		return -1;
	end
	
	
	local flyingCourier=Utility.IsItemAvailable("item_flying_courier");
	if flyingCourier~=nil and flyingCourier:IsFullyCastable() then
		npcBot:Action_UseAbility(flyingCourier);
		return -1;
	end
	
	local phase=Utility.IsItemAvailable("item_phase_boots");
	if phase~=nil and phase:IsFullyCastable() then
		npcBot:Action_UseAbility(phase);
		return -1;
	end


	local flask=Utility.IsItemAvailable("item_flask");
    if flask~=nil and flask:IsFullyCastable() then
		local Enemies=npcBot:GetNearbyHeroes(750,true,BOT_MODE_NONE);
		
		if Enemies==nil or #Enemies==0 then
			if npcBot:GetMaxHealth()-npcBot:GetHealth()>330 and (npcBot.FlaskTimer==nil or DotaTime()-npcBot.FlaskTimer>2) and (not npcBot:HasModifier("modifier_flask_healing")) and (not npcBot:WasRecentlyDamagedByAnyHero(1.5)) and GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))>3000 then
				npcBot.FlaskTimer=DotaTime();
				npcBot:Action_UseAbilityOnEntity(flask,npcBot);
				return -1;
			end
		end
	end
	
	local Enemies=npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);

	
	local hood=Utility.IsItemAvailable("item_hood_of_defiance");
    if hood~=nil and hood:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.6 and (Enemies~=nil and #Enemies>0)then
		npcBot:Action_UseAbility(hood);
		return -1;
	end
	
	local pipe=Utility.IsItemAvailable("item_pipe");
    if pipe~=nil and pipe:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.6 and (Enemies~=nil and #Enemies>0) then
		npcBot:Action_UseAbility(pipe);
		return -1;
	end
	
	local cg=Utility.IsItemAvailable("item_crimson_guard");
    if cg~=nil and cg:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.65 and (Enemies~=nil and #Enemies>0) then
		npcBot:Action_UseAbility(cg);
		return -1;
	end
	
	local shiva=Utility.IsItemAvailable("item_shivas_guard");
    if shiva~=nil and shiva:IsFullyCastable() and ((Enemies~=nil and #Enemies>2) or npcBot:GetActiveMode()==BOT_MODE_ATTACK or npcBot:GetHealth()/npcBot:GetMaxHealth()<0.4) then
		npcBot:Action_UseAbility(shiva);
		return -1;
	end
	
	local rod=Utility.IsItemAvailable("item_rod_of_atos");
	if rod~=nil and rod:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_ATTACK and npcBot.Target~=nil and GetUnitToUnitDistance(npcBot,npcBot.Target)<=1000 then
		npcBot:Action_UseAbilityOnEntity(rod,npcBot.Target);
		return -1;
	end
	
	local lotus=Utility.IsItemAvailable("item_lotus_orb");

	if lotus~=nil and lotus:IsFullyCastable() and ((npcBot:GetHealth()/npcBot:GetMaxHealth()<0.45 and (Enemies~=nil and #Enemies>0)) or npcBot:IsSilenced() or (#Enemies~=nil and #Enemies>3 and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.65)) then
		npcBot:Action_UseAbilityOnEntity(lotus,npcBot);
		return -1;
	end
	
	if lotus~=nil and lotus:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if ((Ally:GetHealth()/Ally:GetMaxHealth()<0.35 and (Enemies~=nil and #Enemies>0)) or Ally:IsSilenced()) then
				npcBot:Action_UseAbilityOnEntity(lotus,Ally);
				return -1;
			end
		end
	end
	

	
	local se=Utility.IsItemAvailable("item_silver_edge");
    if se~=nil and se:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_RETREAT and GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))>1500 then
		npcBot:Action_UseAbility(se);
		npcBot.SBTimer=DotaTime();
		return DotaTime();
	end
	
	local sb=Utility.IsItemAvailable("item_invis_sword");
    if sb~=nil and sb:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_RETREAT and GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))>1500 then
		npcBot:Action_UseAbility(sb);
		npcBot.SBTimer=DotaTime();
		return DotaTime();
	end
	
	
	if (npcBot:GetActiveMode())==BOT_MODE_RETREAT then
		return -1;
	end
	
	local clarity=Utility.IsItemAvailable("item_clarity");
    if clarity~=nil and clarity:IsFullyCastable() then
		local Enemies=npcBot:GetNearbyHeroes(700,true,BOT_MODE_NONE);
		if Enemies==nil or #Enemies==0 then
			if (npcBot.ClarityTimer==nil or DotaTime()-npcBot.ClarityTimer>2) and npcBot:GetMaxMana()-npcBot:GetMana()>64 and (not npcBot:HasModifier("modifier_clarity_potion")) and (not npcBot:WasRecentlyDamagedByAnyHero(1.5)) and GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))>3000 then
				npcBot:Action_UseAbilityOnEntity(clarity,npcBot);
				npcBot.ClarityTimer=DotaTime();
				return -1;
			end
		end
	end
	
	local arcane=Utility.IsItemAvailable("item_arcane_boots");
    if arcane~=nil and arcane:IsFullyCastable() then
		if npcBot:GetMaxMana()-npcBot:GetMana()>160 then
			npcBot:Action_UseAbility(arcane);
			return -1;
		end
	end
	
	local veil=Utility.IsItemAvailable("item_veil_of_discord");
    if veil~=nil and veil:IsFullyCastable() then
		local Enemies=npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		
		if Enemies~=nil and #Enemies~=0 then
			local cpos=Utility.GetCenter(Enemies);
		
			npcBot:Action_UseAbilityOnLocation(veil,cpos);
			return -1;
		end
	end
	
	local drums=Utility.IsItemAvailable("item_ancient_janggo");
    if drums~=nil and drums:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_PUSH_TOWER_MID and drums:GetCurrentCharges()>0 then
		npcBot:Action_UseAbility(drums);
		return -1;
	end
	
	local tp=Utility.IsItemAvailable("item_tpscroll");
	if tp~=nil then
		local dest=GetLocationAlongLane(npcBot.CurLane,0.5);
		if tp:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_LANING and GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))<2000 then
			npcBot:Action_UseAbilityOnLocation(tp,dest);
		elseif not (npcBot:IsUsingAbility() or npcBot:IsChanneling() or npcBot:GetActiveMode()==BOT_MODE_EVASIVE_MANEUVERS) then
			npcBot:ActionImmediate_SellItem(tp);
		end
	end
	
	local hod=Utility.IsItemAvailable("item_helm_of_the_dominator");
    if hod~=nil and hod:IsFullyCastable() and npcBot:GetActiveMode()==BOT_MODE_PUSH_TOWER_MID then
		local creeps=npcBot:GetNearbyLaneCreeps(700,true);
		for _,creep in pairs(creeps) do
			if string.find(creep:GetUnitName(),"siege")~=nil then
				npcBot:Action_UseAbilityOnEntity(hod,creep);
				return -1;
			end
		end
	end
end

function Utility.AreTreesBetween(loc,r)
	local npcBot=GetBot();
	
	local trees=npcBot:GetNearbyTrees(GetUnitToLocationDistance(npcBot,loc));
	--check if there are trees between us
	for _,tree in pairs(trees) do
		local x=GetTreeLocation(tree);
		local y=npcBot:GetLocation();
		local z=loc;
		
		if x~=y then
			local a=1;
			local b=1;
			local c=0;
		
			if x.x-y.x ==0 then
				b=0;
				c=-x.x;
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end
		
			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b));
			if d<=r and GetUnitToLocationDistance(npcBot,loc)>Utility.GetDistance(x,loc)+50 then
				return true;
			end
		end
	end
	return false;
end

function Utility.IsRealHero(unit)
	if unit.isIllusion~=nil and unit.isIllusion then
		return false;
	end
	return true;
end

function Utility.GetRealHero(Candidates)
	if Candidates==nil or #Candidates==0 then
		return nil;
	end
	
	local q=false;
	for i,unit in pairs(Candidates) do
		if unit.isIllusion==nil or (not unit.isIllusion) then
			q=true;
		end
	end
	
	if not q then
		for i,unit in pairs(Candidates) do
			if unit.isRealHero~=nil and unit.isRealHero then
				return i,unit;
			end
		end
		return nil;
	end
	
	for i,unit in pairs(Candidates) do
		if unit:HasModifier("modifier_bloodseeker_thirst_vision") then
			return i,unit;
		end
	end
	
	for i,unit in pairs(Candidates) do
		local int = unit:GetAttributeValue(2);
		local baseRegen=0.01;
		if unit:GetUnitName()==npc_dota_hero_techies then
			baseRegen=0.02;
		end
		
		if math.abs(unit:GetManaRegen()-(baseRegen+0.04*int))>0.001 then
			return i,unit;
		end
	end
	
	local hpRegen=Candidates[1]:GetHealthRegen();
	local suspectind=1;
	local suspect=Candidates[1];
	
	for i,unit in pairs(Candidates) do
		if hpRegen<unit:GetHealthRegen() then
			suspect=unit;
			hpRegen=unit:GetHealthRegen();
			suspectind=i;
		end
	end
	
	for _,unit in pairs(Candidates) do
		if hpRegen>unit:GetHealthRegen() then
			return suspectind,suspect;
		end
	end
	
	for i,unit in pairs(Candidates) do
		if unit:IsUsingAbility() or unit:IsChanneling() then
			return i,unit;
		end
	end
	
	if #Candidates==1 and (Candidates[1].isIllusion==nil or (not Candidates[1].isIllusion)) then
		return 1,Candidates[1];
	end
	
	return nil;
end

Utility.EnemyHeroListTimer=-1000;
Utility.EnemyHeroList=nil;

function Utility.GetEnemyTeam()
	if Utility.EnemyHeroList~=nil and DotaTime()-Utility.EnemyHeroListTimer<0.01 then
		return Utility.EnemyHeroList;
	end
	
	Utility.EnemyHeroListTimer=DotaTime();
	Utility.EnemyHeroList={}
	
	for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		local q=false;
		for _,unit2 in pairs(Utility.EnemyHeroList) do
			if unit2:GetUnitName()==unit:GetUnitName() then
				q=true;
			end
		end
		
		if not q then
			local skip=false;
			if not Utility.NotNilOrDead(unit) then
				skip=true;
			end
--			if unit.isRealHero~=nil and unit.isRealHero then
--				table.insert(Utility.EnemyHeroList,unit);
--				skip=true;
--			end
--			if unit.isIllusion~=nil and unit.isIllusion then
--				skip=true;
--			end
		
			if not skip then
				local candidates={};
				for _,unit2 in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
					if Utility.NotNilOrDead(unit2) and unit2:GetUnitName() == unit:GetUnitName() then
						table.insert(candidates,unit2);
					end
				end
			
				local ind,hero=Utility.GetRealHero(candidates);
				if hero~=nil and (hero.isIllusion==nil or (not hero.isIllusion)) then
					for _,can in pairs(candidates) do
						can.isIllusion=true;
						can.isRealHero=false;
					end
					
					hero.isIllusion=false;
					hero.isRealHero=true;
					
					table.insert(Utility.EnemyHeroList,hero);
				end
			end
		end
	end

	return Utility.EnemyHeroList;
end

function Utility.FindTarget(dist)
	--npcBot:GetEstimatedDamageToTarget( true, WeakestCreep, AttackSpeed, DAMAGE_TYPE_PHYSICAL )
	local npcBot=GetBot();
	
	local mindis=100000;
	local candidate=nil;
	local MaxScore=-1;
	local damage=0;
	
	local Enemies=npcBot:GetNearbyHeroes(dist,true,BOT_MODE_NONE);
	
	if Enemies==nil or #Enemies==0 then
		return nil,0.0,0.0;
	end
	
	local Towers=npcBot:GetNearbyTowers(1100,true);
	local AlliedTowers=npcBot:GetNearbyTowers(950,false);
	local AlliedCreeps=npcBot:GetNearbyLaneCreeps(1000,false);
	local EnemyCreeps=npcBot:GetNearbyLaneCreeps(700,true);
	local nEc=0;
	local nAc=0;
	if AlliedCreeps~=nil then
		nAc=#AlliedCreeps;
	end
	if EnemyCreeps~=nil then
		nEc=#EnemyCreeps;
	end
	
	local nTo=0;
	if Towers~=nil then
		nTo=#Towers;
	end
	
	local fTo=0;
	if AlliedTowers~=nil then
		fTo=#AlliedTowers;
	end
	
	local lvl=Utility.GetHeroLevel();
	if lvl==nil then
		lvl=25;
	end
	
	local ShredderAQDamage={100,150,200,250};
	
	for _,enemy in pairs(Enemies) do
		if Utility.NotNilOrDead(enemy) and enemy:GetHealth()>0 and GetUnitToLocationDistance(enemy,Utility.Fountain(Utility.GetOtherTeam()))>1350 
		and Utility.IsRealHero(enemy) then
			local myDamage=npcBot:GetEstimatedDamageToTarget(true,enemy,4.5,DAMAGE_TYPE_ALL);
			
			if string.find(npcBot:GetUnitName(),"shredder")~=nil then
				local shq=npcBot:GetAbilityByName("shredder_whirling_death");
				if shq~=nil and shq:IsFullyCastable() then
					if npcBot:GetMana()<400 then
						myDamage=myDamage + ShredderAQDamage[shq:GetLevel()];
					else
						myDamage=myDamage + ShredderAQDamage[shq:GetLevel()]*2;
					end
				end
			end

			local nfriends=0;
			for _,enemy2 in pairs(Utility.GetEnemyTeam()) do
				if Utility.NotNilOrDead(enemy2) and enemy2:GetHealth()>0 then
					if GetUnitToUnitDistance(enemy,enemy2)<1200 and enemy2:GetHealth()/enemy2:GetMaxHealth()>0.4 then
						nfriends=nfriends+1;
					end
				end
			end
			
			local nMyFriends=0;
			for j =1,5,1 do
				local Ally=GetTeamMember(j);
				if Utility.NotNilOrDead(Ally) and GetUnitToUnitDistance(enemy,Ally)<1200 then
					if Ally:GetActiveMode()==BOT_MODE_RETREAT then
						nMyFriends=nMyFriends+3;
					else
						nMyFriends=nMyFriends+1.1;
					end
				end
			end
			
			local score= Min(myDamage/enemy:GetHealth(),4) + (nMyFriends)/1.7 - (nfriends)/1.7 - GetUnitToUnitDistance(enemy,npcBot)/3500 -(1-npcBot:GetHealth()/npcBot:GetMaxHealth()) - nTo/(Min(lvl/8,3)) + fTo/(Min(lvl/8,3)) - nEc/(2*lvl) + nAc/(2*lvl);
			if score>MaxScore then
				damage=myDamage;
				candidate=enemy;
				MaxScore=score;
			end
		end
	end
	
	return candidate,damage,MaxScore;
end

function Utility.UseCourier()
	local npcBot=GetBot();
	local cnum=GetNumCouriers();
	
	local courier = nil;
	
	for i=0,cnum-1,1 do
		local cour=GetCourier(i);
		if Utility.NotNilOrDead(cour) and (GetCourierState(cour)==COURIER_STATE_IDLE or GetCourierState(cour)==COURIER_STATE_AT_BASE) then
			courier=cour;
		end
		
		if cour~=nil and (not cour:IsAlive()) then
			cour.IsGoingToSecretShop=false;
			cour.SecretShopTimer=-1000;
		end
	end
	
	if courier==nil then
		return;
	end
	
	if courier.IsGoingToSecretShop==nil then
		courier.IsGoingToSecretShop=false;
		courier.SecretShopTimer=-1000;
	end
	
	if npcBot.CourierTimer==nil then
		npcBot.CourierTimer=-1000;
	end
	
--	print("--------");
--	print(npcBot:GetUnitName(),npcBot:GetStashValue(),npcBot:GetCourierValue(),Utility.HasRecipe(),IsCourierAvailable(),(DotaTime()-npcBot.CourierTimer),courier.IsGoingToSecretShop,(GetCourierState(cour)==COURIER_STATE_AT_BASE),(GetCourierState(cour)==COURIER_STATE_IDLE))
--	-----------------
	
	if (npcBot:IsAlive() and (npcBot:GetStashValue()>900 or npcBot:GetCourierValue()>0 or Utility.HasRecipe())) and (npcBot.CourierTimer==nil or DotaTime()-npcBot.CourierTimer>2) and (not courier.IsGoingToSecretShop) then
		npcBot:ActionImmediate_Courier(courier,6);
		npcBot.CourierTimer=DotaTime();
		return;
	end
	
	if	npcBot.ItemsToBuy==nil or #npcBot.ItemsToBuy==0 or (npcBot.IsGoingToShop~=nil and npcBot.IsGoingToShop) then
		return;
	end
	
	local NextItem=npcBot.ItemsToBuy[1];

	local secLoc=nil;
	if GetTeam()==TEAM_RADIANT then
		secLoc=Utility.SECRET_SHOP_RADIANT;
	else
		secLoc=Utility.SECRET_SHOP_DIRE;
	end
	
	
	if (not IsItemPurchasedFromSecretShop(NextItem)) or (npcBot:GetGold() < GetItemCost(NextItem)) or (npcBot.IsGoingToShop~=nil and npcBot.IsGoingToShop)
	or ((IsItemPurchasedFromSideShop(NextItem) and npcBot:DistanceFromSideShop()<4000) and GetUnitToLocationDistance(courier,secLoc)>300) then
		return;
	end
	
	secLoc=Utility.GetSecretShop();
	
	if IsItemPurchasedFromSecretShop(NextItem) then
		if GetUnitToLocationDistance(npcBot,secLoc)>4700 and DotaTime()-courier.SecretShopTimer>2 then
			npcBot:ActionImmediate_Courier(courier,COURIER_ACTION_SECRET_SHOP);
			courier.IsGoingToSecretShop=true;
			courier.SecretShopTimer=DotaTime();
			return;
		end
		
		if GetTeam()==TEAM_RADIANT then
			secLoc=Utility.SECRET_SHOP_RADIANT;
		else
			secLoc=Utility.SECRET_SHOP_DIRE;
		end
		if GetUnitToLocationDistance(courier,secLoc)<300 then
			courier.IsGoingToSecretShop=false;
			courier.SecretShopTimer=-1000;
			courier:ActionImmediate_PurchaseItem( NextItem );
			table.remove( npcBot.ItemsToBuy, 1 );
			return;
		end
	end
end

return Utility;