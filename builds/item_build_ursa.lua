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
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_lifesteal",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_blink",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_robe",
				"item_recipe_diffusal_blade",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_recipe_abyssal_blade",
				"item_recipe_diffusal_blade",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar"
				
			};

-- Set up Skill build
local SKILL_Q = "ursa_earthshock";
local SKILL_W = "ursa_overpower";
local SKILL_E = "ursa_fury_swipes";
local SKILL_R = "ursa_enrage";    

local ABILITY1 = "special_bonus_attack_damage_25"
local ABILITY2 = "special_bonus_magic_resistance_10"
local ABILITY3 = "special_bonus_armor_5"
local ABILITY4 = "special_bonus_attack_speed_20"
local ABILITY5 = "special_bonus_movement_speed_15"
local ABILITY6 = "special_bonus_hp_250"
local ABILITY7 = "special_bonus_unique_ursa"
local ABILITY8 = "special_bonus_all_stats_14"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_W,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_Q,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X