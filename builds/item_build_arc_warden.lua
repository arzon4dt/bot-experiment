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
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots_of_elves",
				"item_gloves",
				"item_mithril_hammer",
				"item_gloves",
				"item_recipe_maelstrom",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_hyperstone",
				"item_recipe_mjollnir",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "arc_warden_flux";
local SKILL_W = "arc_warden_magnetic_field";
local SKILL_E = "arc_warden_spark_wraith";
local SKILL_R = "arc_warden_tempest_double";    


local ABILITY1 = "special_bonus_attack_speed_25"
local ABILITY2 = "special_bonus_unique_arc_warden_2"
local ABILITY3 = "special_bonus_hp_200"
local ABILITY4 = "special_bonus_attack_damage_30"
local ABILITY5 = "special_bonus_attack_range_100"
local ABILITY6 = "special_bonus_cooldown_reduction_10"
local ABILITY7 = "special_bonus_unique_arc_warden"
local ABILITY8 = "special_bonus_lifesteal_30"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X