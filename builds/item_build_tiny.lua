X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_ring_of_aquila",
	"item_sange_and_yasha",
	"item_black_king_bar",
	"item_assault",
	"item_silver_edge",
	"item_greater_crit"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  --{1,2,2,1,2,4,2,1,1,3,4,3,3,3,4}, skills, 
	  {1,2,3,3,3,4,3,2,2,2,4,1,1,1,4}, skills, 
	  {2,3,6,8}, talents
);

return X