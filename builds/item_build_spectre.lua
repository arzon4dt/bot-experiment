X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_flask",
				"item_tango",
				"item_stout_shield",
				"item_quelling_blade",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_robe",
				"item_recipe_diffusal_blade",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_recipe_diffusal_blade",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_recipe_abyssal_blade",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "spectre_spectral_dagger";
local SKILL_W = "spectre_desolate";
local SKILL_E = "spectre_dispersion";
local SKILL_R = "spectre_haunt";    


local ABILITY1 = "special_bonus_armor_5"
local ABILITY2 = "special_bonus_attack_damage_20"
local ABILITY3 = "special_bonus_movement_speed_20"
local ABILITY4 = "special_bonus_all_stats_8"
local ABILITY5 = "special_bonus_strength_20"
local ABILITY6 = "special_bonus_attack_speed_30"
local ABILITY7 = "special_bonus_unique_spectre"
local ABILITY8 = "special_bonus_hp_400"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X