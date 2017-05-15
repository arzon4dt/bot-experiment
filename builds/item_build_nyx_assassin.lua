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
				"item_clarity",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_staff_of_wizardry",
				"item_recipe_dagon",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_blink",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon"
			};

-- Set up Skill build
local SKILL_Q = "nyx_assassin_impale";
local SKILL_W = "nyx_assassin_mana_burn";
local SKILL_E = "nyx_assassin_spiked_carapace";
local SKILL_R = "nyx_assassin_vendetta";    


local ABILITY1 = "special_bonus_hp_175"
local ABILITY2 = "special_bonus_spell_amplify_5"
local ABILITY3 = "special_bonus_unique_nyx_2"
local ABILITY4 = "special_bonus_magic_resistance_12"
local ABILITY5 = "special_bonus_agility_40"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_nyx"
local ABILITY8 = "special_bonus_movement_speed_40"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X