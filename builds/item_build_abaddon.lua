X = {}

local IBUtil  = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot  = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = {
	"item_magic_wand",
	"item_phase_boots",
	"item_blade_mail",
	"item_holy_locket",
	"item_kaya_and_sange",
	"item_lotus_orb",
	"item_ultimate_scepter_2",
	"item_shivas_guard"
};

X["builds"] = {
	{2,3,2,3,2,4,2,3,3,1,4,1,1,1,4},
	{2,1,3,2,2,4,2,1,1,1,4,3,3,3,4}
}

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  IBUtil.GetRandomBuild(X['builds']), skills, 
	  {2,3,6,8}, talents
);

return X