X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_urn_of_shadows",
	"item_pipe",
	"item_blink",
	"item_cyclone",
	"item_lotus_orb",
	"item_heart"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,2,1,4,1,2,2,3,4,3,3,3,4}, skills, 
	  {1,3,6,8}, talents
);

return X