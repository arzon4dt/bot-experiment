X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_force_staff",
	"item_glimmer_cape",
	"item_cyclone",
	"item_ultimate_scepter",
	"item_hurricane_pike",
	"item_sheepstick",
	"item_ultimate_scepter_2",
	"item_octarine_core",
};			

X["builds"] = {
	{1,3,1,3,3,4,3,2,2,2,4,2,1,1,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{3,1,3,2,3,4,3,2,2,2,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);

return X