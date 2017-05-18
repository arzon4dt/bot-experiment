X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_force_staff",
	"item_glimmer_cape",
	"item_aether_lens",
	"item_cyclone",
	"item_ultimate_scepter"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,2,1,2,4,2,1,2,1,4,3,3,3,4}, skills, 
	  {1,3,6,7}, talents
);

return X