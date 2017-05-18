X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_power_treads_agi",
	"item_medallion_of_courage",
	"item_force_staff",
	"item_solar_crest",
	"item_aether_lens",
	"item_cyclone",
	"item_ultimate_scepter",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,2,1,4,1,3,2,2,4,3,3,3,4}, skills, 
	  {2,4,5,8}, talents
);

return X