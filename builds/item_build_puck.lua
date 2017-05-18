X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_int",
	"item_veil_of_discord",
	"item_blink",
	"item_dagon_1",
	"item_cyclone",
	"item_sheepstick",
	"item_dagon_5"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,1,4,2,1,2,2,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X