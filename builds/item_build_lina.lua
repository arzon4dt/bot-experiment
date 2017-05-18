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
	"item_cyclone",
	"item_ultimate_scepter",
	"item_bloodthorn",
	"item_sheepstick",
	"item_silver_edge"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,1,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,3,5,7}, talents
);

return X