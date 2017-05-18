X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = {
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_boots",
	"item_necronomicon_3",
	"item_blink",
	"item_travel_boots",
	"item_heavens_halberd",
	"item_ultimate_scepter",
	"item_assault"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,4,5,7}, talents
);

return X