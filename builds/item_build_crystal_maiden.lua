X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_tranquil_boots",
	"item_aether_lens",
	"item_force_staff",
	"item_glimmer_cape",
	"item_black_king_bar",
	"item_ultimate_scepter",
	"item_hurricane_pike"
};			

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {2,3,1,2,2,4,2,1,1,1,4,3,3,3,4}, skills, 
	  {1,3,5,7}, talents
);

return X