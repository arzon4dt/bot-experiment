--[[local utils = require(GetScriptDirectory() ..  "/util")
local bot = GetBot();
local retreatCause = "";
local pMana = 0;
local pHealth = 0;
local State = "";
local RADI_BASE = Vector(-7156.000000, -6661.000000, 0.000000)
local DIRE_BASE = Vector(7156.000000, 6661.000000, 0.000000)

function GetDesire()

	pHealth = bot:GetHealth() / bot:GetMaxHealth();  
	pMana   = bot:GetMana() / bot:GetMaxMana();

	if bot:DistanceFromFountain() and pHealth == 1.0 and pMana == 1.0 then
		State = ""
	end
	
	if bot:IsChanneling() or not bot:IsAlive() then
		return BOT_MODE_DESIRE_NONE; 
	end
	
	if bot:DistanceFromFountain() == 0 and ( pHealth < 1.0 or pMana < 1.0 ) then
		retreatCause = "notfullyet"
		return BOT_MODE_DESIRE_ABSOLUTE;
	end
	
	if GetNumCouriers() > 0 then
		if bot:GetCourierValue() > 0 and GetUnitToUnitDistance(GetCourier(0), bot) < 500 then
			retreatCause = "itemoncourier"
			return BOT_MODE_DESIRE_HIGH;
		end
	end
	
	if pMana < 0.05 or pHealth < 0.15 then
		State = "retreat"
		retreatCause = "lowhpormana"
		return BOT_MODE_DESIRE_VERYHIGH;
	end
	
	if State == "retreat" then
		return BOT_MODE_DESIRE_VERYHIGH;
	end
	
	return BOT_MODE_DESIRE_NONE; 
	
end

function OnEnd()
	retreatCause = "";
end

function Think()
	
	if State == "retreat" then
		bot:Action_MoveToLocation( GetBase(GetTeam()) + RandomVector(300) )
		return
	end

	if retreatCause == "itemoncourier" then
		bot:Action_MoveToLocation( GetCourier(0):GetLocation() )
		return
	elseif retreatCause == "notfullyet" then
		bot:Action_MoveToLocation( GetBase(GetTeam()) + RandomVector(300) )
		return
	elseif retreatCause == "lowhpormana"  then
		if  GetUnitToLocationDistance(bot, GetBase(GetTeam())) > 300 then
			bot:Action_MoveToLocation( GetBase(GetTeam()) )
			return
		else
			bot:Action_MoveToLocation( GetBase(GetTeam()) + RandomVector(300) )
			return
		end
	end
end

function GetBase(team)
	if team == TEAM_DIRE then
		return DIRE_BASE;
	else
		return RADI_BASE;
	end
end
]]--