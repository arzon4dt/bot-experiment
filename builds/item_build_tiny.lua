X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_blink",
	"item_echo_sabre",
	"item_ultimate_scepter",
	"item_assault",
	"item_butterfly"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,2,1,2,4,2,1,1,3,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X