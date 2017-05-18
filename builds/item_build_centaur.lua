X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_tranquil_boots",
	"item_blink",
	"item_pipe",
	"item_ultimate_scepter",
	"item_shivas_guard",
	"item_heart"
};	
			
X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  {1,2,2,1,2,4,2,1,1,3,4,3,3,3,4}, skills, 
	  {1,3,5,8}, talents
);

return X