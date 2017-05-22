X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_shadow_blade",
	"item_greater_crit",
	"item_blink",
	"item_silver_edge",
	"item_black_king_bar",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,3,3,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {1,3,6,8}, talents
);

return X