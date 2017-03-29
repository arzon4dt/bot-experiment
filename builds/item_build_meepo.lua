X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ NOT SURE IF STILL AN ISSUE: warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will possilby break! ]]
X["items"] = {
--"item_tango",
--"item_tango",
--"item_quelling_blade", -- iron talon
--"item_ring_of_protection", -- iron talon
"item_slippers", -- poor mans shield
"item_slippers", -- poor mans shield
"item_stout_shield", -- poor mans shield
--"item_recipe_iron_talon", -- iron talon
"item_boots", -- power treads
"item_gloves",-- power treads
"item_belt_of_strength",-- power treads
"item_blade_of_alacrity", -- aghs
"item_ogre_axe",-- aghs
"item_point_booster",-- aghs
"item_staff_of_wizardry",-- aghs
"item_ogre_axe", -- dragon lance
"item_boots_of_elves",-- dragon lance
"item_boots_of_elves",-- dragon lance
"item_blink",
"item_blade_of_alacrity", -- yasha
"item_boots_of_elves", -- yasha
"item_recipe_yasha", -- yasha
--"item_ogre_axe",-- dragon lance
--"item_boots_of_elves",-- dragon lance
--"item_boots_of_elves",-- dragon lance
"item_ogre_axe", -- sange
"item_belt_of_strength",-- sange
"item_recipe_sange",-- sange
"item_ring_of_regen", -- force staff
"item_staff_of_wizardry",-- force staff
"item_recipe_force_staff",-- force staff
"item_recipe_hurricane_pike",
}

-- Set up Skill build
local SKILL_Q = "meepo_earthbind";
local SKILL_W = "meepo_poof";
local SKILL_E = "meepo_geostrike";
local SKILL_R = "meepo_divided_we_stand";    

local ABILITY1  = "special_bonus_armor_4"
local ABILITY2  = "special_bonus_attack_damage_15"
local ABILITY3  = "special_bonus_lifesteal_15"
local ABILITY4  = "special_bonus_movement_speed_25"
local ABILITY5  = "special_bonus_evasion_10"
local ABILITY6  = "special_bonus_attack_speed_25"
local ABILITY7  = "special_bonus_hp_400"
local ABILITY8  = "special_bonus_unique_meepo"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_W,
    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    SKILL_R,    "-1",    	"-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X