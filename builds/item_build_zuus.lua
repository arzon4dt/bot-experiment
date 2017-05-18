X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_veil_of_discord",
	"item_force_staff",
	"item_aether_lens",
	"item_octarine_core",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,2,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X