X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_ring_of_aquila",
	"item_invis_sword",
	"item_echo_sabre",
	"item_desolator",
	"item_black_king_bar",
	"item_silver_edge",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,3,1,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,4,5,8}, talents
);

return X