X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_blades_of_attack",
				"item_boots",
				"item_blades_of_attack",
				"item_shadow_amulet",
				"item_claymore",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_gloves",
				"item_recipe_maelstrom",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_hyperstone",
				"item_recipe_mjollnir",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_demon_edge",
				"item_javelin",
				"item_javelin",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "furion_sprout";
local SKILL_W = "furion_teleportation";
local SKILL_E = "furion_force_of_nature";
local SKILL_R = "furion_wrath_of_nature";    


local ABILITY1 = "special_bonus_hp_225"
local ABILITY2 = "special_bonus_attack_damage_30"
local ABILITY3 = "special_bonus_movement_speed_35"
local ABILITY4 = "special_bonus_intelligence_20"
local ABILITY5 = "special_bonus_armor_10"
local ABILITY6 = "special_bonus_attack_speed_35"
local ABILITY7 = "special_bonus_unique_furion"
local ABILITY8 = "special_bonus_respawn_reduction_40"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X