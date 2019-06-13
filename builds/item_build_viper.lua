X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	-- "item_boots",
	-- "item_rod_of_atos",
	-- "item_guardian_greaves",
	-- "item_ultimate_scepter",
	-- "item_black_king_bar",
	-- "item_butterfly"
	"item_power_treads_agi",
	"item_dragon_lance",
	"item_maelstrom",
	"item_black_king_bar",
	"item_hurricane_pike",
	"item_manta",
	"item_mjollnir",
	"item_ultimate_scepter_2",
	"item_butterfly"
};			

X["builds"] = {
	{1,3,1,3,1,4,1,2,2,2,4,2,3,3,4},
	{1,3,1,2,1,4,1,3,3,3,4,2,2,2,4},
	{1,3,1,2,3,4,1,3,1,3,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,3,5,7}, talents
);

return X