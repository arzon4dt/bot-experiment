X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_tranquil_boots",
	"item_blink",
	"item_force_staff",
	"item_silver_edge",
	"item_assault",
	"item_heart"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,2,3,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {1,3,5,7}, talents
);

return X