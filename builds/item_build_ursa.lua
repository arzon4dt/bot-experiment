X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_vladmir",
	"item_sange_and_yasha",
	"item_blink",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_ultimate_scepter",
	"item_ultimate_scepter_2",
	"item_monkey_king_bar"
};			

X["builds"] = {
	{3,2,3,2,3,4,3,2,2,1,4,1,1,1,4},
	{3,1,3,2,1,4,3,1,3,1,4,2,2,2,4},
	{3,1,3,2,2,4,1,2,1,2,4,1,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,5,8}, talents
);

return X