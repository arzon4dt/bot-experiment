X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_medallion_of_courage",
	"item_desolator",
	"item_solar_crest",
	"item_orchid",
	"item_bloodthorn",
	"item_black_king_bar",
	"item_dagon_5"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,1,1,1,4,1,3,2,2,4,2,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X