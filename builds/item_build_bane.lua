X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_aether_lens",
	"item_force_staff",
	"item_glimmer_cape",
	"item_necronomicon_3",
	"item_sheepstick"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,1,2,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {2,4,5,8}, talents
);

return X