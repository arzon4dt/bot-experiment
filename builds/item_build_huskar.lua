X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_dragon_lance",
	"item_lifesteal",
	"item_black_king_bar",
	"item_heavens_halberd",
	"item_hurricane_pike",
	"item_ultimate_scepter_2",
	"item_assault",
	"item_satanic"
};			

X["builds"] = {
	{2,3,2,1,2,4,2,3,3,3,4,1,1,1,4},
	{2,3,3,1,3,4,3,1,1,1,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,8}, talents
);

return X