X = {};

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_medallion_of_courage",
	"item_rod_of_atos",
	"item_solar_crest",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,2,2,2,4,2,3,3,3,4,1,1,1,4}, skills, 
	  {2,4,5,8}, talents
);

return X