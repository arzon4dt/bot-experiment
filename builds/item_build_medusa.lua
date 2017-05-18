X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_ring_of_aquila",
	"item_phase_boots",
	"item_yasha",
	"item_dragon_lance",
	"item_maelstrom",
	"item_manta",
	"item_mjollnir",
	"item_eye_of_skadi",
	"item_butterfly",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,2,3,2,4,2,3,3,1,4,1,1,1,4}, skills, 
	  {1,4,6,7}, talents
);

return X