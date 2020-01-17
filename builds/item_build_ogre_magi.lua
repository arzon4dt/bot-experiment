X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_hand_of_midas",
	"item_aether_lens",
	"item_glimmer_cape",
	"item_force_staff",
	"item_cyclone",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_sheepstick"
};			

X["builds"] = {
	{2,1,2,3,2,4,2,3,3,3,4,1,1,1,4},
	{2,1,2,1,2,4,2,1,1,3,4,3,3,3,4},
	{2,1,2,3,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X