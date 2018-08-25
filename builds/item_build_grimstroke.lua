X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(1));

X["items"] = { 
	"item_magic_wand",
	"item_arcane_boots",
	"item_force_staff",
	"item_glimmer_cape",
	"item_aether_lens",
	"item_cyclone",
	"item_sheepstick",
	"item_hurricane_pike"
};			

local Roll = RollPercentage(50); 
local build = {1,2,1,3,1,4,1,3,3,3,4,2,2,2,4};

if Roll then
	  build = {1,2,1,3,1,4,1,2,2,2,4,3,3,3,4};
end

X["skills"] = IBUtil.GetBuildPattern(
	  "normal", 
	  build, skills, 
	  {1,3,5,7}, talents
);

return X