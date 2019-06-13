X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_echo_sabre",
	"item_invis_sword",
	"item_sange_and_yasha",
	"item_black_king_bar",
	"item_silver_edge",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{3,1,3,2,3,1,3,1,4,1,4,2,2,2,4},
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4},
	{3,1,2,1,1,4,1,3,3,3,4,2,2,2,4},
	{3,1,2,1,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X