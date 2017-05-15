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
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_mithril_hammer",
				"item_gloves",
				"item_recipe_maelstrom",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_hyperstone",
				"item_recipe_mjollnir",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit"
			};


-- Set up Skill build
local SKILL_Q = "troll_warlord_berserkers_rage";
local SKILL_W = "troll_warlord_whirling_axes_ranged";
local SKILL_E = "troll_warlord_fervor";
local SKILL_R = "troll_warlord_battle_trance";    


local ABILITY1 = "special_bonus_agility_10"
local ABILITY2 = "special_bonus_strength_7"
local ABILITY3 = "special_bonus_armor_6"
local ABILITY4 = "special_bonus_movement_speed_15"
local ABILITY5 = "special_bonus_attack_damage_40"
local ABILITY6 = "special_bonus_hp_350"
local ABILITY7 = "special_bonus_unique_troll_warlord"
local ABILITY8 = "special_bonus_magic_resistance_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X