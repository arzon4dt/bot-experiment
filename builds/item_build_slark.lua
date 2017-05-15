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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_boots_of_elves",
				"item_gloves",
				"item_shadow_amulet",
				"item_claymore",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_recipe_abyssal_blade",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn"
			};

-- Set up Skill build
local SKILL_Q = "slark_dark_pact";
local SKILL_W = "slark_pounce";
local SKILL_E = "slark_essence_shift";
local SKILL_R = "slark_shadow_dance";    


local ABILITY1 = "special_bonus_attack_damage_15"
local ABILITY2 = "special_bonus_lifesteal_10"
local ABILITY3 = "special_bonus_strength_15"
local ABILITY4 = "special_bonus_agility_15"
local ABILITY5 = "special_bonus_attack_speed_25"
local ABILITY6 = "special_bonus_cooldown_reduction_10"
local ABILITY7 = "special_bonus_unique_slark"
local ABILITY8 = "special_bonus_all_stats_12"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_W,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X