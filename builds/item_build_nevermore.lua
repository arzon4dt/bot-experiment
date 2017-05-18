X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(7));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_shadow_blade",
	"item_dragon_lance",
	"item_black_king_bar",
	"item_silver_edge",
	"item_butterfly",
	"item_hurricane_pike",
	"item_eye_of_skadi"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,2,1,1,2,2,4,3,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X