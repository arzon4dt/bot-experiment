X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_ring_of_basilius",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_dragon_lance",
	"item_orchid",
	"item_black_king_bar",
	"item_desolator",
	"item_bloodthorn",
	"item_monkey_king_bar",
	"item_hurricane_pike"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,2,1,2,4,2,3,3,3,4,1,1,1,4}, skills, 
	  {2,4,6,8}, talents
);

return X