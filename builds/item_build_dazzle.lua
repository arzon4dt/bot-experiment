X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_boots",
	"item_urn_of_shadows",
	"item_arcane_boots",
	"item_force_staff",
	"item_glimmer_cape",
	"item_necronomicon_3",
	"item_cyclone",
	"item_sheepstick"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,1,3,2,4,3,2,3,2,4,1,1,1,4}, skills, 
	  {1,4,6,7}, talents
);

return X