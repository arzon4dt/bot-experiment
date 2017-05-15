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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_blink",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ogre_axe",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_recipe_hurricane_pike",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "lion_impale";
local SKILL_W = "lion_voodoo";
local SKILL_E = "lion_mana_drain";
local SKILL_R = "lion_finger_of_death";    


local ABILITY1 = "special_bonus_attack_damage_60"
local ABILITY2 = "special_bonus_respawn_reduction_30"
local ABILITY3 = "special_bonus_gold_income_15"
local ABILITY4 = "special_bonus_unique_lion_2"
local ABILITY5 = "special_bonus_spell_amplify_8"
local ABILITY6 = "special_bonus_magic_resistance_20"
local ABILITY7 = "special_bonus_unique_lion"
local ABILITY8 = "special_bonus_all_stats_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X