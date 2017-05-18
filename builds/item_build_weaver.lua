X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_dragon_lance",
	"item_desolator",
	"item_black_king_bar",
	"item_greater_crit",
	"item_butterfly",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,2,1,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {1,4,6,7}, talents
);

return X