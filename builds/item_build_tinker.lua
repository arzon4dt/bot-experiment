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
				"item_mantle",
				"item_recipe_null_talisman",
				"item_bottle",
				"item_boots",
				"item_sobi_mask",
				"item_ring_of_regen",
				"item_recipe_soul_ring",
				"item_recipe_travel_boots",
				"item_blink",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_staff_of_wizardry",
				"item_recipe_dagon",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "tinker_laser";
local SKILL_W = "tinker_heat_seeking_missile";
local SKILL_E = "tinker_march_of_the_machines";
local SKILL_R = "tinker_rearm";    


local ABILITY1 = "special_bonus_armor_6"
local ABILITY2 = "special_bonus_intelligence_8"
local ABILITY3 = "special_bonus_spell_amplify_4"
local ABILITY4 = "special_bonus_hp_225"
local ABILITY5 = "special_bonus_magic_resistance_15"
local ABILITY6 = "special_bonus_cast_range_75"
local ABILITY7 = "special_bonus_unique_tinker"
local ABILITY8 = "special_bonus_spell_lifesteal_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X