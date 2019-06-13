X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_invis_sword",
	"item_orchid",
	"item_maelstrom",
	"item_bloodthorn",
	"item_black_king_bar",
	"item_mjollnir",
	"item_silver_edge",
	"item_ultimate_scepter_2",
	"item_sheepstick"
};			

X["builds"] = {
	{3,2,3,1,3,4,3,2,2,2,4,1,1,1,4},
	{3,2,1,3,3,4,3,2,2,2,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X