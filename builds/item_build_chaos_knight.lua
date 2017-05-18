X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_str",
	"item_diffusal_blade_1",
	"item_manta",
	"item_heavens_halberd",
	"item_assault",
	"item_heart"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,3,2,4,1,2,1,2,4,3,3,3,4}, skills, 
	  {2,4,6,7}, talents
);

return X