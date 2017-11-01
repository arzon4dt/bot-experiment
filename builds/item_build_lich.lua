X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_force_staff",
	"item_glimmer_cape",
	"item_ultimate_scepter",
	"item_cyclone",
	"item_hurricane_pike",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,1,2,4,1,3,1,3,4,2,2,2,4}, skills, 
	  {1,3,5,8}, talents
);

return X