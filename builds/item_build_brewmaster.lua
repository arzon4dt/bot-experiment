X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_arcane_boots",
	"item_blink",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_linken_sphere",
	"item_heart"
}; 

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {2,3,6,7}, talents
);

return X