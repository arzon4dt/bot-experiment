if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local BotsInit = require( "game/botsinit" );
local MyModule = BotsInit.CreateGeneric();

local build = "NOT IMPLEMENTED";

--if not GetBot():IsNull() and not GetBot():IsIllusion() and string.find(GetBot():GetUnitName(), "hero") then	
if string.find(GetBot():GetUnitName(), "hero") and build == "NOT IMPLEMENTED" then
	build = require(GetScriptDirectory() .. "/builds/item_build_" .. string.gsub(GetBot():GetUnitName(), "npc_dota_hero_", ""))
end

if build == "NOT IMPLEMENTED" then 
	return 
end

local role = require(GetScriptDirectory() .. "/RoleUtility");
local mutil = require(GetScriptDirectory() ..  "/MyUtility")
local utils = require(GetScriptDirectory() ..  "/util")
local eUtils = require(GetScriptDirectory() ..  "/EnemyUtility")

local BotAbilityPriority = build["skills"];
local IdleTime = 0;
local AllowedIddle = 15;
local npcBot = GetBot();
local TimeDeath = nil;
local count = 1;
local humanInTeam = nil;

local testMode = true;
local chatInstalled = false;

npcBot.lastPlayerChat = nil

function EventChatCallback(nPID, sText, bTeamOnly)
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if IsPlayerBot(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member.ChatEvent ~= nil then
				member.ChatEvent(nPID, sText, bTeamOnly);
			end
		end
	end
end

local function TestChatCallBack(nPID, sText, bTeamOnly)
	print("GetBot() value => "..tostring(GetBot()))
	if npcBot.lastPlayerChat == nil then
		npcBot.lastPlayerChat = {
			['pid'] = nPID;
			['text'] = sText;
			['team_only'] = bTeamOnly;
		}
	else
		npcBot:ActionImmediate_Chat("Relax mate, I haven't done the first command!", true);
		print(npcBot:GetUnitName().." Chat : Relax mate, I haven't done the first command!, true")
	end
end

function AbilityLevelUpThink()  

	if GetGameMode() == GAMEMODE_1V1MID and testMode then
		return;
	end
	
	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() then
		return;
	end

	--[[if GetGameState() == GAME_STATE_GAME_IN_PROGRESS and not chatInstalled then 
		chatInstalled = true;
		InstallChatCallback(function (attr) EventChatCallback(attr.player_id, attr.string, attr.team_only); end);
	end]]--
	
	--npcBot.ChatEvent = TestChatCallBack
	
	--[[if npcBot.lastPlayerChat ~= nil then
		print(npcBot:GetUnitName().." => {"..tostring(npcBot.lastPlayerChat.pid)..","..npcBot.lastPlayerChat.text..","..tostring(npcBot.lastPlayerChat.team_only).."}")
		npcBot.lastPlayerChat = nil;
	end]]--
	
	if DotaTime() < 15 then
		npcBot.theRole = role.GetCurrentSuitableRole(npcBot, npcBot:GetUnitName());	
	end
	
	--[[if DotaTime() > 20 and DotaTime() < 20.5 then
		print(npcBot:GetUnitName().." have role :"..npcBot.theRole);
	end]]--
	
	if npcBot:IsChanneling() then
		npcBot:Action_ClearActions( false ) 
		return
	end
	
	--[[if mutil.IsSlowed(npcBot) then
		print(npcBot:GetUnitName().." is slowed");
	end]]--
	
	UnImplementedItemUsage()
	UseGlyph()
	
	local botLoc = npcBot:GetLocation();
	if npcBot:IsAlive() and npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and not IsLocationPassable(botLoc) then
		if npcBot.stuckLoc == nil then
			npcBot.stuckLoc = botLoc
			npcBot.stuckTime = DotaTime();
		elseif npcBot.stuckLoc ~= botLoc then
			npcBot.stuckLoc = botLoc
			npcBot.stuckTime = DotaTime();
		end
	else	
		npcBot.stuckTime = nil;
		npcBot.stuckLoc = nil;
	end
	
	if GetGameMode() == GAMEMODE_MO then
	
		if npcBot:GetLevel() > 25 or (GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS) then
			return;
		end
		
		if npcBot:GetAbilityPoints() > 0 then
			if BotAbilityPriority[count] ~= "-1" then
				local sNextAbility = npcBot:GetAbilityByName(BotAbilityPriority[count]);
				if sNextAbility ~= nil and sNextAbility:CanAbilityBeUpgraded() and sNextAbility:GetLevel() < sNextAbility:GetMaxLevel() then
					if npcBot:GetUnitName() == "npc_dota_hero_troll_warlord" and BotAbilityPriority[count] == "troll_warlord_whirling_axes_ranged" and sNextAbility:IsHidden() 
					then
						npcBot:ActionImmediate_LevelAbility("troll_warlord_whirling_axes_melee");
					elseif npcBot:GetUnitName() == "npc_dota_hero_keeper_of_the_light" and BotAbilityPriority[count] == "keeper_of_the_light_illuminate" and npcBot:HasScepter() then
						local ability = npcBot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate");
						if not ability:IsHidden() then
							npcBot:ActionImmediate_LevelAbility("keeper_of_the_light_spirit_form_illuminate");
						else
							return;
						end			
					elseif sNextAbility:IsHidden() then
						return;	
					else
						npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[count])
					end
					count = count + 1;
				end
			else
				count = count + 1;
			end
		end
		
	else
	
		if npcBot:GetAbilityPoints() < 1 or #BotAbilityPriority == 0 or  (GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS) then
			return;
		end
	
		if BotAbilityPriority[1] ~= "-1" 
		then
			local sNextAbility = npcBot:GetAbilityByName(BotAbilityPriority[1])
			if ( sNextAbility ~= nil and sNextAbility:CanAbilityBeUpgraded() and sNextAbility:GetLevel() < sNextAbility:GetMaxLevel() ) 
			then
				if npcBot:GetUnitName() == "npc_dota_hero_troll_warlord" and BotAbilityPriority[count] == "troll_warlord_whirling_axes_ranged" and sNextAbility:IsHidden() 
				then
					npcBot:ActionImmediate_LevelAbility("troll_warlord_whirling_axes_melee");
				elseif npcBot:GetUnitName() == "npc_dota_hero_keeper_of_the_light" and BotAbilityPriority[count] == "keeper_of_the_light_illuminate" and npcBot:HasScepter() 
				then
					local ability = npcBot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate");
					if not ability:IsHidden() then
						npcBot:ActionImmediate_LevelAbility("keeper_of_the_light_spirit_form_illuminate");
					else
						return;
					end			
				elseif sNextAbility:IsHidden() then
					return;	
				else
					npcBot:ActionImmediate_LevelAbility(BotAbilityPriority[1])
				end
				table.remove( BotAbilityPriority, 1 )
			end	
		else
			table.remove( BotAbilityPriority, 1 )
		end	
	
	end	
	
end

function GetNumEnemyNearby(building)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(building, dInfo.location) <= 2750 and dInfo.time_since_seen < 1.0 then
					nearbynum = nearbynum + 1;
				end
			end
		end
	end
	return nearbynum;
end

function GetNumOfAliveHeroes(team)
	local nearbynum = 0;
	for i,id in pairs(GetTeamPlayers(team)) do
		if IsHeroAlive(id) then
			nearbynum = nearbynum + 1;
		end
	end
	return nearbynum;
end

function GetRemainingRespawnTime()
	if TimeDeath == nil then
		return 0;
	else
		return npcBot:GetRespawnTime() - ( DotaTime() - TimeDeath );
	end
end

function IsMeepoClone()
	if npcBot:GetUnitName() == "npc_dota_hero_meepo" and npcBot:GetLevel() > 1 
	then
		for i=0, 5 do
			local item = npcBot:GetItemInSlot(i);
			if item ~= nil and not ( string.find(item:GetName(),"boots") or string.find(item:GetName(),"treads") )  
			then
				return false;
			end
		end
		return true;
    end
	return false;
end

function BuybackUsageThink() 
	
	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() or IsMeepoClone() then
		return;
	end
	
	if npcBot:IsAlive() and TimeDeath ~= nil then
		TimeDeath = nil;
	end
	
	if not npcBot:HasBuyback() then
		return;
	end

	if not npcBot:IsAlive() then
		if TimeDeath == nil then
			TimeDeath = DotaTime();
		end
		--print(npcBot:GetUnitName()..":"..tostring(npcBot:GetRespawnTime()).."><"..tostring(RespawnTime))
	end
	
	local RespawnTime = GetRemainingRespawnTime();
	
	if RespawnTime < 10 then
		return;
	end
	
	local ancient = GetAncient(GetTeam());
	
	if ancient ~= nil 
	then
		local nEnemies = GetNumEnemyNearby(ancient);
		if  nEnemies > 0 and nEnemies >= GetNumOfAliveHeroes(GetTeam()) then		
			npcBot:ActionImmediate_Buyback();
			return;
		end	
	end

end

--[[function ItemUsageThink()
	--print(npcBot:GetUnitName().."item usage")
	if GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	
	UnImplementedItemUsage()
	--UseShrine()
end]]--

function PrintCourierState(state)
	
		if state == 0 then
			print("COURIER_STATE_IDLE ");
		elseif state == 1 then
			print("COURIER_STATE_AT_BASE");
		elseif state == 2 then
			print("COURIER_STATE_MOVING");
		elseif state == 3 then
			print("COURIER_STATE_DELIVERING_ITEMS");
		elseif state == 4 then
			print("COURIER_STATE_RETURNING_TO_BASE");
		elseif state == 5 then
			print("COURIER_STATE_DEAD");
		else
			print("UNKNOWN");
		end
		
end

local courierTime = -90;
local cState = -1;
npcBot.SShopUser = false;
local returnTime = -90;
local apiAvailable = false;
function CourierUsageThink()

	if npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() or npcBot:HasModifier("modifier_arc_warden_tempest_double") or GetNumCouriers() == 0 then
		return;
	end
	
	local npcCourier = GetCourier(0);	
	local cState = GetCourierState( npcCourier );

	local courierPHP = npcCourier:GetHealth() / npcCourier:GetMaxHealth(); 
	
	if cState == COURIER_STATE_DEAD then
		npcCourier.latestUser = nil;
		return
	end
	
	if IsFlyingCourier(npcCourier) then
		local burst = npcCourier:GetAbilityByName('courier_shield');
		if IsTargetedByUnit(npcCourier) then
			if burst:IsFullyCastable() and apiAvailable == true 
			then
				npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_BURST );
				return
			elseif DotaTime() > returnTime + 7.0
			       --and not burst:IsFullyCastable() and not npcCourier:HasModifier('modifier_courier_shield') 
			then
				npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
				returnTime = DotaTime();
				return
			end
		end
	else	
		if IsTargetedByUnit(npcCourier) then
			if DotaTime() - returnTime > 7.0 then
				npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
				returnTime = DotaTime();
				return
			end
		end
	end
	
	if ( IsCourierAvailable() and cState ~= COURIER_STATE_IDLE )  then
		npcCourier.latestUser = "temp";
	end
	
	--FREE UP THE COURIER FOR HUMAN PLAYER
	if cState == COURIER_STATE_MOVING or IsHumanHaveItemInCourier() then
		npcCourier.latestUser = nil;
	end
	
	if npcBot.SShopUser and ( not npcBot:IsAlive() or npcBot:GetActiveMode() == BOT_MODE_SECRET_SHOP or not npcBot.SecretShop  ) then
		--npcBot:ActionImmediate_Chat( "Releasing the courier to anticipate secret shop stuck", true );
		npcCourier.latestUser = "temp";
		npcBot.SShopUser = false;
		npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
		return
	end
	
	if npcCourier.latestUser ~= nil and ( IsCourierAvailable() or cState == COURIER_STATE_RETURNING_TO_BASE ) and DotaTime() - returnTime > 7.0  then 
		
		if cState == COURIER_STATE_AT_BASE and courierPHP < 1.0 then
			return;
		end
		
		--RETURN COURIER TO BASE WHEN IDLE 
		if cState == COURIER_STATE_IDLE then
			npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN );
			return
		end
		
		--TAKE ITEM FROM STASH
		if  cState == COURIER_STATE_AT_BASE then
			local nCSlot = GetCourierEmptySlot(npcCourier);
			local numPlayer =  GetTeamPlayers(GetTeam());
			for i = 1, #numPlayer
			do
				local member =  GetTeamMember(i);
				if member ~= nil and IsPlayerBot(numPlayer[i]) and member:IsAlive() 
				then
					local nMSlot = GetNumStashItem(member);
					if nMSlot > 0 and nMSlot <= nCSlot then
						member:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_STASH_ITEMS );
						nCSlot = nCSlot - nMSlot ;
						courierTime = DotaTime();
					end
				end
			end
		end
		
		--MAKE COURIER GOES TO SECRET SHOP
		if  npcBot:IsAlive() and npcBot.SecretShop and npcCourier:DistanceFromFountain() < 7000 and DotaTime() > courierTime + 1.0 then
			--npcBot:ActionImmediate_Chat( "Using Courier for secret shop.", true );
			npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_SECRET_SHOP )
			npcCourier.latestUser = npcBot;
			npcBot.SShopUser = true;
			UpdateSShopUserStatus(npcBot);
			courierTime = DotaTime();
			return
		end
		
		--TRANSFER ITEM IN COURIER
		if npcBot:IsAlive() and IsTheClosestToCourier(npcBot, npcCourier) and npcCourier:DistanceFromFountain() < 7000 and DotaTime() > courierTime + 1.0
		then
			npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
			npcCourier.latestUser = npcBot;
			courierTime = DotaTime();
			return
		end
		
		--RETURN STASH ITEM WHEN DEATH
		if  not npcBot:IsAlive() and cState == COURIER_STATE_DELIVERING_ITEMS  
			and npcBot:GetCourierValue( ) > 0 and DotaTime() > courierTime + 1.0
		then
			npcBot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS );
			npcCourier.latestUser = npcBot;
			courierTime = DotaTime();
			return
		end
		
	
	end
end

function IsHumanHaveItemInCourier()
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		if not IsPlayerBot(numPlayer[i]) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() and member:GetCourierValue( ) > 0 
			then
				return true;
			end
		end
	end
	return false;
end

function IsTheClosestToCourier(npcBot, npcCourier)
	local numPlayer =  GetTeamPlayers(GetTeam());
	local closest = nil;
	local closestD = 100000;
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and IsPlayerBot(numPlayer[i]) and member:IsAlive() and member:GetCourierValue( ) > 0 and  not IsInvFull(member)
		then
			local dist = GetUnitToUnitDistance(member, npcCourier);
			if dist < closestD then
				closest = member;
				closestD = dist;
			end
		end
	end
	return closest ~= nil and closest == npcBot
end

function GetCourierEmptySlot(courier)
	local amount = 0;
	for i=0, 8 do
		if courier:GetItemInSlot(i) == nil then
			amount = amount + 1;
		end
	end
	return amount;
end

function GetNumStashItem(unit)
	local amount = 0;
	for i=9, 14 do
		if unit:GetItemInSlot(i) ~= nil then
			amount = amount + 1;
		end
	end
	return amount;
end

function UpdateSShopUserStatus(bot)
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and IsPlayerBot(numPlayer[i]) and  member:GetUnitName() ~= bot:GetUnitName() 
		then
			member.SShopUser = false;
		end
	end
end

function IsTargetedByUnit(courier)
	for i = 0, 10 do
	local tower = GetTower(GetOpposingTeam(), i)
		if tower ~= nil and tower:GetAttackTarget() == courier then
			return true;
		end
	end
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil and GetUnitToLocationDistance(courier, dInfo.location) <= 700 and dInfo.time_since_seen < 0.5 then
					return true;
				end
			end
		end
	end
	return false;
end

function IsInvFull(npcHero)
	for i=0, 8 do
		if(npcHero:GetItemInSlot(i) == nil) then
			return false;
		end
	end
	return true;
end

function CanCastOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end
function CanCastOnMagicImmuneTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsInvulnerable();
end

function IsDisabled(npcTarget)
	if npcTarget:IsRooted( ) or npcTarget:IsStunned( ) or npcTarget:IsHexed( ) or npcTarget:IsSilenced() or npcTarget:IsNightmared() then
		return true;
	end
	return false;
end

function UseConsumables()

	

end

function GiveToMidLaner()
	local teamPlayers = GetTeamPlayers(GetTeam())
	local target = nil;
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and not member:IsIllusion() and member:IsAlive() then
			local num_stg = GetItemCount(member, "item_tango_single"); 
			local num_ff = GetItemCount(member, "item_faerie_fire"); 
			if num_ff > 0 and num_stg < 1 then
				return member;
			end
		end
	end
	return nil;
end

function GetItemCount(unit, item_name)
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end

function CanSwitchPTStat(pt)
	if npcBot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and pt:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH then
		return true;
	elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY  and pt:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT then
		return true;
	elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and pt:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY then
		return true;
	end 
	return false;
end

local giveTime = -90;
function UnImplementedItemUsage()

	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted( ) then
		return;
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	local npcTarget = npcBot:GetTarget();
	local mode = npcBot:GetActiveMode();
	
	local pt = IsItemAvailable("item_power_treads");
	if pt~=nil and pt:IsFullyCastable() then
		if mode == BOT_MODE_RETREAT and pt:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH and npcBot:WasRecentlyDamagedByAnyHero(5.0) then
			npcBot:Action_UseAbility(pt);
			return
		elseif mode == BOT_MODE_ATTACK and CanSwitchPTStat(pt) then
			npcBot:Action_UseAbility(pt);
			return
		else
			local enemies = npcBot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
			if #enemies == 0 and  mode ~= BOT_MODE_RETREAT and CanSwitchPTStat(pt)  then
				npcBot:Action_UseAbility(pt);
				return
			end
		end
	end
	
	local bas = IsItemAvailable("item_ring_of_basilius");
	if bas~=nil and bas:IsFullyCastable() then
		if mode == BOT_MODE_LANING and not bas:GetToggleState() then
			npcBot:Action_UseAbility(bas);
			return
		elseif mode ~= BOT_MODE_LANING and bas:GetToggleState() then
			npcBot:Action_UseAbility(bas);
			return
		end
	end
	
	local aq = IsItemAvailable("item_ring_of_aquila");
	if aq~=nil and aq:IsFullyCastable() then
		if mode == BOT_MODE_LANING and not aq:GetToggleState() then
			npcBot:Action_UseAbility(aq);
			return
		elseif mode ~= BOT_MODE_LANING and aq:GetToggleState() then
			npcBot:Action_UseAbility(aq);
			return
		end
	end
	
	local itg=IsItemAvailable("item_tango");
	if itg~=nil and itg:IsFullyCastable() then
		local tCharge = itg:GetCurrentCharges()
		if DotaTime() > -80 and DotaTime() < 0 and npcBot:DistanceFromFountain() == 0 and role.CanBeSupport(npcBot:GetUnitName())
		   and npcBot:GetAssignedLane() ~= LANE_MID and tCharge > 2 and DotaTime() > giveTime + 2.0 then
			local target = GiveToMidLaner()
			if target ~= nil then
				npcBot:ActionImmediate_Chat(string.gsub(npcBot:GetUnitName(),"npc_dota_hero_","")..
						" giving tango to "..
						string.gsub(target:GetUnitName(),"npc_dota_hero_","")
						, false);
				npcBot:Action_UseAbilityOnEntity(itg, target);
				giveTime = DotaTime();
				return;
			end
		elseif npcBot:GetActiveMode() == BOT_MODE_LANING and role.CanBeSupport(npcBot:GetUnitName()) and tCharge > 1 and DotaTime() > giveTime + 2.0 then
			local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			for _,ally in pairs(allies)
			do
				local tangoSlot = ally:FindItemSlot('item_tango');
				if ally:GetUnitName() ~= npcBot:GetUnitName() and not ally:IsIllusion() 
				   and tangoSlot == -1 and GetItemCount(ally, "item_tango_single") == 0 
				then
					npcBot:Action_UseAbilityOnEntity(itg, ally);
					giveTime = DotaTime();
					return
				end
			end
		end
	end
	
	local bdg=IsItemAvailable("item_blink");
	if bdg~=nil and bdg:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using blink while stuck.", true);
			npcBot:Action_UseAbilityOnLocation(bdg, npcBot:GetXUnitsTowardsLocation( GetAncient(GetTeam()):GetLocation(), 1100 ));
			return;
		end
	end
	
	local fst=IsItemAvailable("item_force_staff");
	if fst~=nil and fst:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using force staff while stuck.", true);
			npcBot:Action_UseAbilityOnEntity(fst, npcBot);
			return;
		end
	end
	
	local tpt=IsItemAvailable("item_tpscroll");
	if tpt~=nil and tpt:IsFullyCastable() then
		if mutil.IsStuck(npcBot)
		then
			npcBot:ActionImmediate_Chat("I'm using tp while stuck.", true);
			npcBot:Action_UseAbilityOnLocation(tpt, GetAncient(GetTeam()):GetLocation());
			return;
		end
	end
	
	local its=IsItemAvailable("item_tango_single");
	if its~=nil and its:IsFullyCastable() and npcBot:DistanceFromFountain() > 1300 then
		if DotaTime() > 10*60 
		then
			local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			local trees = npcBot:GetNearbyTrees(1300);
			
			if trees[1] ~= nil and #tableNearbyEnemyHeroes == 0 and GetHeightLevel(npcBot:GetLocation()) == GetHeightLevel(GetTreeLocation(trees[1])) then
				if npcBot:GetUnitName() == 'npc_dota_hero_lion' then
					print("Bot"..tostring( GetHeightLevel(npcBot:GetLocation())))
					print("Tree"..tostring( GetHeightLevel(GetTreeLocation(trees[1]))))
				end
				npcBot:Action_UseAbilityOnTree(its, trees[1]);
				return;
			end
		end
	end
	
	local irt=IsItemAvailable("item_iron_talon");
	if irt~=nil and irt:IsFullyCastable() then
		if npcBot:GetActiveMode() == BOT_MODE_FARM 
		then
			local neutrals = npcBot:GetNearbyNeutralCreeps(500);
			local maxHP = 0;
			local target = nil;
			for _,c in pairs(neutrals) do
				local cHP = c:GetHealth();
				if cHP > maxHP and not c:IsAncientCreep() then
					maxHP = cHP;
					target = c;
				end
			end
			if target ~= nil then
				npcBot:Action_UseAbilityOnEntity(irt, target);
				return;
			end
		end
	end
	
	local msh=IsItemAvailable("item_moon_shard");
	if msh~=nil and msh:IsFullyCastable() then
		if not npcBot:HasModifier("modifier_item_moon_shard_consumed")
		then
			npcBot:Action_UseAbilityOnEntity(msh, npcBot);
			return;
		end
	end
	
	local mg=IsItemAvailable("item_enchanted_mango");
	if mg~=nil and mg:IsFullyCastable() then
		if npcBot:GetMaxMana() - npcBot:GetMana() > 150 
		then
			npcBot:Action_UseAbility(mg);
			return;
		end
	end
	
	local tok=IsItemAvailable("item_tome_of_knowledge");
	if tok~=nil and tok:IsFullyCastable() then
		npcBot:Action_UseAbility(tok);
		return;
	end
	
	local ff=IsItemAvailable("item_faerie_fire");
	if ff~=nil and ff:IsFullyCastable() then
		if ( mode == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			npcBot:DistanceFromFountain() > 0 and
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.15 ) or DotaTime() > 10*60
		then
			npcBot:Action_UseAbility(ff);
			return;
		end
	end
	
	local bst=IsItemAvailable("item_bloodstone");
	if bst ~= nil and bst:IsFullyCastable() then
		if  mode == BOT_MODE_RETREAT and 
			npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			( npcBot:GetHealth() / npcBot:GetMaxHealth() ) < 0.10 - ( npcBot:GetLevel() / 500 )
		then
			npcBot:Action_UseAbilityOnLocation(bst, npcBot:GetLocation());
			return;
		end
	end
	
	local pb=IsItemAvailable("item_phase_boots");
	if pb~=nil and pb:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_RETREAT or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			npcBot:Action_UseAbility(pb);
			return;
		end	
	end
	
	local bt=IsItemAvailable("item_bloodthorn");
	if bt~=nil and bt:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			local npcTarget = npcBot:GetTarget();
			if ( npcTarget ~= nil and npcTarget:IsHero() and CanCastOnTarget(npcTarget) and not npcTarget:IsSilenced() and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(bt,npcTarget);
				return
			end
		end
	end
	
	local sc=IsItemAvailable("item_solar_crest");
	if sc~=nil and sc:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_ATTACK or
			 mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK or
			 mode == BOT_MODE_DEFEND_ALLY )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() 
			   and not npcTarget:HasModifier('modifier_item_solar_crest_armor_reduction') 
			   and not npcTarget:IsMagicImmune()
			   and GetUnitToUnitDistance(npcTarget, npcBot) < 900 )
			then
			    npcBot:Action_UseAbilityOnEntity(sc, npcTarget);
				return
			end
		end
	end
	
	if sc~=nil and sc:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if Ally:GetUnitName() ~= npcBot:GetUnitName() and not Ally:HasModifier('modifier_item_solar_crest_armor_reduction') and
			   ( ( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and CanCastOnTarget(Ally) ) or 
				 ( IsDisabled(Ally) and CanCastOnTarget(Ally) ) )
			then
				npcBot:Action_UseAbilityOnEntity(sc,Ally);
				return;
			end
		end
	end
	
	local se=IsItemAvailable("item_silver_edge");
    if se ~= nil and se:IsFullyCastable() then
		if mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH and 
			tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0
		then
			npcBot:Action_UseAbility(se);
			return;
	    end
		if ( mode == BOT_MODE_ROAM or
			 mode == BOT_MODE_TEAM_ROAM or
			 mode == BOT_MODE_GANK )
		then
			if ( npcTarget ~= nil and npcTarget:IsHero() and GetUnitToUnitDistance(npcTarget, npcBot) > 1000 and  GetUnitToUnitDistance(npcTarget, npcBot) < 2500 )
			then
			    npcBot:Action_UseAbility(se);
				return;
			end
		end
	end
	
	local hood=IsItemAvailable("item_hood_of_defiance");
    if hood~=nil and hood:IsFullyCastable() and npcBot:GetHealth()/npcBot:GetMaxHealth()<0.8 and not npcBot:HasModifier('modifier_item_pipe_barrier')
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
			npcBot:Action_UseAbility(hood);
			return;
		end
	end
	
	local lotus=IsItemAvailable("item_lotus_orb");
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		if  not npcBot:HasModifier('modifier_item_lotus_orb_active') 
			and not npcBot:IsMagicImmune()
			and ( npcBot:IsSilenced() or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.35 + (0.05*#tableNearbyEnemyHeroes) ) )
	    then
			npcBot:Action_UseAbilityOnEntity(lotus,npcBot);
			return;
		end
	end
	
	if lotus~=nil and lotus:IsFullyCastable() 
	then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  not Ally:HasModifier('modifier_item_lotus_orb_active') 
				and not Ally:IsMagicImmune()
			    and (( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 )  or 
				IsDisabled(Ally))
			then
				npcBot:Action_UseAbilityOnEntity(lotus,Ally);
				return;
			end
		end
	end
	
	local hurricanpike = IsItemAvailable("item_hurricane_pike");
	if hurricanpike~=nil and hurricanpike:IsFullyCastable() 
	then
		if ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( GetUnitToUnitDistance( npcEnemy, npcBot ) < 400 and CanCastOnTarget(npcEnemy) )
				then
					npcBot:Action_UseAbilityOnEntity(hurricanpike,npcEnemy);
					return
				end
			end
			if npcBot:IsFacingLocation(GetAncient(GetTeam()):GetLocation(),10) and npcBot:DistanceFromFountain() > 0 
			then
				npcBot:Action_UseAbilityOnEntity(hurricanpike,npcBot);
				return;
			end
		end
	end
	
	local glimer=IsItemAvailable("item_glimmer_cape");
	if glimer~=nil and glimer:IsFullyCastable() then
		if  not npcBot:HasModifier('modifier_item_glimmer_cape') 
			and not npcBot:IsMagicImmune()
			and ( npcBot:IsSilenced() or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.35 + (0.05*#tableNearbyEnemyHeroes) ) )
	    then	
			npcBot:Action_UseAbilityOnEntity(glimer,npcBot);
			return;
		end
	end
	
	if glimer~=nil and glimer:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if not Ally:HasModifier('modifier_item_glimmer_cape') 
			   and not Ally:IsMagicImmune()
			   and (( Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 ) or IsDisabled(Ally))
			then
				npcBot:Action_UseAbilityOnEntity(glimer,Ally);
				return;
			end
		end
	end
	
	local hod=IsItemAvailable("item_helm_of_the_dominator");
	if hod~=nil and hod:IsFullyCastable() 
	then
		local maxHP = 0;
		local NCreep = nil;
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( 1000, true );
		if #tableNearbyCreeps >= 2 
		then
			for _,creeps in pairs(tableNearbyCreeps)
			do
				local CreepHP = creeps:GetHealth();
				if CreepHP > maxHP and ( creeps:GetHealth() / creeps:GetMaxHealth() ) > .75  and not creeps:IsAncientCreep()
				then
					NCreep = creeps;
					maxHP = CreepHP;
				end
			end
		end
		if NCreep ~= nil then
			npcBot:Action_UseAbilityOnEntity(hod,NCreep);
			return
		end	
	end
	
	local guardian=IsItemAvailable("item_guardian_greaves");
	if guardian~=nil and guardian:IsFullyCastable() then
		local Allies=npcBot:GetNearbyHeroes(1000,false,BOT_MODE_NONE);
		for _,Ally in pairs(Allies) do
			if  Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 
			then
				npcBot:Action_UseAbility(guardian);
				return;
			end
		end
	end
	
	local satanic=IsItemAvailable("item_satanic");
	if satanic~=nil and satanic:IsFullyCastable() then
		if  npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.50 and 
			tableNearbyEnemyHeroes~=nil and #tableNearbyEnemyHeroes > 0 and 
			npcBot:GetActiveMode() == BOT_MODE_ATTACK
		then
			npcBot:Action_UseAbility(satanic);
			return;
		end
	end
	
	local cyclone=IsItemAvailable("item_cyclone");
	if cyclone~=nil and cyclone:IsFullyCastable() then
		if npcTarget ~= nil and ( npcTarget:HasModifier('modifier_teleporting') or npcTarget:HasModifier('modifier_abaddon_borrowed_time') ) 
		   and CanCastOnTarget(npcTarget) and GetUnitToUnitDistance(npcBot, npcTarget) < 775
		then
			npcBot:Action_UseAbilityOnEntity(cyclone, npcTarget);
			return;
		end
	end
	
	local metham=IsItemAvailable("item_meteor_hammer");
	if metham~=nil and metham:IsFullyCastable() then
		if mutil.IsPushing(npcBot) then
			local towers = npcBot:GetNearbyTowers(800, true);
			if #towers > 0 and towers[1] ~= nil and  towers[1]:IsInvulnerable() == false then 
				npcBot:Action_UseAbilityOnLocation(metham, towers[1]:GetLocation());
				return;
			end
		elseif  mutil.IsInTeamFight(npcBot, 1200) then
			local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 600, 300, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				npcBot:Action_UseAbilityOnLocation(metham, locationAoE.targetloc);
				return;
			end
		elseif mutil.IsGoingOnSomeone(npcBot) then
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800) 
			   and mutil.IsDisabled(true, npcTarget) == true	
			then
				npcBot:Action_UseAbilityOnLocation(metham, npcTarget:GetLocation());
				return;
			end
		end
	end
	
	local sv=IsItemAvailable("item_spirit_vessel");
	if sv~=nil and sv:IsFullyCastable() and sv:GetCurrentCharges() > 0
	then
		if mutil.IsGoingOnSomeone(npcBot)
		then
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 900) 
			   and npcTarget:HasModifier("modifier_item_spirit_vessel_damage") == false and npcTarget:GetHealth()/npcTarget:GetMaxHealth() < 0.65
			then
			    npcBot:Action_UseAbilityOnEntity(sv, npcTarget);
				return;
			end
		else
			local Allies=npcBot:GetNearbyHeroes(1150,false,BOT_MODE_NONE);
			for _,Ally in pairs(Allies) do
				if Ally:HasModifier('modifier_item_spirit_vessel_heal') == false and mutil.CanCastOnNonMagicImmune(Ally) and
				   Ally:GetHealth()/Ally:GetMaxHealth() < 0.35 and #tableNearbyEnemyHeroes == 0 and Ally:WasRecentlyDamagedByAnyHero(2.5) == false   
				then
					npcBot:Action_UseAbilityOnEntity(sv,Ally);
					return;
				end
			end
		end
	end
	
	local null=IsItemAvailable("item_nullifier");
	if null~=nil and null:IsFullyCastable() 
	then
		if mutil.IsGoingOnSomeone(npcBot)
		then	
			if mutil.IsValidTarget(npcTarget) and mutil.CanCastOnNonMagicImmune(npcTarget) and mutil.IsInRange(npcTarget, npcBot, 800) 
			   and npcTarget:HasModifier("modifier_item_nullifier_mute") == false 
			then
			    npcBot:Action_UseAbilityOnEntity(null, npcTarget);
				return;
			end
		end
	end
	
end

function IsItemAvailable(item_name)
    for i = 0, 5 do
        local item = npcBot:GetItemInSlot(i);
		if item~=nil and item:GetName() == item_name then
			return item;
		end
    end
    return nil;
end

function IsTargetedByEnemy(building)
	local heroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _,hero in pairs(heroes)
	do
		if ( GetUnitToUnitDistance(building, hero) <= hero:GetAttackRange() + 200 and hero:GetAttackTarget() == building ) then
			return true;
		end
	end
	return false;
end

function UseGlyph()

	if GetGlyphCooldown( ) > 0 then
		return
	end	
	
	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_3,
		TOWER_MID_3, 
		TOWER_BOT_3, 
		TOWER_BASE_1, 
		TOWER_BASE_2
	}
	
	for _,t in pairs(T1)
	do
		local tower = GetTower(GetTeam(), t);
		if  tower ~= nil and tower:GetHealth() > 0 and tower:GetHealth()/tower:GetMaxHealth() < 0.15 and tower:GetAttackTarget() ~=  nil
		then
			npcBot:ActionImmediate_Glyph( )
			return
		end
	end
	

	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}
	
	for _,b in pairs(MeleeBarrack)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil and barrack:GetHealth() > 0 and barrack:GetHealth()/barrack:GetMaxHealth() < 0.5 and IsTargetedByEnemy(barrack)
		then
			npcBot:ActionImmediate_Glyph( )
			return
		end
	end
	
	local Ancient = GetAncient(GetTeam())
	if Ancient ~= nil and Ancient:GetHealth() > 0 and Ancient:GetHealth()/Ancient:GetMaxHealth() < 0.5 and IsTargetedByEnemy(Ancient)
	then
		npcBot:ActionImmediate_Glyph( )
		return
	end

end

--[[this chunk prevents dota_bot_reload_scripts from breaking your 
    item/skill builds.  Note the script doesn't account for 
    consumables. ]]

-- check skill build vs current level
local npcBot = GetBot()
local ability_name = BotAbilityPriority[1];
local ability = GetBot():GetAbilityByName(ability_name);
--print(ability:GetLevel())
if(ability ~= nil and ability:GetLevel() > 0) then
    --print (#BotAbilityPriority .. " > " .. "25 - " .. npcBot:GetLevel())
    if #BotAbilityPriority > (25 - npcBot:GetLevel()) then
        --print(#BotAbilityPriority - (25 - npcBot:GetLevel()))
        for i=1, (#BotAbilityPriority - (25 - npcBot:GetLevel())) do
            table.remove(BotAbilityPriority, 1)
        end
    end
end

return MyModule;

