X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_blink",
	"item_aether_lens",
	"item_cyclone",
	"item_ultimate_scepter",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,3,1,4,1,3,3,3,4,2,2,2,4}, skills, 
	  {1,3,5,7}, talents
);

return X