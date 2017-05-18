X = {}

local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
local skills  = IBUtil.FillSkillTable(npcBot, IBUtil.GetSlotPattern(5));

X["items"] = { 
	"item_magic_wand",
	"item_phase_boots",
	"item_ultimate_scepter",
	"item_cyclone",
	"item_blink",
	"item_sheepstick",
	"item_octarine_core"
};			

local Roll = RollPercentage(50); 

if Roll then
	print("Invoker build is QE")	
	X["skills"] = IBUtil.GetBuildPattern(
		  "invoker", 
		  {3,1,3,1,3,1,3,1,2,3,3,3,2,2,2,2,2,2,1,1,1}, skills, 
		  {1,4,5,8}, talents
	);
else
	print("Invoker build is QW")
	X["skills"] = IBUtil.GetBuildPattern(
		  "invoker", 
		  {1,2,1,2,1,2,1,2,3,2,2,2,3,3,3,1,1,1,3,3,3}, skills, 
		  {1,4,5,8}, talents
	);
end	
	
return X