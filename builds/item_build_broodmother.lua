X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_ring_of_basilius",
	"item_magic_wand",
	"item_phase_boots",
	"item_vladmir",
	"item_orchid",
	"item_black_king_bar",
	"item_assault",
	"item_bloodthorn",
	"item_butterfly"
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,1,1,2,1,4,1,2,2,3,4,3,3,3,4}, skills, 
	  {2,3,6,8}, talents
);

return X