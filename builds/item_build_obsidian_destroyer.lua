X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_int",
	"item_hurricane_pike",
	"item_kaya",
	"item_yasha_and_kaya",
	"item_black_king_bar",
	"item_shivas_guard",
	"item_ultimate_scepter_2",
	"item_sheepstick"
};			

X["builds"] = {
	{2,3,1,3,3,4,3,2,1,2,4,2,1,1,4},
	{2,3,1,3,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X