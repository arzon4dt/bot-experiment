X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_shadow_blade",
	"item_orchid",
	"item_maelstrom",
	"item_bloodthorn",
	"item_mjollnir",
	"item_silver_edge",
	"item_sheepstick",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,2,3,4,2,2,2,3,4,1,1,1,4}, skills, 
	  {1,3,5,7}, talents
);

return X