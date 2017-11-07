X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_str",
	"item_blade_mail",
	"item_invis_sword",
	"item_heavens_halberd",
	"item_silver_edge",
	"item_mjollnir",
	"item_ultimate_scepter"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,1,3,4,3,1,1,2,4,2,2,2,4}, skills, 
	  {1,4,6,8}, talents
);

return X