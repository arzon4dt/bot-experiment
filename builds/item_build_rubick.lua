X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(8));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_urn_of_shadows",
	"item_force_staff",
	"item_cyclone",
	"item_blink",
	"item_glimmer_cape",
	"item_ultimate_scepter"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,2,1,2,4,2,3,3,3,4,3,1,1,4}, skills, 
	  {1,4,6,7}, talents
);

return X