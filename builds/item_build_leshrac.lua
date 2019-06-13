X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_bloodstone",
	"item_cyclone",
	"item_black_king_bar",
	"item_octarine_core",
	"item_ultimate_scepter_2",
	"item_shivas_guard"
};			

X["builds"] = {
	{3,1,3,1,3,4,3,1,1,2,4,2,2,2,4},
	{1,3,3,1,3,4,3,1,1,2,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,8}, talents
);

return X