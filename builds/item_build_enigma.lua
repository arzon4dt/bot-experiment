X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_blink",
	"item_black_king_bar",
	"item_guardian_greaves",
	"item_ultimate_scepter",
	"item_sheepstick",
	"item_ultimate_scepter_2",
	"item_octarine_core"
};			

X["builds"] = {
	{2,1,2,1,2,4,2,1,1,3,4,3,3,3,4},
	{2,1,2,3,2,4,2,3,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,6,8}, talents
);

return X