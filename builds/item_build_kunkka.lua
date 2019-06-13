X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_invis_sword",
	"item_greater_crit",
	"item_kaya_and_sange",
	"item_black_king_bar",
	"item_silver_edge",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{2,1,2,3,2,4,2,3,3,3,4,1,1,1,4},
	{2,1,2,3,1,4,2,1,2,1,4,3,3,3,4},
	{2,1,1,3,3,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,8}, talents
);

return X