X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(3));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_arcane_boots",
	"item_blink",
	"item_cyclone",
	"item_ultimate_scepter",
	"item_aether_lens",
	"item_dagon_5"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,1,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {1,3,5,8}, talents
);

return X