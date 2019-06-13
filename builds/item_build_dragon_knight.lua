X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_invis_sword",
	"item_black_king_bar",
	"item_sange_and_yasha",
	"item_assault",
	"item_ultimate_scepter_2",
	"item_heart",
	"item_silver_edge"
};	

X["builds"] = {
	{1,3,1,3,1,4,2,1,3,3,4,2,2,2,4},
	{3,2,3,1,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X