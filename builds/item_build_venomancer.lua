X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_wraith_band",
	"item_magic_wand",
	"item_tranquil_boots",
	"item_ring_of_aquila",
	"item_veil_of_discord",
	"item_cyclone",
	"item_force_staff",
	"item_ultimate_scepter",
	"item_octarine_core",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,3,1,1,4,1,3,2,3,4,2,3,2,4}, skills, 
	  {2,3,5,7}, talents
);

return X;