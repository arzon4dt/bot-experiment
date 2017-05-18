X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_sange_and_yasha",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_butterfly",
	"item_monkey_king_bar"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,2,2,2,4,2,3,3,3,4,1,1,1,4}, skills, 
	  {1,3,6,8}, talents
);

return X