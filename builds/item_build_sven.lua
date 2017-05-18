X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_str",
	"item_echo_sabre",
	"item_blink",
	"item_black_king_bar",
	"item_assault",
	"item_greater_crit"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,2,2,4,2,2,3,3,4,3,1,1,4}, skills, 
	  {2,3,5,7}, talents
);

return X