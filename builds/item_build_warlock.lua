X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_ultimate_scepter",
	"item_guardian_greaves",
	"item_shivas_guard",
	"item_refresher",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,2,1,2,4,2,1,1,3,4,3,3,3,4}, skills, 
	  {1,3,6,8}, talents
);


return X