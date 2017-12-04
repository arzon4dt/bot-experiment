X = {}

local IBUtil  = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot  = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_arcane_boots",
	"item_mekansm",
	"item_blade_mail",
	"item_aeon_disk",
	"item_lotus_orb",
	"item_guardian_greaves",
	"item_shivas_guard"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,2,3,1,4,2,1,2,1,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X