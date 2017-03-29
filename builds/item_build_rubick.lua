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
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_blink"
				--[["item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity"]]--
			};

-- Set up Skill build
local SKILL_Q = "rubick_telekinesis";
local SKILL_W = "rubick_fade_bolt";
local SKILL_E = "rubick_null_field";
local SKILL_R = "rubick_spell_steal";    

local ABILITY1 = "special_bonus_attack_damage_60"
local ABILITY2 = "special_bonus_gold_income_10"
local ABILITY3 = "special_bonus_intelligence_15"
local ABILITY4 = "special_bonus_hp_150"
local ABILITY5 = "special_bonus_spell_amplify_8"
local ABILITY6 = "special_bonus_cast_range_75"
local ABILITY7 = "special_bonus_unique_rubick"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X