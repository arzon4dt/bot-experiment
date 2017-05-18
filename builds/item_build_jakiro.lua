X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_force_staff",
	"item_guardian_greaves",
	"item_glimmer_cape",
	"item_ultimate_scepter",
	"item_hurricane_pike",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,3,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X