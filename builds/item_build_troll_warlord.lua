X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(2));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_ring_of_aquila",
	"item_sange_and_yasha",
	"item_black_king_bar",
	"item_eye_of_skadi",
	"item_butterfly",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,3,2,2,4,2,3,1,3,4,3,1,1,4}, skills, 
	  {2,4,6,8}, talents
);

return X