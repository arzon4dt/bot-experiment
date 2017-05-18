X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_force_staff",
	"item_orchid",
	"item_ultimate_scepter",
	"item_linken_sphere",
	"item_bloodthorn",
	"item_hurricane_pike",
	"item_monkey_king_bar"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,2,1,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {2,4,5,8}, talents
);

return X