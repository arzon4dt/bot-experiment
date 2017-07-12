local role = require(GetScriptDirectory() .. "/RoleUtility");
local utils = require(GetScriptDirectory() ..  "/util")
local campUtils = require(GetScriptDirectory() ..  "/CampUtility")
local bot = GetBot()
local minute = 0;
local sec = 0;
local preferedCamp = nil;
local AvailableCamp = {};
local LaneCreeps = {};
local numCamp = 18;
local farmState = 0;
local teamPlayers = nil;
local lanes = {LANE_TOP, LANE_MID, LANE_BOT}

function GetDesire()
	
	if teamPlayers == nil then teamPlayers = GetTeamPlayers(GetTeam()) end
	
	local EnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	minute = math.floor(DotaTime() / 60)
	sec = DotaTime() % 60
	
	if #AvailableCamp < numCamp and ( ( DotaTime() > 30 and DotaTime() < 60 and sec > 30 and sec < 31 ) 
	   or ( DotaTime() > 30 and  sec > 0 and sec < 1 ) ) 
	then
		AvailableCamp, numCamp = campUtils.RefreshCamp(bot);
		--print(tostring(GetTeam())..tostring(#AvailableCamp))
	end
	
	if #EnemyHeroes > 0 then
		return BOT_MODE_DESIRE_NONE;
	end		
	
	if not bot:IsAlive() or bot:IsChanneling() or bot:GetCurrentActionType() == 1 or bot:GetNextItemPurchaseValue() == 0 
	   or bot:WasRecentlyDamagedByAnyHero(3.0) or #EnemyHeroes >= 1 
	   or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
	   or bot.SecretShop
	then
		return BOT_MODE_DESIRE_NONE;
	end
	
	
	
	if bot:GetLevel() >= 6 and campUtils.IsStrongJungler(bot)
	then
		LaneCreeps = bot:GetNearbyLaneCreeps(1600, true);
		if LaneCreeps ~= nil and #LaneCreeps > 0 then
			return BOT_MODE_DESIRE_HIGH;
		else
			if preferedCamp == nil then preferedCamp = campUtils.GetClosestNeutralSpwan(bot, AvailableCamp) end
			if preferedCamp ~= nil then
				if bot:GetHealth() / bot:GetMaxHealth() <= 0.15 then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_LOW;
				elseif farmState == 1 then 
					return BOT_MODE_DESIRE_ABSOLUTE;
				elseif not campUtils.IsSuitableToFarm(bot) then 
					preferedCamp = nil;
					return BOT_MODE_DESIRE_NONE;
				else
					return BOT_MODE_DESIRE_VERYHIGH;
				end
			end
		end
	end
	
	return 0.0
	
end

function OnEnd()
	preferedCamp = nil;
	farmState = 0;
end

function Think()
	if bot:IsUsingAbility() then 
		return
	end
	
	if LaneCreeps ~= nil and #LaneCreeps > 0 then
		local farmTarget = campUtils.FindFarmedTarget(LaneCreeps)
		if farmTarget ~= nil then
			bot:Action_AttackUnit(farmTarget, true);
			return
		end
	end
		
	if preferedCamp ~= nil then
		local cDist = GetUnitToLocationDistance(bot, preferedCamp.cattr.location);
		local stackMove = campUtils.GetCampMoveToStack(preferedCamp.idx);
		local stackTime =  campUtils.GetCampStackTime(preferedCamp);
		if cDist > 300 and farmState == 0 then
			bot:Action_MoveToLocation(preferedCamp.cattr.location);
			return
		else
			local neutralCreeps = bot:GetNearbyNeutralCreeps(800);
			local farmTarget = campUtils.FindFarmedTarget(neutralCreeps)
			if farmTarget ~= nil then
				farmState = 1;
				if sec >= stackTime then
					bot:Action_MoveToLocation(stackMove);
					return
				else
					bot:Action_AttackUnit(farmTarget, true);
					return
				end
			else
				farmState = 0;
				AvailableCamp, preferedCamp = campUtils.UpdateAvailableCamp(bot, preferedCamp, AvailableCamp);
			end
		end	
	end
	
end



