X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_medallion_of_courage",
	"item_meteor_hammer",
	"item_holy_locket",
	"item_solar_crest",
	"item_lotus_orb",
	"item_ultimate_scepter_2",
	"item_blink"
};			

X["builds"] = {
	{1,2,1,3,3,4,3,3,2,2,4,2,1,1,4},
	{1,3,3,2,2,4,2,2,3,3,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X