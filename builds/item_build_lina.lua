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
				"item_clarity",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
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
local SKILL_Q = "lina_dragon_slave";
local SKILL_W = "lina_light_strike_array";
local SKILL_E = "lina_fiery_soul";
local SKILL_R = "lina_laguna_blade";    


local ABILITY1 = "special_bonus_respawn_reduction_30"
local ABILITY2 = "special_bonus_unique_lina_3"
local ABILITY3 = "special_bonus_cast_range_125"
local ABILITY4 = "special_bonus_attack_damage_50"
local ABILITY5 = "special_bonus_attack_range_150"
local ABILITY6 = "special_bonus_spell_amplify_6"
local ABILITY7 = "special_bonus_unique_lina_2"
local ABILITY8 = "special_bonus_unique_lina_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X