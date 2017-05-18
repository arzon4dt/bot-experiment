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
	"item_sange_and_yasha",
	"item_dragon_lance",
	"item_maelstrom",
	"item_hurricane_pike",
	"item_mjollnir",
	"item_heart",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,3,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X