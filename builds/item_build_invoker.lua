X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_ultimate_scepter",
	"item_cyclone",
	"item_force_staff",
	"item_sheepstick",
	"item_hurricane_pike",
	"item_octarine_core"
};			

X["builds"] = {
	{3,1,3,1,3,1,3,1,2,3,3,3,2,2,2,2,2,2,1,1,1},
	{1,2,1,2,1,2,1,2,3,2,2,2,3,3,3,1,1,1,3,3,3}
}

X["skills"] = IBUtil.GetBuildPattern(
	"invoker", 
	IBUtil.GetRandomBuild(X['builds']), skills, 
	{1,4,5,8}, talents
);

return X