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
	"item_invis_sword",
	"item_dragon_lance",
	"item_manta",
	"item_black_king_bar",
	"item_hurricane_pike",
	"item_silver_edge",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,1,2,3,4,3,3,1,1,4,2,2,2,4}, skills, 
	  {2,3,5,8}, talents
);

return X