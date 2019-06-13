X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_vanguard",
	"item_maelstrom",
	"item_abyssal_blade",
	"item_yasha_and_kaya",
	"item_mjollnir",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{1,2,1,2,1,4,1,2,2,3,4,3,3,3,4},
	{1,3,1,2,1,4,1,2,2,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,5,8}, talents
);

return X