X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_arcane_boots",
	"item_pipe",
	"item_aeon_disk",
	"item_lotus_orb",
	"item_radiance",
	"item_shivas_guard"
}	

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,3,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {2,4,5,7}, talents
);

return X;