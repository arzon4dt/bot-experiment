X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_phase_boots",
	"item_ring_of_aquila",
	"item_shadow_blade",
	"item_dragon_lance",
	"item_maelstrom",
	"item_hurricane_pike",
	"item_mjollnir",
	"item_greater_crit",
	"item_silver_edge",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,1,1,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {2,3,6,8}, talents
);

return X