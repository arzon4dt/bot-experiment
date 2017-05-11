------------------------------------------------------------
--- AUTHOR: PLATINUM_DOTA2 (Pooya J.)
--- EMAIL ADDRESS: platinum.dota2@gmail.com
------------------------------------------------------------

-------
BotsInit = require( "game/botsinit" );

local MyModule = BotsInit.CreateGeneric();
----------
Utility = require( GetScriptDirectory().."/ps/Utility")
----------

function  OnStart()
end

function OnEnd()
end

local function AlliesInLane(lane)
	local npcBot=GetBot();

	local nAl=0;
	for i=1,5,1 do
		local ally=GetTeamMember(i);
		if ally~=nil and ally.CurLane~=nil and ally.CurLane==lane
		and (ally:GetUnitName()~="npc_dota_hero_bloodseeker" or ally:GetActiveMode()==BOT_MODE_LANING)
		and ally:GetUnitName()~=npcBot:GetUnitName()
		and Utility.IsCore(ally) then
			nAl=nAl+1;
		end
	end
	return nAl;
end

function GetDesire()
	local npcBot=GetBot();
	
	if npcBot.CurLane==nil then
		return 0;
	end
	
	local MyLane=npcBot:GetAssignedLane();
	
	if not Utility.IsCore(npcBot) then
		for _,lane in pairs(Utility.Lanes) do
			if AlliesInLane(lane)>1 then
				npcBot.CurLane=lane;
				return 0;
			end
		end
		return 0;
	end
	
	if (Utility.NumberOfDeadTowers(Utility.GetOtherTeam(),MyLane)<2 or DotaTime()<990) and (DotaTime()<20*60) then
		return 0;
	end
	
	local MyLaneFront=Min(GetLaneFrontAmount(Utility.GetOtherTeam(),MyLane,true),GetLaneFrontAmount(GetTeam(),MyLane,true));
	
	if GetUnitToLocationDistance(npcBot,Utility.Fountain(GetTeam()))>1000 then
		return 0;
	end
	
	if MyLaneFront<0.44 and Utility.AreRacksUp(MyLane) then
		npcBot.CurLane=MyLane;
		return 0;
	end
	
	if MyLaneFront<0.29 then
		npcBot.CurLane=MyLane;
		return 0;
	end
	
	
	local mtdel=Utility.NumberOfDeadTowers(GetTeam(),MyLane) - Utility.NumberOfDeadTowers(Utility.GetOtherTeam(),MyLane);
	
	if mtdel>=0 then
		return 0;
	end
	
	for _,lane in pairs(Utility.Lanes) do
		if lane~=MyLane and lane~= LANE_TOP then
			local ntdel=Utility.NumberOfDeadTowers(GetTeam(),lane) - Utility.NumberOfDeadTowers(Utility.GetOtherTeam(),lane);
			
			local nAl=AlliesInLane(lane);
			local mAl=AlliesInLane(MyLane);
			
			if ntdel >= mtdel and nAl>mAl and Utility.AreRacksUp(lane) then
				npcBot.CurLane=lane;
				return 0;
			end
		end
	end
	
	if Utility.AreRacksUp(MyLane) then
		npcBot.CurLane=MyLane;
	end
	
	return 0;
end

function Think()
end

--------
MyModule.OnStart = OnStart;
MyModule.OnEnd = OnEnd;
MyModule.Think = Think;
MyModule.GetDesire = GetDesire;
return MyModule;