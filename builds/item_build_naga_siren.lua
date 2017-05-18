X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_ring_of_aquila",
	"item_diffusal_blade_1",
	"item_manta",
	"item_butterfly",
	"item_heart",
	"item_radiance"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,3,2,3,4,3,2,2,1,4,1,1,1,4}, skills, 
	  {1,3,5,7}, talents
);

return X