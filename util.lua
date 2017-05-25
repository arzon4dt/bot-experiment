local utilsModule = {}

local vec = require(GetScriptDirectory() .."/Vectors")
local BotData = require(GetScriptDirectory() .."/BotData")

utilsModule["tableNeutralCamps"] = vec.tableNeutralCamps  -- constant - shouldn't be modified runtime use X.jungle instead
utilsModule["tableRuneSpawns"] = vec.tableRuneSpawns
utilsModule.Roles = BotData.Roles
----------------------------------------------------------------------------------------------------

CDOTA_Bot_Script.AttackPower = 0
CDOTA_Bot_Script.MagicPower = 0
CDOTA_Bot_Script.Role = 0
CDOTA_Bot_Script.NeedsHelp = false
CDOTA_Bot_Script.CanHelp = true
CDOTA_Bot_Script.IsReady = false
CDOTA_Bot_Script.IsFighting = false
CDOTA_Bot_Script.LostCause = false
CDOTA_Bot_Script.hasGlobal = false
CDOTA_Bot_Script.missing = true
CDOTA_Bot_Script.NearbyFriends = {}
CDOTA_Bot_Script.NearbyEnemies = {}
----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetForwardVector()
    local radians = self:GetFacing() * math.pi / 180
    local forward_vector = Vector(math.cos(radians), math.sin(radians))
    return forward_vector
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:IsFacingUnit( hTarget, degAccuracy )
    local direction = (hTarget:GetLocation() - self:GetLocation()):Normalized()
    local dot = direction:Dot(self:GetForwardVector())
    local radians = degAccuracy * math.pi / 180
    return dot > math.cos(radians)
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetXUnitsTowardsLocation( vLocation, nUnits)
    local direction = (vLocation - self:GetLocation()):Normalized()
    return self:GetLocation() + direction * nUnits
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetXUnitsInFront( nUnits )
    return self:GetLocation() + self:GetForwardVector() * nUnits
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetNearestNeutrals( tCamps )
    local closestDistance = 1000000;
    local closestCamp;
    for k,v in ipairs(tCamps) do
        if v ~= nil and GetUnitToLocationDistance( self, v[VECTOR] ) < closestDistance then
            closestDistance = GetUnitToLocationDistance( self, v[VECTOR] )
            closestCamp = v
        end
    end
    return closestCamp
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetNearest( tVecs )
    local closestDistance = 1000000;
    local closestCamp;
    for k,v in ipairs(tVecs) do
        if v ~= nil and GetUnitToLocationDistance( self, v ) < closestDistance then
            closestDistance = GetUnitToLocationDistance( self, v )
            closestCamp = v
        end
    end
    return closestCamp
end

----------------------------------------------------------------------------------------------------

function CDOTA_Bot_Script:GetLocationDanger()
    return utilsModule.GetLocationDanger(self:GetLocation())
end

----------------------------------------------------------------------------------------------------
--check if a path from nloc1 to nloc2 that is nWidth wide is clear of units
function CDOTA_Bot_Script:IsSkillPathClear( vTargetLoc, nWidth, bFriends)
    local heroWidth = 24 --this isn't true for lycan/naga/pl who are 8
    local dist = heroWidth + nWidth + 1
    local pointcount = math.floor(GetUnitToLocationDistance(self, vTargetLoc) / nWidth - 2)
    print(pointcount)
    local pointlist = {}
    local currentPoint = GetBot():GetXUnitsTowardsLocation( vTargetLoc, dist )

    for i=0,pointcount do
        --[[
        for _,v in pairs(pointlist) do
            DebugDrawCircle( v, nWidth, 0, 255, 50 )
            DebugDrawCircle( self:GetLocation(), nWidth, 0, 50, 255 )
            DebugDrawCircle( vTargetLoc, nWidth, 255, 50, 50 )
        end
        ]]

        table.insert(pointlist, currentPoint)
        --print("added point")
        dist = dist + nWidth
        currentPoint = GetBot():GetXUnitsTowardsLocation( vTargetLoc, dist )
        --print(GetUnitToLocationDistance(self, currentPoint))
    end

 
    for _,v in pairs(pointlist) do
        DebugDrawCircle( v, nWidth, 0, 255, 50 )
        DebugDrawCircle( self:GetLocation(), nWidth, 0, 50, 255 )
        DebugDrawCircle( vTargetLoc, nWidth, 255, 50, 50 )
    end

   for _,v in pairs(pointlist) do
        --print("checking point")
        --DebugDrawCircle( v, nWidth, 0, 255, 50 )
        --DebugDrawCircle( self:GetLocation(), nWidth, 0, 50, 255 )
        --DebugDrawCircle( vTargetLoc, nWidth, 255, 50, 50 )
        local enemyHeroes = self:FindAoELocation( true, true, v, 0, nWidth, 0.0, 100000 ) 
        local enemyCreeps = self:FindAoELocation( true, false, v, 0, nWidth, 0.0, 100000 ) 
        local friendlyHeroes = self:FindAoELocation( false, true, v, 0, nWidth, 0.0, 100000 ) 
        local friendlyCreeps = self:FindAoELocation( false, false, v, 0, nWidth, 0.0, 100000 ) 
        if not bFriends then
            friendlyHeroes = 0
            friendlyCreeps = 0
        end
        if (enemyHeroes.count > 0 or
            enemyCreeps.count > 0 or
            friendlyHeroes.count > 0 or
             friendlyCreeps.count > 0)
        then
            --print("path blocked")
            return false
        end
    end
    --print("Path Clear!")
    return true
end

function utilsModule.TestTower()
	
	local tower1Mid = GetTower(GetTeam(), TOWER_MID_1);
	if tower1Mid ~= nil then
		local ACreeps = tower1Mid:GetNearbyCreeps(1000, false);
		local ECreeps = tower1Mid:GetNearbyCreeps(1000, true);
		local EHeroes = tower1Mid:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
		local AHeroes = tower1Mid:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
		
		if ACreeps ~= nil then
		print("Allied Creeps = "..tostring(#ACreeps))
		end
		if ECreeps ~= nil then
		print("Enemy Creeps = "..tostring(#ECreeps))
		end
		if EHeroes ~= nil then
		print("Enemy Heroes = "..tostring(#EHeroes))
		end
		if AHeroes ~= nil then
		print("Allied Heroes = "..tostring(#AHeroes))
		end
		
		if tower1Mid:WasRecentlyDamagedByAnyHero(2.0) then
		print("Recently Damaged by Any Heroes ")
		end
		if tower1Mid:WasRecentlyDamagedByAnyHero(2.0) then
		print("Recently Damaged by Any Creeps")
		end
	end
	
end

function utilsModule.PrintMode(mod)
	if mod == BOT_MODE_NONE then
		print("BOT_MODE_NONE")
	elseif mod == BOT_MODE_LANING then	
		print("BOT_MODE_LANING")
	elseif mod == BOT_MODE_ATTACK  then	
		print("BOT_MODE_ATTACK ")
	elseif mod == BOT_MODE_ROAM then	
		print("BOT_MODE_ROAM")
	elseif mod == BOT_MODE_RETREAT then	
		print("BOT_MODE_RETREAT")
	elseif mod == BOT_MODE_SECRET_SHOP then	
		print("BOT_MODE_SECRET_SHOP")
	elseif mod == BOT_MODE_SIDE_SHOP then	
		print("BOT_MODE_SIDE_SHOP")
	elseif mod == BOT_MODE_RUNE then	
		print("BOT_MODE_RUNE")
	elseif mod == BOT_MODE_PUSH_TOWER_TOP then	
		print("BOT_MODE_PUSH_TOWER_TOP")
	elseif mod == BOT_MODE_PUSH_TOWER_MID then	
		print("BOT_MODE_PUSH_TOWER_MID")
	elseif mod == BOT_MODE_PUSH_TOWER_BOT then	
		print("BOT_MODE_PUSH_TOWER_BOT")
	elseif mod == BOT_MODE_DEFEND_TOWER_TOP  then	
		print("BOT_MODE_DEFEND_TOWER_TOP ")	
	elseif mod == BOT_MODE_DEFEND_TOWER_MID  then	
		print("BOT_MODE_DEFEND_TOWER_MID ")	
	elseif mod == BOT_MODE_DEFEND_TOWER_BOT  then	
		print("BOT_MODE_DEFEND_TOWER_BOT ")	
	elseif mod == BOT_MODE_ASSEMBLE  then	
		print("BOT_MODE_ASSEMBLE ")	
	elseif mod == BOT_MODE_ASSEMBLE_WITH_HUMANS  then	
		print("BOT_MODE_ASSEMBLE_WITH_HUMANS ")	
	elseif mod == BOT_MODE_TEAM_ROAM  then	
		print("BOT_MODE_TEAM_ROAM ")		
	elseif mod == BOT_MODE_FARM  then	
		print("BOT_MODE_FARM ")		
	elseif mod == BOT_MODE_ASSEMBLE_WITH_HUMANS  then	
		print("BOT_MODE_ASSEMBLE_WITH_HUMANS ")	
	elseif mod == BOT_MODE_DEFEND_ALLY  then	
		print("BOT_MODE_DEFEND_ALLY ")
	elseif mod == BOT_MODE_EVASIVE_MANEUVERS  then	
		print("BOT_MODE_EVASIVE_MANEUVERS ")
	elseif mod == BOT_MODE_ROSHAN  then	
		print("BOT_MODE_ROSHAN ")
	elseif mod == BOT_MODE_ITEM  then	
		print("BOT_MODE_ITEM ")
	elseif mod == BOT_MODE_WARD  then	
		print("BOT_MODE_WARD ")	
	else
		print("UNKNOWN")
	end
end

function utilsModule.GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

function utilsModule.HasForbiddenModifier(npcTarget)
	local modifier = {
		"modifier_winter_wyvern_winters_curse",
		"modifier_modifier_dazzle_shallow_grave",
		"modifier_modifier_oracle_false_promise",
		"modifier_oracle_fates_edict"
	}
	for _,mod in pairs(modifier)
	do
		if npcTarget:HasModifier(mod) then
			return true
		end	
	end
	return false;
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.IsFacingLocation(hero,loc,delta)
	
	local face=hero:GetFacing();
	local move = loc - hero:GetLocation();
	
	move = move / (utilsModule.GetDistance(Vector(0,0),move));

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


-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.Fountain(team)
	if team==TEAM_RADIANT then
		return Vector(-7093,-6542);
	end
	return Vector(7015,6534);
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.GetDistance(s, t)
    --print("S1: "..s[1]..", S2: "..s[2].." :: T1: "..t[1]..", T2: "..t[2]);
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.VectorTowards(s,t,d)
	local f=t-s;
	f=f / utilsModule.GetDistance(f,Vector(0,0));
	return s+(f*d);
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.AreTreesBetween(loc,r)
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
			if d<=r and GetUnitToLocationDistance(npcBot,loc)>utilsModule.GetDistance(x,loc)+50 then
				return true;
			end
		end
	end
	return false;
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.AreEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    local npcBot = GetBot()

    local eCreeps = npcBot:GetNearbyCreeps(GetUnitToLocationDistance(npcBot, loc), true)

    --check if there are enemy creeps between us and location with line-of-sight thickness
    for _, eCreep in ipairs(eCreeps) do
        local x = eCreep:GetLocation()
        local y = npcBot:GetLocation()
        local z = loc

        if x ~= y then
            local a = 1
            local b = 1
            local c = 0

            if x.x - y.x == 0 then
                b = 0
                c = -x.x
            else
                a =- (x.y - y.y)/(x.x - y.x)
                c =- (x.y + x.x*a)
            end

            local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
            if d <= lineOfSightThickness and
                GetUnitToLocationDistance(npcBot, loc) > (utilsModule.GetDistance(x,loc) + 50) then
                return true
            end
        end
    end
    return false
end



-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.AreFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    local npcBot = GetBot()

    local fCreeps = npcBot:GetNearbyCreeps(GetUnitToLocationDistance(npcBot, loc), false)

    --check if there are enemy creeps between us and location with line-of-sight thickness
    for _, fCreep in ipairs(fCreeps) do
        local x = fCreep:GetLocation()
        local y = npcBot:GetLocation()
        local z = loc

        if x ~= y then
            local a = 1
            local b = 1
            local c = 0

            if x.x - y.x == 0 then
                b = 0
                c = -x.x
            else
                a =- (x.y - y.y)/(x.x - y.x)
                c =- (x.y + x.x*a)
            end

            local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
            if d <= lineOfSightThickness and
                GetUnitToLocationDistance(npcBot, loc) > (utilsModule.GetDistance(x,loc) + 50) then
                return true
            end
        end
    end
    return false
end

function utilsModule.AreCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    if not utilsModule.AreEnemyCreepsBetweenMeAndLoc(loc, lineOfSightThickness) then
        return utilsModule.AreFriendlyCreepsBetweenMeAndLoc(loc, lineOfSightThickness)
    end
    return true
end

function utilsModule.ValidTarget(target)
    if target and not target:IsNull() and target:IsAlive() then
        return true
    end
    return false
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.GetFriendlyHeroesBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fHeroList = {}

    local fHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)

    --check if there are enemy creeps between us and location with line-of-sight thickness
    for _, fHero in pairs(fHeroes) do
        if utilsModule.ValidTarget(fHero) then
            local x = fHero:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (utilsModule.GetDistance(x,loc) + 50) then
                    table.insert(fHeroList, fHero)
                end
            end
        end
    end
    return fHeroList
end

-- CONTRIBUTOR: Function below was based off above function by Platinum_dota2
function utilsModule.GetEnemyHeroesBetweenMeAndLoc(loc, lineOfSightThickness)
    local bot = GetBot()
    local fHeroList = {}

     local fHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

    --check if there are enemy creeps between us and location with line-of-sight thickness
    for _, fHero in pairs(fHeroes) do
        if utilsModule.ValidTarget(fHero) then
            local x = fHero:GetLocation()
            local y = bot:GetLocation()
            local z = loc

            if x ~= y then
                local a = 1
                local b = 1
                local c = 0

                if x.x - y.x == 0 then
                    b = 0
                    c = -x.x
                else
                    a =- (x.y - y.y)/(x.x - y.x)
                    c =- (x.y + x.x*a)
                end

                local d = math.abs((a*z.x + b*z.y + c)/math.sqrt(a*a + b*b))
                if d <= lineOfSightThickness and
                    GetUnitToLocationDistance(bot, loc) > (utilsModule.GetDistance(x,loc) + 50) then
                    table.insert(fHeroList, fHero)
                end
            end
        end
    end
    return fHeroList
end


-- util function for printing a table
function utilsModule.print_r(t)--print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

----------------------------------------------------------------------------------------------------

function utilsModule.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utilsModule.deepcopy(orig_key)] = utilsModule.deepcopy(orig_value)
        end
        setmetatable(copy, utilsModule.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

----------------------------------------------------------------------------------------------------

function utilsModule.GetLane( vLoc )
    --local team = GetTeam()
    local sideOfMap = 0

    if vLoc.x + vLoc.y > 0 then --mostly true
        sideOfMap = TEAM_DIRE
    else
        sideOfMap = TEAM_RADIANT
    end
    --print(sideOfMap)
    local angleToMid = 0
    if sideOfMap == TEAM_RADIANT then
        vToLoc = vLoc - LANE_HEAD_RAD
        angleToMid = vToLoc:Dot(LANE_MID_RAD) / (#vToLoc * #LANE_MID_RAD)
    else
        vToLoc = vLoc - LANE_HEAD_DIRE
        --print(tostring(vToLoc))
        --print(tostring(#vToLoc) .. ":".. #LANE_MID_DIRE)
        angleToMid = vToLoc:Dot(LANE_MID_DIRE) / (#vToLoc * #LANE_MID_DIRE)
    end
    if angleToMid > 90 then angleToMid = angleToMid - 180 end
    angleToMid = math.acos(math.abs(angleToMid)) * 180 / math.pi
    --print(sideOfMap .. ":" .. angleToMid)
    if angleToMid < 7.5 then return LANE_MID end
    if angleToMid < 38 then return LANE_NONE end

    if vLoc.x - vLoc.y < 0 then 
        return LANE_TOP
    else 
        return LANE_BOT 
    end

end
----------------------------------------------------------------------------------------------------
-- attempt to assess a locations current danger
function utilsModule.GetLocationDanger( vLoc )
    local npcBot = GetBot()
    --local team = GetTeam()
    local danger = 0
    lane = utilsModule.GetLane( vLoc )
    
    --range is 0 - 1
    local toRosh = vLoc - ROSHAN
    if #toRosh < 500 then
        danger = danger + 1
    end

    --range is 0 - 1 out of lane or 2 if you are base seiged
    --range in lane is 0 - ~3
    if lane == LANE_NONE then
        local lanes = (GetLaneFrontAmount( GetTeam(), LANE_TOP, true ) +
                        GetLaneFrontAmount( GetTeam(), LANE_MID, true ) +
                        GetLaneFrontAmount( GetTeam(), LANE_BOT, true ))
        if lanes == 0 then danger = danger + 2 end
        danger = danger + (1 - (lanes / 3))
    else

        local laneFront = 0
        if lane == LANE_BOT then
            laneFront = GetLocationAlongLane( LANE_BOT, GetLaneFrontAmount( GetTeam(), LANE_BOT, true ) )
        elseif lane == LANE_TOP then
            laneFront = GetLocationAlongLane( LANE_TOP, GetLaneFrontAmount( GetTeam(), LANE_TOP, true ) )
        else
            laneFront = GetLocationAlongLane( LANE_MID, GetLaneFrontAmount( GetTeam(), LANE_MID, true ) )
        end
        --DebugDrawCircle(Vector(laneFront.x, laneFront.y, 300), 25,  0, 255, 0)
        --print(tostring(laneFront))
        local laneDistance = laneFront - GetAncient(GetTeam()):GetLocation()
        local locDistance = vLoc - GetAncient(GetTeam()):GetLocation()
        danger = danger + (math.max((#locDistance - #laneDistance) / 3500, 0))
    end    

    for i=0,10 do
        local tower = GetTower(GetTeam(), i)
        --print("team " ..GetTeam().."  tower " .. i)
        if tower and #(npcBot:GetLocation() - tower:GetLocation()) < 1000 then
            danger = danger - 3
        end

        if GetTeam() - 2 then -- get enemy team (dire - radiant = true)
            tower = GetTower(TEAM_RADIANT, i)
        else
            tower = GetTower(TEAM_DIRE, i)
        end
        if tower and #(npcBot:GetLocation() - tower:GetLocation()) < 1000 then
            danger = danger * 3
        end
    end

    return danger
end
----------------------------------------------------------------------------------------------------

return utilsModule