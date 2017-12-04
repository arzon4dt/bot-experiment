X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_medallion_of_courage",
	"item_blink",
	"item_solar_crest",
	"item_aeon_disk",
	"item_lotus_orb",
	"item_shivas_guard"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,3,3,3,4,3,2,2,2,4,1,1,1,4}, skills, 
	  {1,4,6,7}, talents
);

return X