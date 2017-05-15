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
				"item_belt_of_strength",
				"item_boots",
				"item_gloves",
				"item_chainmail",
				"item_robe",
				"item_broadsword",
				"item_shadow_amulet",
				"item_claymore",
				"item_blink",
				--"item_blight_stone",
				--"item_mithril_hammer",
				--"item_mithril_hammer",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "legion_commander_overwhelming_odds";
local SKILL_W = "legion_commander_press_the_attack";
local SKILL_E = "legion_commander_moment_of_courage";
local SKILL_R = "legion_commander_duel";   


local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_strength_7"
local ABILITY3 = "special_bonus_movement_speed_20"
local ABILITY4 = "special_bonus_attack_damage_30"
local ABILITY5 = "special_bonus_respawn_reduction_20"
local ABILITY6 = "special_bonus_armor_7"
local ABILITY7 = "special_bonus_unique_legion_commander_2"
local ABILITY8 = "special_bonus_unique_legion_commander"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X