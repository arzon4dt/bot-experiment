X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
				"item_tango",
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_boots_of_elves",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_recipe_abyssal_blade",
				"item_eagle",
				"item_talisman_of_evasion",
				"item_quarterstaff",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "bloodseeker_bloodrage";
local SKILL_W = "bloodseeker_blood_bath";
local SKILL_E = "bloodseeker_thirst";
local SKILL_R = "bloodseeker_rupture";    


local ABILITY1 = "special_bonus_attack_damage_25"
local ABILITY2 = "special_bonus_hp_225"
local ABILITY3 = "special_bonus_unique_bloodseeker_2"
local ABILITY4 = "special_bonus_attack_speed_30"
local ABILITY5 = "special_bonus_all_stats_10"
local ABILITY6 = "special_bonus_unique_bloodseeker_3"
local ABILITY7 = "special_bonus_lifesteal_30"
local ABILITY8 = "special_bonus_unique_bloodseeker"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X