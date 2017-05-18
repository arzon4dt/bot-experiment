X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_desolator",
	"item_blink",
	"item_black_king_bar",
	"item_bloodthorn",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,1,1,4,1,2,2,2,4,2,3,3,4}, skills, 
	  {1,3,6,7}, talents
);

return X