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
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "naga_siren_mirror_image";
local SKILL_W = "naga_siren_ensnare";
local SKILL_E = "naga_siren_rip_tide";
local SKILL_R = "naga_siren_song_of_the_siren";    


local ABILITY1 = "special_bonus_hp_125"
local ABILITY2 = "special_bonus_mp_250"
local ABILITY3 = "special_bonus_unique_naga_siren_2"
local ABILITY4 = "special_bonus_attack_speed_30"
local ABILITY5 = "special_bonus_strength_20"
local ABILITY6 = "special_bonus_agility_15"
local ABILITY7 = "special_bonus_unique_naga_siren"
local ABILITY8 = "special_bonus_movement_speed_40"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X