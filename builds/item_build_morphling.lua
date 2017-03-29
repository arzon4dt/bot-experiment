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
				"item_boots_of_elves",
				"item_gloves",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_ring_of_health",
				"item_void_stone",
				"item_ultimate_orb",
				"item_recipe_sphere",
				"item_ghost",
				"item_eagle",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_eagle"
			};

-- Set up Skill build
local SKILL_Q = "morphling_waveform";
local SKILL_W = "morphling_adaptive_strike";
local SKILL_E = "morphling_morph_agi";
local SKILL_R = "morphling_replicate";    


local ABILITY1 = "special_bonus_mp_200"
local ABILITY2 = "special_bonus_agility_8"
local ABILITY3 = "special_bonus_cooldown_reduction_12"
local ABILITY4 = "special_bonus_attack_speed_25"
local ABILITY5 = "special_bonus_attack_damage_40"
local ABILITY6 = "special_bonus_movement_speed_25"
local ABILITY7 = "special_bonus_unique_morphling_2"
local ABILITY8 = "special_bonus_unique_morphling_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_E,    SKILL_Q,    SKILL_E,    SKILL_R,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X