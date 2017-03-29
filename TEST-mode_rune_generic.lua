local RuneUtility = require(GetScriptDirectory() .. "/RuneUtility")
local pickRuneRadius = 1300;
local runeL = RUNE_BOUNTY_1;
local flagBot = nil;
local laningRune = nil;

function GetDesire()
	local npcBot = GetBot();
	
	if GetGameState() ~= GAME_STATE_PRE_GAME and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS then
		return ( 0.0 );
	end
	
	--print(npcBot:GetUnitName()..runeL);
	
	local min = math.floor(DotaTime() / 60)
	local sec = DotaTime() % 60
	
	if npcBot:GetActiveMode() == BOT_MODE_WARD then
		return BOT_MODE_DESIRE_NONE;
	end
	
	if flagBot ~= nil then
	print(flagBot:GetUnitName())
	end
	
	if DotaTime() < 1 then
		return BOT_MODE_DESIRE_HIGH;
	elseif ( min % 2 == 1 and sec > 50 ) or ( min % 2 == 0 and sec < 3 ) then
		if flagBot ~= nil and flagBot:GetUnitName() == npcBot:GetUnitName() then
			return BOT_MODE_DESIRE_HIGH;
		end
	end
	
	--[[
	if DotaTime() > 1*60 then
		for i = 1, #(RuneUtility.ListRune) 
		do
			local rune = (RuneUtility.ListRune)[i];
			local runeLoc = (RuneUtility.ListRuneLocation)[i];
			if GetUnitToLocationDistance( npcBot , runeLoc ) < pickRuneRadius and
				GetRuneStatus(rune) == RUNE_STATUS_AVAILABLE
			then
				return BOT_MODE_DESIRE_HIGH 
			end
		end
	end
	]]--
	
	return ( 0.0 );

end

function OnStart()
	local npcBot = GetBot();
	local RL = {
		RUNE_BOUNTY_1,
		RUNE_BOUNTY_2,
		RUNE_BOUNTY_3,
		RUNE_BOUNTY_4
	}
	local min = math.floor(DotaTime() / 60)
	local sec = DotaTime() % 60
	print(min)
	if DotaTime() < 3 then
		runeL = RL[RandomInt(1,4)];
	elseif ( min % 2 == 1 and sec > 50 ) or ( min % 2 == 0 and sec < 3 ) then
		print("START")
		if GetTeam() == TEAM_RADIANT then
			laningRune = RUNE_BOUNTY_2;
			flagBot = TheClosestOne(RUNE_BOUNTY_2)
		else
			laningRune = RUNE_BOUNTY_3;
			flagBot = TheClosestOne(RUNE_BOUNTY_3)
		end
	end
end

function OnEnd()
	local npcBot = GetBot();
	flagBot = nil;
end

function Think()

	min = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	GrabZeroMinuteRune()
	
	--GrabRuneInLaningMode()
	
	--GrabRuneInRange()
	
	--SecureOurRune()
	
	--SecurePU()
	
	
end

function GrabRuneInRange()
	local npcBot = GetBot()
	
	for i = 1, #(RuneUtility.ListRune) 
	do
		local rune = (RuneUtility.ListRune)[i];
		local runeLoc = (RuneUtility.ListRuneLocation)[i];
		if GetUnitToLocationDistance( npcBot , runeLoc ) < pickRuneRadius 
		then
			if GetRuneStatus( rune ) == RUNE_STATUS_AVAILABLE then
				npcBot:Action_PickUpRune(rune);
			elseif 	GetRuneStatus( rune ) == RUNE_STATUS_UNKNOWN or GetRuneStatus( rune ) == RUNE_STATUS_MISSING then
				npcBot:Action_MoveToLocation(GetRuneSpawnLocation(rune) + RandomVector(200))
			end
		end
	end
end

function GrabZeroMinuteRune()
	local npcBot = GetBot();
	if DotaTime() < 3 then
		if GetRuneStatus( runeL ) == RUNE_STATUS_AVAILABLE then
			npcBot:Action_PickUpRune(runeL);
		else		
			npcBot:Action_MoveToLocation(GetRuneSpawnLocation(runeL) + RandomVector(200))
		end		
		
		
		--[[if GetTeam() ==  TEAM_RADIANT then
			if npcBot:GetAssignedLane() == LANE_BOT then
				npcBot:Action_MoveToLocation(RAD_SAFE_BOUNTY_RUNE + RandomVector(200))
			elseif npcBot:GetAssignedLane() == LANE_MID or  npcBot:GetAssignedLane() == LANE_TOP then
				npcBot:Action_MoveToLocation(RAD_OFF_BOUNTY_RUNE + RandomVector(200))
			end
		else
			if npcBot:GetAssignedLane() == LANE_MID or npcBot:GetAssignedLane() == LANE_BOT then
				npcBot:Action_MoveToLocation(DIRE_OFF_BOUNTY_RUNE + RandomVector(200))
			elseif  npcBot:GetAssignedLane() == LANE_TOP then
				npcBot:Action_MoveToLocation(DIRE_SAFE_BOUNTY_RUNE + RandomVector(200))
			end
		end]]--
	elseif ( min % 2 == 1 and sec > 50 ) and ( min % 2 == 0 and sec < 3 ) then
		if npcBot:GetUnitName() == flagBot:GetUnitName() then
			if GetRuneStatus( laningRune ) == RUNE_STATUS_AVAILABLE then
				npcBot:Action_PickUpRune(laningRune);
			else		
				npcBot:Action_MoveToLocation(GetRuneSpawnLocation(laningRune) + RandomVector(200))
			end	
		end
	end	
end

function GrabRuneInLaningMode()
	local npcBot = GetBot();
	if  DotaTime() > 1 * 60 and ( ( min % 2 == 1 and sec > 50 ) or ( min % 2 == 0 and sec < 3 ) ) and IsSuitableToPickUpRune() then
		if npcBot:GetAssignedLane() == LANE_MID then
			if GetTeam() ==  TEAM_RADIANT  then
				if GetRuneStatus( RUNE_POWERUP_1 ) == RUNE_STATUS_AVAILABLE then
					npcBot:Action_PickUpRune(RUNE_POWERUP_1);
				elseif 	GetRuneStatus( RUNE_POWERUP_1 ) == RUNE_STATUS_UNKNOWN or GetRuneStatus( RUNE_POWERUP_1 ) == RUNE_STATUS_MISSING then
					npcBot:Action_MoveToLocation(PU_RUNE_TOP + RandomVector(200))
				end
			elseif GetTeam() ==  TEAM_DIRE then
				if GetRuneStatus( RUNE_POWERUP_2 ) == RUNE_STATUS_AVAILABLE then
					npcBot:Action_PickUpRune(RUNE_POWERUP_2);
				elseif 	GetRuneStatus( RUNE_POWERUP_2 ) == RUNE_STATUS_UNKNOWN or GetRuneStatus( RUNE_POWERUP_2 ) == RUNE_STATUS_MISSING then
					npcBot:Action_MoveToLocation(PU_RUNE_BOT + RandomVector(200))
				end
			end
		else
			local selectedRune = nil;
			local minDist = 1000000;
			for _,r in pairs( RuneUtility.ListRune )
			do
				local botToRuneDist = GetUnitToLocationDistance( npcBot , GetRuneSpawnLocation(r) );
				local NearbyEnemyTower = npcBot:GetNearbyTowers(1000, true);
				if botToRuneDist < minDist and ( #NearbyEnemyTower == 0 or ( NearbyEnemyTower[1] ~= nil and GetUnitToLocationDistance(NearbyEnemyTower[1], GetRuneSpawnLocation(r)) > 2500 ) ) then
					minDist = botToRuneDist;
					selectedRune = r;
				end
			end
			if selectedRune ~= nil and IsSuitableToPickUpRune() and TheClosestOne(selectedRune)
			then
				if GetRuneStatus( selectedRune ) == RUNE_STATUS_AVAILABLE then
					npcBot:Action_PickUpRune(selectedRune);
				elseif 	GetRuneStatus( selectedRune ) == RUNE_STATUS_UNKNOWN or GetRuneStatus( selectedRune ) == RUNE_STATUS_MISSING then
					npcBot:Action_MoveToLocation(GetRuneSpawnLocation(selectedRune) + RandomVector(200))
				end
			end
		end
	end
end

function SecureOurRune()
	if DotaTime() < 1*60 then
		return
	end
	
	local npcBot = GetBot();
	local ToRuneDist = 4500;
	if GetTeam() ==  TEAM_RADIANT  then
		for _,r in pairs(RuneUtility.RadiantBountyRune)
		do	
			if GetUnitToLocationDistance(npcBot, GetRuneSpawnLocation(r)) <  ToRuneDist and 
			   IsSuitableToPickUpRune()  
			then
				if GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE then
					npcBot:Action_PickUpRune(r);
				elseif 	GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN then
					npcBot:Action_MoveToLocation(GetRuneSpawnLocation(r) + RandomVector(200))
				end
			end
		end
	elseif GetTeam() ==  TEAM_DIRE  then
		for _,r in pairs(RuneUtility.DireBountyRune)
		do
			if GetUnitToLocationDistance(npcBot, GetRuneSpawnLocation(r)) < ToRuneDist and 
			   IsSuitableToPickUpRune() 
			then
				if GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE then
					npcBot:Action_PickUpRune(r);
				elseif 	GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN then
					npcBot:Action_MoveToLocation(GetRuneSpawnLocation(r) + RandomVector(200))
				end
			end
		end
	end
	
end

function SecurePU()	
	if DotaTime() < 1*60 then
		return
	end
	local npcBot = GetBot();
	local botToRuneDist = 4500;
	for _,r in pairs(RuneUtility.PU)
	do
		if GetUnitToLocationDistance(npcBot, GetRuneSpawnLocation(r)) < botToRuneDist and 
		   IsSuitableToPickUpRune() 
		then
			if GetRuneStatus( r ) == RUNE_STATUS_AVAILABLE then
				npcBot:Action_PickUpRune(r);
			elseif 	GetRuneStatus( r ) == RUNE_STATUS_UNKNOWN  then
				npcBot:Action_MoveToLocation(GetRuneSpawnLocation(r) + RandomVector(200))
			end
		end
	end
end

function TheClosestOne(rune)
	local npcBot = GetBot();
	local tableNearbyAllies = npcBot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
	if npcBot:GetAssignedLane() == LANE_TOP then
		local theClosestOne = npcBot;
		local theClosestDist = GetUnitToLocationDistance(npcBot, GetRuneSpawnLocation(rune));
		for _,ally in pairs(tableNearbyAllies)
		do
			local dist = GetUnitToLocationDistance(ally, GetRuneSpawnLocation(rune))
			if dist < theClosestDist then
				theClosestDist = dist;
				theClosestOne = ally;
			end
		end
		if theClosestOne:GetUnitName() == npcBot:GetUnitName() then
			return theClosestOne;
		end	
	end
end

function IsSuitableToPickUpRune()

	local npcBot = GetBot();

	if ( ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or npcBot:GetActiveMode() == BOT_MODE_ATTACK
		or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
		or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
		or npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT 
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) then
		return false;
	end

	return true;

end