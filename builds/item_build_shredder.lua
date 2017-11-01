X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(3));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_arcane_boots",
	"item_bloodstone",
	"item_combo_breaker",
	"item_lotus_orb",
	"item_shivas_guard",
	"item_octarine_core"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,2,2,3,4,2,2,3,3,4,1,1,1,4}, skills, 
	  {2,3,6,8}, talents
);

return X