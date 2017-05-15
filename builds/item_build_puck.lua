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
                "item_clarity",
				--"item_branches",
				--"item_branches",
				"item_circlet",
                "item_mantle",
                "item_recipe_null_talisman",
				--"item_bottle",
				--"item_magic_stick",
				"item_boots",
                "item_gloves",
                "item_belt_of_strength",
				--"item_energy_booster",
                "item_ring_of_regen",
				"item_staff_of_wizardry",
				"item_recipe_force_staff",
                "item_blink",
				"item_point_booster",
				"item_staff_of_wizardry",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_staff_of_wizardry",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon"
			};

-- Set up Skill build
local SKILL_Q = "puck_illusory_orb";
local SKILL_W = "puck_waning_rift";
local SKILL_E = "puck_phase_shift";
local SKILL_R = "puck_dream_coil";    
local SKILL_D = "puck_ethereal_jaunt";    -- no levels


local ABILITY1 = "special_bonus_intelligence_8"
local ABILITY2 = "special_bonus_hp_175"
local ABILITY3 = "special_bonus_attack_damage_50"
local ABILITY4 = "special_bonus_magic_resistance_20"
local ABILITY5 = "special_bonus_spell_amplify_10"
local ABILITY6 = "special_bonus_unique_puck_2"
local ABILITY7 = "special_bonus_gold_income_70"
local ABILITY8 = "special_bonus_unique_puck"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X