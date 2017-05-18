X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_null_talisman",
	"item_soul_ring",
	"item_travel_boots",
	"item_blink",
	"item_aether_lens",
	"item_dagon_5",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,2,3,1,3,4,3,1,1,1,4,2,2,2,4}, skills, 
	  {1,4,6,8}, talents
);

return X