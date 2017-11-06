X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(4));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_blink",
	"item_echo_sabre",
	"item_combo_breaker",
	"item_assault",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,2,1,2,4,2,1,1,3,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X