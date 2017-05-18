X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_veil_of_discord",
	"item_cyclone",
	"item_rod_of_atos",
	"item_octarine_core",
	"item_shivas_guard"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {1,3,5,8}, talents
);

return X