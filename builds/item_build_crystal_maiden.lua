X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
                "item_tango",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "crystal_maiden_crystal_nova";
local SKILL_W = "crystal_maiden_frostbite";
local SKILL_E = "crystal_maiden_brilliance_aura";
local SKILL_R = "crystal_maiden_freezing_field";    


local ABILITY1 = "special_bonus_attack_damage_60"
local ABILITY2 = "special_bonus_magic_resistance_15"
local ABILITY3 = "special_bonus_hp_250"
local ABILITY4 = "special_bonus_cast_range_125"
local ABILITY5 = "special_bonus_respawn_reduction_35"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_crystal_maiden_2"
local ABILITY8 = "special_bonus_unique_crystal_maiden_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X