X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_pipe",
	"item_blade_mail",
	"item_force_staff",
	"item_cyclone",
	"item_shivas_guard"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,2,1,4,2,1,2,3,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X;