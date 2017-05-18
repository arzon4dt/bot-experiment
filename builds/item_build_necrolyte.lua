X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_veil_of_discord",
	"item_ultimate_scepter",
	"item_guardian_greaves",
	"item_shivas_guard",
	"item_radiance"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,1,2,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,3,5,7}, talents
);

return X