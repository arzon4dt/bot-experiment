X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_diffusal_blade_1",
	"item_sange_and_yasha",
	"item_abyssal_blade",
	"item_eye_of_skadi",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,2,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {1,4,6,8}, talents
);

return X