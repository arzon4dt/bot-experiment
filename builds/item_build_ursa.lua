X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_vladmir",
	"item_blink",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_ultimate_scepter",
	"item_heart"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,3,2,2,4,3,2,3,2,4,1,1,1,4}, skills, 
	  {2,3,5,8}, talents
);

return X