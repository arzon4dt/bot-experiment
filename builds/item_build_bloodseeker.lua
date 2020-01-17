X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_sange_and_yasha",
	"item_blade_mail",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_butterfly"
};

X["builds"] = {
	{1,3,3,2,3,4,3,2,2,2,4,1,1,1,4},
	{1,3,3,2,2,4,3,2,3,2,4,1,1,1,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,6,8}, talents
);

return X