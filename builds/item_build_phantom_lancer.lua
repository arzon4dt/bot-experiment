X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
				"item_tango",
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_gloves",
				"item_boots_of_elves",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_robe",
				"item_recipe_diffusal_blade",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_recipe_diffusal_blade",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_eagle",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "phantom_lancer_spirit_lance";
local SKILL_W = "phantom_lancer_doppelwalk";
local SKILL_E = "phantom_lancer_phantom_edge";
local SKILL_R = "phantom_lancer_juxtapose";    


local ABILITY1 = "special_bonus_attack_speed_20"
local ABILITY2 = "special_bonus_unique_phantom_lancer_2"
local ABILITY3 = "special_bonus_cooldown_reduction_15"
local ABILITY4 = "special_bonus_all_stats_8"
local ABILITY5 = "special_bonus_evasion_15"
local ABILITY6 = "special_bonus_magic_resistance_15"
local ABILITY7 = "special_bonus_unique_phantom_lancer"
local ABILITY8 = "special_bonus_strength_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X