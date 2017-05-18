X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_blade_mail",
	"item_pipe",
	"item_guardian_greaves",
	"item_lotus_orb",
	"item_ultimate_scepter"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,3,1,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {2,3,5,8}, talents
);

return X