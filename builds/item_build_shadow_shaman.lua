X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_cyclone",
	"item_force_staff",
	"item_blink",
	"item_aether_lens",
	"item_ultimate_scepter"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {3,1,2,1,1,4,1,2,2,2,4,3,3,3,4}, skills, 
	  {1,4,6,8}, talents
);

return X