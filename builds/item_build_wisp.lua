X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(8));

X["items"] = { 
	"item_magic_wand",
	"item_urn_of_shadows",
	"item_arcane_boots",
	"item_mekansm",
	"item_glimmer_cape",
	"item_guardian_greaves",
	"item_cyclone",
	"item_lotus_orb",
	"item_shivas_guard"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,2,2,4,2,3,3,3,4,1,1,1,4}, skills, 
	  {2,3,5,7}, talents
);

return X