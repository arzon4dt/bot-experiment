X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_str",
	"item_sange_and_yasha",
	"item_desolator",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_assault"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,1,3,1,4,1,3,3,2,4,2,2,2,4}, skills, 
	  {1,4,5,7}, talents
);

return X