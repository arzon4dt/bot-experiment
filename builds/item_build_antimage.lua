X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_power_treads_agi",
	"item_bfury",
	"item_manta",
	"item_abyssal_blade",
	"item_butterfly",
	"item_heart"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,3,2,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {2,4,6,7}, talents
);

return X