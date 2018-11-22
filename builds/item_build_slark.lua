X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_echo_sabre",
	"item_invis_sword",
	"item_abyssal_blade",
	"item_silver_edge",
	"item_skadi",
	"item_butterfly"
};			

X["builds"] = {
	{2,3,1,1,1,4,1,2,2,2,4,3,3,3,4},
	{2,3,1,1,2,4,1,2,1,2,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,8}, talents
);

return X