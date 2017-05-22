X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(3));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_ultimate_scepter",
	"item_force_staff",
	"item_glimmer_cape",
	"item_cyclone",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,1,1,4,3,1,3,2,4,2,2,2,4}, skills, 
	  {2,3,6,8}, talents
);

return X