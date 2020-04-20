X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

--[[X["items"] = { 
	"item_poor_mans_shield",
	"item_magic_wand",
	"item_phase_boots",
	"item_vanguard",
	"item_maelstrom",
	"item_assault",
	"item_mjollnir",
	"item_abyssal_blade",
	"item_butterfly",
	"item_heart"
};]]--

X["items"] = { 
	"item_phase_boots",
	"item_radiance",
	"item_assault",
	"item_basher",
	"item_black_king_bar",
	"item_abyssal_blade",
	"item_ultimate_scepter_2",
	"item_mjollnir"
};

X["builds"] = {
	{3,1,3,2,3,4,3,1,1,1,4,2,2,2,4},
	{3,1,3,1,3,4,3,1,1,2,4,2,2,2,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {1,4,6,7}, talents
);			

return X