X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_ultimate_scepter",
	"item_glimmer_cape",
	"item_force_staff",
	"item_rod_of_atos",
	"item_sheepstick",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_octarine_core"
};	

X["builds"] = {
	{3,1,1,2,1,4,1,2,2,2,4,3,3,3,4},
	{1,3,3,2,3,4,1,3,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X