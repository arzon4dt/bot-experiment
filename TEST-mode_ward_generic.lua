
local wardLoc = {}

function GetDesire()
	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return ( 0.0 );
	end
	
	local npcBot = GetBot()
	--print(#wardLoc)
	--remove default location if there is a ward in that location
	for i = 1, #wardLoc, 1
	do
		local ward = GetUnitList(UNIT_LIST_ALLIED_WARDS)
		for _,uw in pairs(ward)
		do
			local X = uw:GetLocation().x; 
			local Y = uw:GetLocation().y; 
			if wardLoc[i] == Vector(X, Y) and FindWardSlot() ~= nil then
				table.remove(wardLoc, i);
			end
		end
	end
	
	--check whether bot has ward and the condition is suitable for warding or not
	for i=0, 8 do
		if(npcBot:GetItemInSlot(i) ~= nil) then
			local _item = npcBot:GetItemInSlot(i):GetName()
			if(_item == "item_ward_observer") and IsSuitableToWard() then
				return BOT_MODE_DESIRE_MODERATE
			end
		end
	end
	
	return ( 0.0 );
end

function OnStart()
	local npcBot = GetBot()
	
	RadWardLoc = {
		Vector(-2947, 808),
		Vector(2200, -3327)
	};
	
	RadWardEG = {
		Vector(-2947, 808),
		Vector(2200, -3327),
		Vector(1385, -4800)
	};
	
	DireWardLoc = {
		Vector(3227, -1520),
		Vector(-2800, 3800),
	};
	
	--refill default ward location when mode ward kick in
	if DotaTime() < 0 then
		if GetTeam() == TEAM_RADIANT then
			for _, p in pairs(RadWardLoc)
			do
				table.insert(wardLoc, p);
			end
		elseif 	GetTeam() == TEAM_DIRE then
			for _, p in pairs(DireWardLoc)
			do
				table.insert(wardLoc, p);
			end
		end
	elseif DotaTime() > 0 then
		if GetTeam() == TEAM_RADIANT then
			for _, p in pairs(RadWardEG)
			do
				table.insert(wardLoc, p);
			end
		elseif 	GetTeam() == TEAM_DIRE then
			for _, p in pairs(DireWardLoc)
			do
				table.insert(wardLoc, p);
			end
		end
	end
end

function OnEnd()
	--emptying ward location table
	local npcBot = GetBot()
	wardLoc = {};
end

function Think()

	if  GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end

	local npcBot = GetBot()
	--print(npcBot:GetUnitName()..npcBot:GetAssignedLane())
	local wardItem = FindWardSlot();
	if GetTeam() == TEAM_RADIANT then
	end
	--Warding Think
	if DotaTime() < 0 and wardItem ~= nil and wardItem:IsFullyCastable() and IsSuitableToWard() and #wardLoc > 0 then
		local ClosestLoc = GetClosestWardLoc();
		if GetTeam() == TEAM_RADIANT then
			npcBot:Action_UseAbilityOnLocation( wardItem,  ClosestLoc);
		elseif GetTeam() == TEAM_DIRE then
			npcBot:Action_UseAbilityOnLocation( wardItem,  ClosestLoc);
		end
	elseif DotaTime() > 0 and wardItem ~= nil and wardItem:IsFullyCastable()  and IsSuitableToWard() and #wardLoc > 0 then
		local ClosestLoc = GetClosestWardLoc();
		if GetTeam() == TEAM_RADIANT then
			npcBot:Action_UseAbilityOnLocation( wardItem,  ClosestLoc);
		elseif GetTeam() == TEAM_DIRE then
			npcBot:Action_UseAbilityOnLocation( wardItem,  ClosestLoc);
		end
	end

end

--get closest ward position from bot
function GetClosestWardLoc()
	local npcBot = GetBot();
	local minDist = 100000;
	local wLoc = Vector(0,0);
	for _, loc in pairs(wardLoc)
	do
		local distance = GetUnitToLocationDistance(npcBot, loc)
		if distance < minDist then
			wLoc = loc;
			minDist = distance;
		end
	end
	return wLoc;
end

--find ward slot and return item ward handle
function FindWardSlot()
	local npcBot = GetBot()
	local MSSlot = npcBot:FindItemSlot("item_ward_observer");
	if MSSlot >= 0 and npcBot:GetItemSlotType(MSSlot) == ITEM_SLOT_TYPE_MAIN then
		return npcBot:GetItemInSlot(MSSlot);
	end
	return nil;
end

--check if the condition is suitable for warding
function IsSuitableToWard()
	local npcBot = GetBot();
	if ( ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or npcBot:GetActiveMode() == BOT_MODE_ATTACK
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
		--or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
		--or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
		--or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT 
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		return false;
	end

	return true;
end
