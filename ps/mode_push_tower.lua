BotsInit = require( "game/botsinit" );
local MyModule = BotsInit.CreateGeneric();

local bot = GetBot();
local Team = GetTeam();
print(tostring(bot))

function GetDesire()

	--local topFLoc = GetLaneFrontLocation( Team, LANE_TOP , 100.0 ) 
	local midFLoc = GetLaneFrontLocation( Team, LANE_MID , 100 ) 
	local midFAmo = GetLaneFrontAmount( Team, LANE_MID, true ) 
	local midLocAmo = GetLocationAlongLane(LANE_MID, midFAmo)
	local AmoLane =  GetAmountAlongLane( LANE_MID, bot:GetLocation() ) 
	--local botFLoc = GetLaneFrontLocation( Team, LANE_BOT , 100.0 ) 
	
	--bot:ActionImmediate_Ping(midLocAmo.x, midLocAmo.y, true)
	
	--print("TOP "..tostring(topFLoc))
	print("MID "..tostring(midFLoc))
	print("AMO "..tostring(midFAmo))
	print("LOC AMO "..tostring(midLocAmo))
	print("LANE AMO "..tostring(AmoLane.amount).."DIST "..tostring(AmoLane.distance))
	--print("BOT "..tostring(botFLoc))
	--[[if bot:IsUsingAbility() or bot:IsChanneling()  
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if DotaTime() > 10*60 or bot:GetLevel() >= 6 then
		return BOT_MODE_DESIRE_MODERATE;
	end]]--
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	
end

function OnEnd()
	
end

function Think()
	
end

MyModule.OnStart = OnStart;
MyModule.OnEnd = OnEnd;
MyModule.Think = Think;
MyModule.GetDesire = GetDesire;
return MyModule;