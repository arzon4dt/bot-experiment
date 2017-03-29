X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);

X["items"] = {
				"item_tango",
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots_of_elves",
				"item_gloves",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_point_booster",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_staff_of_wizardry",
				"item_point_booster",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_recipe_hurricane_pike",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};
-- Set up Skill build
local SKILL_Q = "venomancer_venomous_gale";
local SKILL_W = "venomancer_poison_sting";
local SKILL_E = "venomancer_plague_ward";
local SKILL_R = "venomancer_poison_nova";    

local ABILITY1 = "special_bonus_exp_boost_30"
local ABILITY2 = "special_bonus_movement_speed_30"
local ABILITY3 = "special_bonus_hp_200"
local ABILITY4 = "special_bonus_cast_range_150"
local ABILITY5 = "special_bonus_attack_damage_75"
local ABILITY6 = "special_bonus_magic_resistance_15"
local ABILITY7 = "special_bonus_respawn_reduction_60"
local ABILITY8 = "special_bonus_unique_venomancer"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_Q,    SKILL_Q,    SKILL_W,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_E,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X;