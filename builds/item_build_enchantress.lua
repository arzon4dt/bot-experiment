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
				"item_gloves",
				"item_belt_of_strength",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_recipe_hurricane_pike",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "enchantress_untouchable";
local SKILL_W = "enchantress_enchant";
local SKILL_E = "enchantress_natures_attendants";
local SKILL_R = "enchantress_impetus";    


local ABILITY1 = "special_bonus_movement_speed_25"
local ABILITY2 = "special_bonus_all_stats_6"
local ABILITY3 = "special_bonus_attack_damage_50"
local ABILITY4 = "special_bonus_unique_enchantress_2"
local ABILITY5 = "special_bonus_unique_enchantress_3"
local ABILITY6 = "special_bonus_magic_resistance_15"
local ABILITY7 = "special_bonus_unique_enchantress_1"
local ABILITY8 = "special_bonus_respawn_reduction_50"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X