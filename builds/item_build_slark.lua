X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_shadow_blade",
	"item_orchid",
	"item_abyssal_blade",
	"item_silver_edge",
	"item_eye_of_skadi",
	"item_bloodthorn",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,1,2,1,4,2,1,2,1,4,3,3,3,4}, skills, 
	  {1,3,5,8}, talents
);

return X