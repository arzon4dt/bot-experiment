X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(3));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_desolator",
	"item_sange_and_yasha",
	"item_silver_edge",
	"item_blink",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,2,1,4,1,2,2,3,4,3,3,3,4}, skills, 
	  {2,4,5,8}, talents
);

return X