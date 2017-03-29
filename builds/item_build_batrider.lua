X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_ring_of_protection",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_regen",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_blink",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				--[["item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity"]]--
			};

-- Set up Skill build
local SKILL_Q = "batrider_sticky_napalm";
local SKILL_W = "batrider_flamebreak";
local SKILL_E = "batrider_firefly";
local SKILL_R = "batrider_flaming_lasso";    

local ABILITY1 = "special_bonus_armor_4"
local ABILITY2 = "special_bonus_intelligence_10"
local ABILITY3 = "special_bonus_hp_200"
local ABILITY4 = "special_bonus_spell_amplify_5"
local ABILITY5 = "special_bonus_movement_speed_35"
local ABILITY6 = "special_bonus_cooldown_reduction_15"
local ABILITY7 = "special_bonus_unique_batrider_2"
local ABILITY8 = "special_bonus_unique_batrider_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_E,    SKILL_W,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X