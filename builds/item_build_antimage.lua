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
				"item_quelling_blade",
				"item_boots",
				"item_boots_of_elves",
				"item_gloves",
				"item_ring_of_health",
				"item_void_stone",
				"item_claymore",
				"item_broadsword",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_recipe_abyssal_blade",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "antimage_mana_break";
local SKILL_W = "antimage_blink";
local SKILL_E = "antimage_spell_shield";
local SKILL_R = "antimage_mana_void";    

local ABILITY1 = "special_bonus_attack_damage_20"
local ABILITY2 = "special_bonus_hp_150"
local ABILITY3 = "special_bonus_unique_antimage"
local ABILITY4 = "special_bonus_attack_speed_20"
local ABILITY5 = "special_bonus_all_stats_10"
local ABILITY6 = "special_bonus_evasion_15"
local ABILITY7 = "special_bonus_unique_antimage_2"
local ABILITY8 = "special_bonus_agility_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_E,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_Q,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X