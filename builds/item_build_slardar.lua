X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_echo_sabre",
	"item_blink",
	"item_force_staff",
	"item_black_king_bar",
	"item_ultimate_scepter_2",
	"item_heart"
};			

X["builds"] = {
	{2,1,2,3,2,4,2,1,1,1,4,3,3,3,4},
	{2,1,2,3,1,4,2,1,2,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X