X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_ultimate_scepter",
	"item_force_staff",
	"item_cyclone",
	"item_rod_of_atos",
	"item_sheepstick",
	"item_hurricane_pike"
};	

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,2,1,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,4,5,8}, talents
);

return X