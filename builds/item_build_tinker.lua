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
	"item_kaya",
	"item_dagon_5",
	"item_sheepstick"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,1,2,1,2,1,2,4,3,3,4,3,3,4}, skills, 
	  {1,4,6,8}, talents
);

return X