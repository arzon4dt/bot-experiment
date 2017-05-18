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
	"item_diffusal_blade_1",
	"item_manta",
	"item_ultimate_scepter",
	"item_eye_of_skadi",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,1,1,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {1,4,5,8}, talents
);

return X