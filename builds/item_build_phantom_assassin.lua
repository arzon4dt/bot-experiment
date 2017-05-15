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
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_lifesteal",
				"item_blight_stone",
				"item_mithril_hammer",
				"item_mithril_hammer",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_recipe_abyssal_blade",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "phantom_assassin_stifling_dagger";
local SKILL_W = "phantom_assassin_phantom_strike";
local SKILL_E = "phantom_assassin_blur";
local SKILL_R = "phantom_assassin_coup_de_grace";    

local ABILITY1 = "special_bonus_attack_damage_15"
local ABILITY2 = "special_bonus_hp_150"
local ABILITY3 = "special_bonus_movement_speed_20"
local ABILITY4 = "special_bonus_lifesteal_10"
local ABILITY5 = "special_bonus_all_stats_10"
local ABILITY6 = "special_bonus_attack_speed_35"
local ABILITY7 = "special_bonus_unique_phantom_assassin"
local ABILITY8 = "special_bonus_agility_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X