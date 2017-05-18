X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_str",
	"item_vanguard",
	"item_blade_mail",
	"item_solar_crest",
	"item_crimson_guard",
	"item_shivas_guard",
	"item_octarine_core"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,2,1,2,4,2,3,3,3,4,1,1,1,4}, skills, 
	  {1,4,6,7}, talents
);

return X