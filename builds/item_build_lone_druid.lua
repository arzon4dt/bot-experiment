X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_phase_boots",
	"item_ring_of_aquila",
	"item_maelstrom",
	"item_hurricane_pike",
	"item_mjollnir",
	"item_eye_of_skadi",
	"item_butterfly",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,2,1,2,1,2,3,3,3,3,4,4,4}, skills, 
	  {2,3,6,8}, talents
);

return X