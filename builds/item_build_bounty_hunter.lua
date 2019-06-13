X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_medallion_of_courage",
	"item_desolator",
	"item_solar_crest",
	"item_orchid",
	"item_bloodthorn",
	"item_black_king_bar",
	"item_ultimate_scepter_2",
	"item_dagon_5"
};

X["builds"] = {
	{3,2,1,1,1,4,1,3,3,3,4,2,2,2,4},
	{3,2,2,1,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X