local role = require(GetScriptDirectory() .. "/RoleUtility");
local bnUtil = require(GetScriptDirectory() .. "/BotNameUtility");
local utils = require(GetScriptDirectory() .. "/util");

local hero_roles = role["hero_roles"];
-- mandate that the bots will pick these heroes - for testing purposes
local requiredHeroes = {
	'npc_dota_hero_broodmother',
	'npc_dota_hero_dawnbreaker',
	'npc_dota_hero_hoodwink',
};

local UnImplementedHeroes = {
	
};

----------------------------------------------------------GIVE THE BOT A PRO PLAYER NAME---------------------------------------------------------------------------------------------
function GetBotNames ()
	return bnUtil.GetDota2Team();
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- change quickMode to true for testing
-- quickMode eliminates the 30s delay before picks begin
-- it also eliminates the delay between bot picks
local quickMode = false;
local testMode = false;

local allBotHeroes = {
	'npc_dota_hero_dawnbreaker',
	'npc_dota_hero_hoodwink',
    'npc_dota_hero_snapfire',
	'npc_dota_hero_void_spirit',
	'npc_dota_hero_mars',
	'npc_dota_hero_pangolier',
	'npc_dota_hero_dark_willow',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_earth_spirit',
	'npc_dota_hero_phoenix',
	'npc_dota_hero_terrorblade',
	'npc_dota_hero_morphling',
	'npc_dota_hero_shredder',
	'npc_dota_hero_broodmother',
	'npc_dota_hero_antimage',
	'npc_dota_hero_dark_seer',
	'npc_dota_hero_weaver',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_batrider',
	'npc_dota_hero_lone_druid',
    'npc_dota_hero_wisp',
    'npc_dota_hero_chen',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_alchemist',
	'npc_dota_hero_tinker',
	'npc_dota_hero_furion',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_rubick',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_mirana',
	'npc_dota_hero_medusa',
	'npc_dota_hero_spectre',
	'npc_dota_hero_enigma',
	'npc_dota_hero_visage',
	'npc_dota_hero_riki',
	'npc_dota_hero_lycan',
	'npc_dota_hero_clinkz',
	'npc_dota_hero_techies',
	'npc_dota_hero_winter_wyvern',
	'npc_dota_hero_pugna',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_silencer',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_enchantress',
	'npc_dota_hero_nyx_assassin',
	'npc_dota_hero_storm_spirit',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_spirit_breaker',
        'npc_dota_hero_axe',
        'npc_dota_hero_bane',
	'npc_dota_hero_beastmaster',
        'npc_dota_hero_bloodseeker',
        'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_brewmaster',
        'npc_dota_hero_bristleback',
	'npc_dota_hero_centaur',
        'npc_dota_hero_chaos_knight',
        'npc_dota_hero_crystal_maiden',
        'npc_dota_hero_dazzle',
        'npc_dota_hero_death_prophet',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_doom_bringer',
        'npc_dota_hero_dragon_knight',
        'npc_dota_hero_drow_ranger',
        'npc_dota_hero_earthshaker',
	'npc_dota_hero_elder_titan',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_gyrocopter',
	'npc_dota_hero_huskar',
    'npc_dota_hero_invoker',
        'npc_dota_hero_jakiro',
        'npc_dota_hero_juggernaut',
        'npc_dota_hero_kunkka',
	'npc_dota_hero_legion_commander',
        'npc_dota_hero_lich',
	'npc_dota_hero_life_stealer',
        'npc_dota_hero_lina',
        'npc_dota_hero_lion',
        'npc_dota_hero_luna',
	'npc_dota_hero_magnataur',
    'npc_dota_hero_meepo',
	'npc_dota_hero_monkey_king',
	'npc_dota_hero_naga_siren',
        'npc_dota_hero_necrolyte',
        'npc_dota_hero_nevermore',
	'npc_dota_hero_night_stalker',
	'npc_dota_hero_ogre_magi',
        'npc_dota_hero_omniknight',
        'npc_dota_hero_oracle',
        'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_phantom_lancer',
    'npc_dota_hero_puck',
        'npc_dota_hero_pudge',
    'npc_dota_hero_rattletrap',
        'npc_dota_hero_razor',
        'npc_dota_hero_sand_king',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_shadow_shaman',
        'npc_dota_hero_skeleton_king',
        'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_slardar',
	'npc_dota_hero_slark',
        'npc_dota_hero_sniper',
        'npc_dota_hero_sven',
        'npc_dota_hero_tidehunter',
        'npc_dota_hero_tiny',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	'npc_dota_hero_ursa',
        'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_venomancer',
        'npc_dota_hero_viper',
        'npc_dota_hero_warlock',
        'npc_dota_hero_windrunner',
        'npc_dota_hero_witch_doctor',
        'npc_dota_hero_zuus'
};

local picks = {};
local maxPlayerID = 15;
-- CHANGE THESE VALUES IF YOU'RE GETTING BUGS WITH BOTS NOT PICKING (or infinite loops)
-- To find appropriate values, start a game, open a console, and observe which slots are
-- being used by which players/teams. maxPlayerID shoulud just be the highest-numbered
-- slot in use.

local slots = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
-- TODO
-- 1. determine which slots contain players - don't pick for those slots
-- 2. determine what heroes have already been picked - don't pick those heroes - DONE
-- 4. copy the default behavior of picking everything at once after players have picked, though
-- 5. add some jitter, so the bots pick at slightly more random times
-- 6. reimplement farm priority based system
local ListPickedHeroes = {};
local AllHeroesSelected = false;
local BanCycle = 1;
local PickCycle = 1;
local NeededTime = 29;
local Min = 27;
local Max = 28;
local CMTestMode = false;
local UnavailableHeroes = {
	'npc_dota_hero_dawnbreaker'
}
local HeroLanes = {
	[1] = LANE_MID,
	[2] = LANE_TOP,
	[3] = LANE_TOP,
	[4] = LANE_BOT,
	[5] = LANE_BOT,
};

local PairsHeroNameNRole = {};
local humanPick = {};

-----------------------------------------------------SELECT HERO FOR BOT WITH CHAT FEATURE-------------------------------------------
--function to get hero name that match the expression
function GetHumanChatHero(name)
	if name == nil then return ""; end	
	for _,hero in  pairs(allBotHeroes) do
		if string.find(hero, name) then
			return hero;
		end
	end
	return "";
end	
--function to decide which team should get the hero
function SelectHeroChatCallback(PlayerID, ChatText, bTeamOnly)
	local text = string.lower(ChatText);
	local hero = GetHumanChatHero(text);
	if hero ~= "" then
		if bTeamOnly then
			for _,id in pairs(GetTeamPlayers(GetTeam())) 
			do
				if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
					SelectHero(id, hero);
					break;
				end
			end	
		elseif bTeamOnly == false and GetTeamForPlayer(PlayerID) ~= GetTeam() then
			for _,id in pairs(GetTeamPlayers(GetTeam())) 
			do
				if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
					SelectHero(id, hero);
					break;
				end
			end			
		end
	else
		print("Hero name not found! Please refer to hero_selection.lua of this script for list of heroes's name");
	end
end
--function to random all bot heroes
function SelectRandomHeroesForBot(PlayerID, ChatText, bTeamOnly)
	local text = string.lower(ChatText);
	if text == 'random' and ( GetTeamForPlayer(PlayerID) == GetTeam() or GetTeamForPlayer(PlayerID) ~= GetTeam() ) then
		for _,id in pairs(GetTeamPlayers(GetTeam())) 
		do
			if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
				hero = GetRandomHero(); 
				SelectHero(id, hero);
			end
		end	
	else
		print("Command Not Found!");
	end
end
----------------------------------------------------------------------------------------------------------------------------------------
local GAMEMODE_TM = 23;
function Think()
	if GetGameMode() == GAMEMODE_AP then
		if GetGameState() == GAME_STATE_HERO_SELECTION then
			InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
		end
		AllPickLogic();
	elseif GetGameMode() == GAMEMODE_CM then
		CaptainModeLogic();
		AddToList();
	elseif GetGameMode() == GAMEMODE_AR then
		AllRandomLogic();
	elseif GetGameMode() == GAMEMODE_MO then
		if GetGameState() == GAME_STATE_HERO_SELECTION then
			InstallChatCallback(function (attr) SelectRandomHeroesForBot(attr.player_id, attr.string, attr.team_only); end);
		end
		MidOnlyLogic();	
	elseif GetGameMode() == GAMEMODE_1V1MID then
		OneVsOneLogic();		
	elseif  GetGameMode() == GAMEMODE_SD then
		if GetGameState() == GAME_STATE_HERO_SELECTION then
			InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
		end
		SingleDraftLogic();
	elseif GetGameMode() == GAMEMODE_TM then
		if GetGameState() == GAME_STATE_HERO_SELECTION then
			InstallChatCallback(function (attr) SelectHeroChatCallback(attr.player_id, attr.string, attr.team_only); end);
		end
		NewTurboModeLogic();		
	else 
		print("GAME MODE NOT SUPPORTED")
	end
end

local function IsHumanDonePickingFirstSlot()
	if GetTeam() == TEAM_RADIANT then
		for _,id in pairs(GetTeamPlayers(GetTeam())) do
			if IsPlayerBot(id) == false and GetSelectedHeroName(id) ~= "" then
				return true;
			end
		end
	else
		for _,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
			if IsPlayerBot(id) == false and GetSelectedHeroName(id) ~= "" then
				return true;
			end
		end
	end
end

local function IsHumanPlayerInRadiant1Slot()
	if GetTeam() == TEAM_RADIANT then
		for i,id in pairs(GetTeamPlayers(GetTeam())) do
			if i == 1 and IsPlayerBot(id) == false then
				return true;
			end
		end
	else
		for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) do
			if i == 1 and IsPlayerBot(id) == false then
				return true;
			end
		end
	end
	return false;
end

local lastpick = 10;
local tmstate = -99;
function NewTurboModeLogic()
	if GetHeroPickState() == 60 and GameTime() >= 15 and GameTime() >= lastpick + 2 then
		for i,id in pairs(GetTeamPlayers(GetTeam())) do
			if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
				if testMode then
					hero = GetRandomHero() 
				else
					hero = PickRightHero(i-1) 
				end
				SelectHero(id, hero); 
				lastpick = GameTime();
				return;
			end
		end
	end
end

local humanInRad1Slot = nil;

function TurboModeLogic() 
	
	if #GetTeamPlayers(GetTeam()) < 5 or #GetTeamPlayers(GetOpposingTeam()) < 5 then return end  
	
	
	if humanInRad1Slot == nil then humanInRad1Slot = IsHumanPlayerInRadiant1Slot() return end
	
	--print(tostring(GetGameMode()).."=>"..tostring(GetGameState())..":"..tostring(DotaTime( ))..":"..tostring(GetHeroPickState()))
	if GetHeroPickState() == 55 and ( ( humanInRad1Slot == true and IsHumanDonePickingFirstSlot() and DotaTime() > -10 and DotaTime() < -5 ) 
	   or ( humanInRad1Slot == false and GameTime() > 10  and DotaTime() > -10 and DotaTime() < -5 ) ) 
    then
		for i,id in pairs(GetTeamPlayers(GetTeam())) 
		do 
			if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" 
			then 
				if testMode then
					hero = GetRandomHero() 
				else
					hero = PickRightHero(i-1) 
				end
				SelectHero(id, hero); 
				return;
			end
		end 
	end	
end

function SingleDraftLogic()
	--print(tostring(GetGameMode()).."=>"..tostring(GetGameState())..":"..tostring(DotaTime( ))..":"..tostring(GetHeroPickState()))
	if GetHeroPickState() == 2 and GameTime() >= 45 and GameTime() >= lastpick + 1.5 then
		for i,id in pairs(GetTeamPlayers(GetTeam())) do
			if IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == "" then
				if testMode then
					hero = GetRandomHero() 
				else
					hero = PickRightHero(i-1) 
				end
				SelectHero(id, hero); 
				lastpick = GameTime();
				return;
			end
		end
	end
end

local oboselect = false;
------------------------------------------1 VS 1 GAME MODE-------------------------------------------
function OneVsOneLogic()
	
	if IsHumanPlayerExist() then
		oboselect = true;
	end
	
	for _,i in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if not oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" 
		then
			if IsHumanPresentInGame() then
				hero = GetSelectedHumanHero(GetOpposingTeam()); 
			else
				hero = GetRandomHero();
			end
			if hero ~= nil then
				SelectHero(i, hero); 
				oboselect = true;
			end
			return
		elseif oboselect and IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" 
		then
			SelectHero(i, 'npc_dota_hero_techies'); 
			return
		end		
	end	
end
-------------------------------------------------------------------------------------------------------


------------------------------------------ALL PICK GAME MODE-------------------------------------------
local PickTime = 10;
local RandomTime = 0;
--Picking logic for All Pick Game Mode
function AllPickLogic()

	if not CanPick() then return end;
	 
	 local idx = 0;
	 for _,i in pairs(GetTeamPlayers(GetTeam())) 
	 do 
		if IsPlayerBot(i) and IsPlayerInHeroSelectionControl(i) and GetSelectedHeroName(i) == "" 
		then 
			if testMode then
				hero = GetRandomHero() 
			else
				hero = PickRightHero(idx) 
			end
			SelectHero(i, hero); 
			PickTime = GameTime();
			RandomTime = 0;
			return;
		end
		idx = idx + 1;
	end 
	idx = 0;
end
--Delay for picking between player in team
function CanPick()
	if not IsHumanPresentInGame() and RandomTime == 0 then RandomTime = RandomInt((30/5)/2,30/5); end
	if GameTime() > 60 or IsHumansDonePicking() then return true end
	if RandomTime ~= 0 and GameTime() >= PickTime + RandomTime then return true end
	return false;
end
-------------------------------------------------------------------------------------------------------


------------------------------------------CAPTAIN'S MODE GAME MODE-------------------------------------------
--Picking logic for Captain's Mode Game Mode
local lastState = -1;
function CaptainModeLogic()
	if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then
        return
    end
	if not CMTestMode then
		if NeededTime == 29 then
			NeededTime = RandomInt( Min, Max );
		elseif NeededTime == 0 then
			NeededTime = RandomInt( Min, Max );
		end
	elseif CMTestMode then
		NeededTime = 29;
	end	
	if GetHeroPickState() ~= lastState then
		--print('Pick State: '..tostring(GetHeroPickState()))
		lastState = GetHeroPickState();
	end
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then	
		PickCaptain();
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= 20 and GetCMPhaseTimeRemaining() <= NeededTime then
		BansHero();
		NeededTime = 0 
	elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and GetCMPhaseTimeRemaining() <= NeededTime then
		PicksHero();	
		NeededTime = 0
	elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		SelectsHero();	
	end	
end
--Pick the captain
function PickCaptain()
	if not IsHumanPlayerExist() or DotaTime() > -1 then
		if GetCMCaptain() == -1 then
			local CaptBot = GetFirstBot();
			if CaptBot ~= nil then
				print("CAPTAIN PID : "..CaptBot)
				SetCMCaptain(CaptBot)
			end
		end
	end
end
--Check if human player exist in team
function IsHumanPlayerExist()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if not IsPlayerBot(id) then
			return true;
        end
    end
	return false;
end
--Get the first bot to be the captain
function GetFirstBot()
	local BotId = nil;
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) do
        if IsPlayerBot(id) then
			BotId = id;
			return BotId;
        end
    end
	return BotId;
end
--Ban hero function
function BansHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end	
	local BannedHero = RandomHero();
	if BanCycle == 1 then
		while not role.CanBeOfflaner(BannedHero) do
			BannedHero = RandomHero();
		end
	elseif	BanCycle == 2 then
		while not role.CanBeSupport(BannedHero) do
			BannedHero = RandomHero();
		end
	elseif	BanCycle == 3 then
		while not role.CanBeMidlaner(BannedHero) do
			BannedHero = RandomHero();
		end
	elseif	BanCycle == 4 then
		while not role.CanBeSupport(BannedHero) do
			BannedHero = RandomHero();
		end
	elseif	BanCycle == 5 then
		while not role.CanBeSafeLaneCarry(BannedHero) do
			BannedHero = RandomHero();
		end	
	end
	print(BannedHero.." is banned")
	CMBanHero(BannedHero);
	BanCycle = BanCycle + 1;
end
--Pick hero function
function PicksHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then
		return
	end	
	local PickedHero = RandomHero();
	if PickCycle == 1 then
		while not role.CanBeOfflaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "offlaner";
	elseif	PickCycle == 2 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 3 then
		while not role.CanBeMidlaner(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "midlaner";
	elseif	PickCycle == 4 then
		while not role.CanBeSupport(PickedHero) do
			PickedHero = RandomHero();
		end
		PairsHeroNameNRole[PickedHero] = "support";
	elseif	PickCycle == 5 then
		while not role.CanBeSafeLaneCarry(PickedHero) do
			PickedHero = RandomHero();
		end	
		PairsHeroNameNRole[PickedHero] = "carry";
	end
	print(PickedHero.." is picked")
	CMPickHero(PickedHero);
	PickCycle = PickCycle + 1;
end
--Add to list human picked heroes
function AddToList()
	if not IsPlayerBot(GetCMCaptain()) then
		for _,h in pairs(allBotHeroes)
		do
			if IsCMPickedHero(GetTeam(), h) and not alreadyInTable(h) then
				table.insert(humanPick, h)
			end
		end
	end
end
--Check if selected hero already picked by human
function alreadyInTable(hero_name)
	for _,h in pairs(humanPick)
	do
		if hero_name == h then
			return true
		end
	end
	return false
end
--Check if the randomed hero doesn't available for captain's mode
function IsUnavailableHero(name)
	for _,uh in pairs(UnavailableHeroes)
	do
		if name == uh then
			return true;
		end	
	end
	return false;
end
--Check if a hero hasn't implemented yet
function IsUnImplementedHeroes()
	for _,unh in pairs(UnImplementedHeroes)
	do
		if name == unh then
			return true;
		end	
	end
	return false;
end
--Random hero which is non picked, non banned, or non human picked heroes if the human is the captain 
function RandomHero()
	local hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
	while ( IsUnavailableHero(hero) or IsCMPickedHero(GetTeam(), hero) or IsCMPickedHero(GetOpposingTeam(), hero) or IsCMBannedHero(hero) ) 
	do
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end
	return hero;
end
--Check if the human already pick the hero in captain's mode
function WasHumansDonePicking()
	local Players = GetTeamPlayers(GetTeam())
    for _,id in pairs(Players) 
	do
        if not IsPlayerBot(id) then
			if GetSelectedHeroName(id) == nil or GetSelectedHeroName(id) == "" then
				return false;
			end	
        end
    end
	return true;
end
--Select the rest of the heroes that the human players don't pick in captain's mode
function SelectsHero()
	if not AllHeroesSelected and ( WasHumansDonePicking() or GetCMPhaseTimeRemaining() < 1 ) then
		local Players = GetTeamPlayers(GetTeam())
		local RestBotPlayers = {};
		GetTeamSelectedHeroes();
		
		for _,id in pairs(Players) 
		do
			local hero_name =  GetSelectedHeroName(id);
			if hero_name ~= nil and hero_name ~= "" then
				UpdateSelectedHeroes(hero_name)
				print(hero_name.." Removed")
			else
				table.insert(RestBotPlayers, id)
			end	
		end
		
		for i = 1, #RestBotPlayers
		do
			SelectHero(RestBotPlayers[i], ListPickedHeroes[i])
		end
		
		AllHeroesSelected = true;
	end
end
--Get the team picked heroes
function GetTeamSelectedHeroes()
	for _,sName in pairs(allBotHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end
	end
	for _,sName in pairs(UnImplementedHeroes)
	do
		if IsCMPickedHero(GetTeam(), sName) then
			table.insert(ListPickedHeroes, sName);
		end	
	end
end
--Update team picked heroes after human players select their desired hero
function UpdateSelectedHeroes(selected)
	for i=1, #ListPickedHeroes
	do
		if ListPickedHeroes[i] == selected then
			table.remove(ListPickedHeroes, i);
		end
	end
end
-------------------------------------------------------------------------------------------------------


------------------------------------------ALL RANDOM GAME MODE-------------------------------------------
--Picking logic for All Random Game Mode
function AllRandomLogic()
	for i,id in pairs(GetTeamPlayers(GetTeam())) 
	 do 
		if  GetHeroPickState() == HEROPICK_STATE_AR_SELECT and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == ""
		then 
			hero = GetRandomHero(); 
			SelectHero(id, hero); 
			return;
		end
	end
end
-------------------------------------------------------------------------------------------------------------


------------------------------------------MID ONLY SAME HERO GAME MODE-----------------------------------------------
--Picking logic for Mid Only Same Hero Game Mode
local RandomedHero = nil;
function MidOnlyLogic()
	if IsHumanPresentInGame() then
		if GameTime() > 45 then
			PickMidOnlyRandomHero()
		elseif GameTime() > 30 and  GameTime() <= 45 and IsHumansDonePicking() then
			if IsHumanPlayerExist() then
				local selectedHero = GetSelectedHumanHero(GetTeam())
				if selectedHero ~= "" and  selectedHero ~= nil then
					for i,id in pairs(GetTeamPlayers(GetTeam())) 
					 do 
						if  GetHeroPickState() == HEROPICK_STATE_AP_SELECT and IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == ""
						then 
							SelectHero(id, selectedHero); 
							return;
						end
					end 
				end 
			else
				local selectedHero = GetSelectedHumanHero(GetOpposingTeam())
				if selectedHero ~= "" and  selectedHero ~= nil then
					for i,id in pairs(GetTeamPlayers(GetTeam())) 
					do 
						if  GetHeroPickState() == HEROPICK_STATE_AP_SELECT and IsPlayerBot(id) and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == ""
						then 
							SelectHero(id, selectedHero); 
							return;
						end
					end 
				end 
			end 
		end 
	else
		PickMidOnlyRandomHero()
	end	
end

function PickMidOnlyRandomHero()
	if GetTeam() ==	TEAM_DIRE then
		if not IsOpposingTeamDonePicking() then
			return
		else
			local selectedHero = GetOpposingTeamSelectedHero()
			for i,id in pairs(GetTeamPlayers(GetTeam())) 
			do 
				if  GetHeroPickState() == HEROPICK_STATE_AP_SELECT and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == ""
				then 
					SelectHero(id, selectedHero); 
					return;
				end
			end 
		end
	else
		local selectedHero = SetRandomHero();
		for i,id in pairs(GetTeamPlayers(GetTeam())) 
		do 
			if  GetHeroPickState() == HEROPICK_STATE_AP_SELECT and IsPlayerInHeroSelectionControl(id) and GetSelectedHeroName(id) == ""
			then 
				SelectHero(id, selectedHero); 
				return;
			end
		end 
	end
end

--Get Human Selected Hero
function GetSelectedHumanHero(team)
	for i,id in pairs(GetTeamPlayers(team)) 
	do 
		if not IsPlayerBot(id) and GetSelectedHeroName(id) ~= ""
		then 
			return  GetSelectedHeroName(id);
		end
	end 
end
--Check if human present in the game 
function IsHumanPresentInGame()
	for i,id in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if not IsPlayerBot(id) 
		then 
			return true;
		end
	end 
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if not IsPlayerBot(id) 
		then 
			return true;
		end
	end 
	return false;
end
--Get opposing team selected hero
function GetOpposingTeamSelectedHero()
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(id) ~= ""
		then 
			return GetSelectedHeroName(id);
		end
	end
end
--Set hero that will be use in mid only same hero game
function SetRandomHero()
	if RandomedHero == nil then
		RandomedHero = GetRandomHero();
	else
		return RandomedHero;
	end
end
--Check if the opposing team done picking 
function IsOpposingTeamDonePicking()
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(id) == ""
		then 
			return false;
		end
	end
	return true;
end
---------------------------------------------------------------------------------------------------------------


----------------------------------------------------HERO SELECTION UTILITY FUNCTION------------------------------
--Pick hero based on role
function PickRightHero(slot)
	local initHero = GetRandomHero();
	local Team = GetTeam();
	if slot == 0 then
		while not role.CanBeMidlaner(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 1 then
		while ( Team == TEAM_RADIANT and not role.CanBeOfflaner(initHero) ) or 
			  ( Team == TEAM_DIRE and not role.CanBeSafeLaneCarry(initHero) ) 
		do
			initHero = GetRandomHero();
		end
	elseif slot == 2 then
		while not role.CanBeSupport(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 3 then
		while not role.CanBeSupport(initHero) do
			initHero = GetRandomHero();
		end
	elseif slot == 4 then
		while ( Team == TEAM_RADIANT and not role.CanBeSafeLaneCarry(initHero) ) or 
			  ( Team == TEAM_DIRE and not role.CanBeOfflaner(initHero) )
		do
			initHero = GetRandomHero();
		end
	end
	return initHero;
end
--Check if human done picking
function IsHumansDonePicking() 
	-- check radiant 
	for _,i in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i) then 
			return false; 
		end 
	end 
	-- check dire 
	for _,i in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i) then 
			return false; 
		end 
	end 
	-- else humans have picked 
	return true; 
end
--Pick hero function
function PickHero(slot)
  local hero = GetRandomHero();
  SelectHero(slot, hero);
end
-- haven't found a better way to get already-picked heroes than just looping over all the players
function GetPicks()
	local selectedHeroes = {};
    local pickedSlots = {};
	for _,i in pairs(GetTeamPlayers(GetTeam())) 
	do 
		if GetSelectedHeroName(i) ~= "" then 
			selectedHeroes[i] =  GetSelectedHeroName(i);
		end 
	end 
	-- check dire 
	for _,i in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do 
		if GetSelectedHeroName(i) ~= "" then 
			selectedHeroes[i] =  GetSelectedHeroName(i);
		end 
	end 
    return selectedHeroes;
end
-- first, check the list of required heroes and pick from those
-- then try the whole bot pool
function GetRandomHero()
    local hero;
    local picks = GetPicks();
    local selectedHeroes = {};
	
    for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
    end

	if testMode then
		hero = requiredHeroes[RandomInt(1, #requiredHeroes)];
	else
		hero = nil;
	end
	
	if (hero == nil) then
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end

    while ( selectedHeroes[hero] == true ) do
        hero = allBotHeroes[RandomInt(1, #allBotHeroes)];
    end

    return hero;
end

local chatLanes = {};
---------------------------------------------------------LANE ASSIGMENT WITH CHAT FEATURE-----------------------------------------------
function SelectLaneChatCallback(PlayerID, ChatText, bTeamOnly)
	if GetTeamForPlayer(PlayerID) == GetTeam() then
		chatLanes = {};
		local count = 1;
		for str in string.gmatch(ChatText, "%S+") do
			if str == "top" then
				chatLanes[count] = LANE_TOP;	
			elseif str == "mid" then
				chatLanes[count] = LANE_MID;
			elseif str == "bot" then
				chatLanes[count] = LANE_BOT;
			end
			count = count + 1;
		end
		if #chatLanes ~= 5 then 
			print("Wrong Command! Lane count is less or more than 5. Typo? Please type 5 lane (top, mid, or bot) with space separating each other.")
		end
	else
		print("You're not my team...!")
	end
end

---------------------------------------------------------LANE ASSIGNMENT-----------------------------------------------------------------
function UpdateLaneAssignments()    
	if GetGameMode() == GAMEMODE_AP or GetGameMode() == GAMEMODE_TM or GetGameMode() == GAMEMODE_SD then
		--print("AP Lane Assignment")
		if GetGameState() == GAME_STATE_STRATEGY_TIME or GetGameState() == GAME_STATE_PRE_GAME then
			InstallChatCallback(function (attr) SelectLaneChatCallback(attr.player_id, attr.string, attr.team_only); end);
		end
		if #chatLanes == 5 then
			return chatLanes;
		else
			return APLaneAssignment();
		end	
	elseif GetGameMode() == GAMEMODE_CM then
		--print("CM Lane Assignment")
		return CMLaneAssignment()	
	elseif GetGameMode() == GAMEMODE_AR then
		return APLaneAssignment()	
	elseif GetGameMode() == GAMEMODE_MO then
		return MOLaneAssignment()	
	elseif GetGameMode() == GAMEMODE_1V1MID then
		return OneVsOneLaneAssignment()			
	end
   
end
---------------------------------------------------------ALL PICK LANE ASSIGNMENT------------------------------------------------------------
function APLaneAssignment()

	 local lanecount = {
        [LANE_NONE] = 5,
        [LANE_MID] = 1,
        [LANE_TOP] = 2,
        [LANE_BOT] = 2,
    };

    local lanes = {
        [1] = LANE_MID,
        [2] = LANE_TOP,
        [3] = LANE_TOP,
        [4] = LANE_BOT,
        [5] = LANE_BOT,
        };

    local playercount = 0

    if ( GetTeam() == TEAM_RADIANT )
    then 
        local ids = GetTeamPlayers(TEAM_RADIANT)
        for i,v in pairs(ids) do
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end
        for i=1,playercount do
            local lane = GetLane( TEAM_RADIANT,GetTeamMember( i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end
	
        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
		--print("RAD")
		--utils.print_r(lanes)
        return lanes
    elseif ( GetTeam() == TEAM_DIRE )
    then
        local ids = GetTeamPlayers(TEAM_DIRE)
        for i,v in pairs(ids) do
            --print(tostring(IsPlayerBot(v)))
            if not IsPlayerBot(v) then
                playercount = playercount + 1
            end
        end
        for i=1,playercount do
            local lane = GetLane( TEAM_DIRE, GetTeamMember( i ) )
            lanecount[lane] = lanecount[lane] - 1
            lanes[i] = lane 
        end

        for i=(playercount + 1), 5 do
            if lanecount[LANE_MID] > 0 then
                lanes[i] = LANE_MID
                lanecount[LANE_MID] = lanecount[LANE_MID] - 1
            elseif lanecount[LANE_TOP] > 0 then
                lanes[i] = LANE_TOP
                lanecount[LANE_TOP] = lanecount[LANE_TOP] - 1
            else
                lanes[i] = LANE_BOT
            end
        end
		--print("DIRE")
        --utils.print_r(lanes)
        return lanes
    end

end

function GetLane( nTeam ,hHero )
        local vBot = GetLaneFrontLocation(nTeam, LANE_BOT, 0)
        local vTop = GetLaneFrontLocation(nTeam, LANE_TOP, 0)
        local vMid = GetLaneFrontLocation(nTeam, LANE_MID, 0)
        --print(GetUnitToLocationDistance(hHero, vMid))
        if GetUnitToLocationDistance(hHero, vBot) < 2500 then
            return LANE_BOT
        end
        if GetUnitToLocationDistance(hHero, vTop) < 2500 then
            return LANE_TOP
        end
        if GetUnitToLocationDistance(hHero, vMid) < 2500 then
            return LANE_MID
        end
        return LANE_NONE
end
-------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------CAPTAIN'S MODE LANE ASSIGNMENT------------------------------------------------
function CMLaneAssignment()
	if IsPlayerBot(GetCMCaptain()) then
		FillLaneAssignmentTable();
	else
		FillLAHumanCaptain()
	end
	return HeroLanes;
end
--Lane Assignment if the captain is not human
function FillLaneAssignmentTable()
	local supportAlreadyAssigned = false;
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name =  GetTeamMember(i):GetUnitName(); 
			if PairsHeroNameNRole[unit_name] == "support" and not supportAlreadyAssigned then
				HeroLanes[i] = LANE_TOP;
				supportAlreadyAssigned = true;
			elseif PairsHeroNameNRole[unit_name] == "support" and supportAlreadyAssigned then
				HeroLanes[i] = LANE_BOT;
			elseif PairsHeroNameNRole[unit_name] == "midlaner" then
				HeroLanes[i] = LANE_MID;
			elseif PairsHeroNameNRole[unit_name] == "offlaner" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_TOP;
				else
					HeroLanes[i] = LANE_BOT;
				end
			elseif PairsHeroNameNRole[unit_name] == "carry" then
				if GetTeam() == TEAM_RADIANT then
					HeroLanes[i] = LANE_BOT;
				else
					HeroLanes[i] = LANE_TOP;
				end	
			end
		end
	end	
end
--Fill the lane assignment if the captain is human
function FillLAHumanCaptain()
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		if GetTeamMember(i) ~= nil and GetTeamMember(i):IsHero() then
			local unit_name =  GetTeamMember(i):GetUnitName(); 
			local key = GetFromHumanPick(unit_name);
			if key ~= nil then
				if key == 1 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_BOT;
					else
						HeroLanes[i] = LANE_TOP;
					end
				elseif key == 2 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_BOT;
					else
						HeroLanes[i] = LANE_TOP;
					end	
				elseif key == 3 then
					HeroLanes[i] = LANE_MID;
				elseif key == 4 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_TOP;
					else
						HeroLanes[i] = LANE_BOT;
					end
				elseif key == 5 then
					if GetTeam() == TEAM_DIRE then
						HeroLanes[i] = LANE_TOP;
					else
						HeroLanes[i] = LANE_BOT;
					end	
				end
			end
		end
	end	
end
--Get human picked heroes if the captain is human player
function GetFromHumanPick(hero_name)
	local i = nil;
	for key,h in pairs(humanPick)
	do
		if hero_name == h then
			i = key;
		end	
	end
	return i;
end
---------------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------MID ONLY LANE ASSIGNMENT------------------------------------------------------
function MOLaneAssignment()
	local lanes = {
        [1] = LANE_MID,
        [2] = LANE_MID,
        [3] = LANE_MID,
        [4] = LANE_MID,
        [5] = LANE_MID,
        };
	return lanes;	
end
---------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------1 VS 1 LANE ASSIGNMENT------------------------------------------------------
function OneVsOneLaneAssignment()
	local lanes = {
        [1] = LANE_MID,
        [2] = LANE_TOP,
        [3] = LANE_TOP,
        [4] = LANE_TOP,
        [5] = LANE_TOP,
        };
	return lanes;	
end
---------------------------------------------------------------------------------------------------------------------------------------