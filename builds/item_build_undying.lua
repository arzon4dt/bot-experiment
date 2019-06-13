X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_vanguard",
	"item_blade_mail",
	"item_pipe",
	"item_crimson_guard",
	"item_lotus_orb",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_shivas_guard"
};			

X["builds"] = {
	{1,3,3,2,3,4,3,2,2,2,4,1,1,1,4},
	{1,2,1,3,3,4,3,3,2,2,4,2,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,8}, talents
);

return X