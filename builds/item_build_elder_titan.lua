X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_pipe",
	"item_blade_mail",
	"item_yasha_and_kaya",
	"item_cyclone",
	"item_ultimate_scepter_2",
	"item_shivas_guard"
};			

X["builds"] = {
	{2,1,2,1,1,4,1,3,3,3,4,3,2,2,4},
	{1,2,1,3,1,4,1,3,3,3,4,2,2,2,4},
	{2,1,3,1,2,4,1,2,1,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X;