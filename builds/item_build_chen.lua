X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_ultimate_scepter",
	"item_force_staff",
	"item_guardian_greaves",
	"item_glimmer_cape",
	"item_sheepstick",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_shivas_guard"
};	

X["builds"] = {
	{3,1,3,1,3,4,3,1,1,2,4,2,2,2,4},
	{2,1,2,1,2,4,2,1,1,3,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,7}, talents
);

return X