X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
				"item_tango",
                "item_stout_shield",
				"item_blight_stone",
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_ogre_axe",
				"item_quarterstaff",
				"item_robe",
				"item_sobi_mask",
				"item_mithril_hammer",
				"item_mithril_hammer",
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
local SKILL_Q = "life_stealer_rage";
local SKILL_W = "life_stealer_feast";
local SKILL_E = "life_stealer_open_wounds";
local SKILL_R = "life_stealer_infest";    

local ABILITY1 = "special_bonus_attack_speed_15"
local ABILITY2 = "special_bonus_all_stats_5"
local ABILITY3 = "special_bonus_attack_damage_25"
local ABILITY4 = "special_bonus_hp_250"
local ABILITY5 = "special_bonus_movement_speed_25"
local ABILITY6 = "special_bonus_evasion_15"
local ABILITY7 = "special_bonus_unique_lifestealer"
local ABILITY8 = "special_bonus_armor_15"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_R,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X