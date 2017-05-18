X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_arcane_boots",
	"item_cyclone",
	"item_force_staff",
	"item_glimmer_cape",
	"item_ultimate_scepter",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,2,1,3,4,1,2,1,2,4,3,3,3,4}, skills, 
	  {1,4,5,8}, talents
);

return X