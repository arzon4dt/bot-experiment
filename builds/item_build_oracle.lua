X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_glimmer_cape",
	"item_lotus_orb",
	"item_force_staff",
	"item_aether_lens",
	"item_hurricane_pike",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,2,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {1,4,6,8}, talents
);

return X