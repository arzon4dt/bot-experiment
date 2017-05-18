X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_tranquil_boots",
	"item_blink",
	"item_force_staff",
	"item_black_king_bar",
	"item_cyclone",
	"item_ultimate_scepter"
};

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,3,3,1,2,4,3,3,2,2,4,2,1,1,4}, skills, 
	  {1,3,5,7}, talents
);

return X