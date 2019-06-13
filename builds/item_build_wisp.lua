X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_urn_of_shadows",
	"item_arcane_boots",
	"item_mekansm",
	"item_holy_locket",
	"item_spirit_vessel",
	"item_glimmer_cape",
	"item_guardian_greaves",
	"item_ultimate_scepter_2",
	"item_lotus_orb"
};			

X["builds"] = {
	{1,2,2,3,2,4,2,3,3,3,4,1,1,1,4},
	{1,2,2,3,3,4,2,3,2,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,7}, talents
);

return X