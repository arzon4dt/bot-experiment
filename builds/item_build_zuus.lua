X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_veil_of_discord",
	"item_cyclone",
	"item_aether_lens",
	"item_ultimate_scepter",
	"item_octarine_core"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,2,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X