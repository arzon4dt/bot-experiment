X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_armlet",
	"item_sange_and_yasha",
	--"item_echo_sabre",
	"item_desolator",
	"item_abyssal_blade",
	"item_assault"
};			

X["builds"] = {
	{2,3,1,1,1,4,1,3,3,3,4,2,2,2,4},
	{2,3,2,1,1,4,1,1,3,3,4,3,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,4,5,7}, talents
);

return X