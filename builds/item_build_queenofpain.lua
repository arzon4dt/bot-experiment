X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_int",
	"item_orchid",
	"item_ultimate_scepter",
	"item_linken_sphere",
	"item_bloodthorn",
	"item_shivas_guard",
	"item_octarine_core"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,3,3,4,3,3,2,2,4,2,1,1,4}, skills, 
	  {1,3,6,8}, talents
);

return X