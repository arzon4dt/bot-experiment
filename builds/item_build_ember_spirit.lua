X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_veil_of_discord",
	"item_maelstrom",
	"item_shivas_guard",
	"item_greater_crit",
	"item_mjollnir",
	"item_octarine_core"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,1,3,4,3,1,1,2,4,2,2,2,4}, skills, 
	  {1,4,5,7}, talents
);

return X