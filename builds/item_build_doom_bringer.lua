X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_blade_mail",
	"item_invis_sword",
	"item_shivas_guard",
	"item_black_king_bar",
	"item_ultimate_scepter",
	"item_silver_edge"
};	

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,2,1,4,2,1,2,1,4,3,3,3,4}, skills, 
	  {2,4,6,7}, talents
);

return X