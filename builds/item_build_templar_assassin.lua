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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_blink",
				"item_blight_stone",
				"item_mithril_hammer",
				"item_mithril_hammer",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "templar_assassin_refraction";
local SKILL_W = "templar_assassin_meld";
local SKILL_E = "templar_assassin_psi_blades";
local SKILL_R = "templar_assassin_psionic_trap";    


local ABILITY1 = "special_bonus_movement_speed_20"
local ABILITY2 = "special_bonus_attack_speed_25"
local ABILITY3 = "special_bonus_evasion_12"
local ABILITY4 = "special_bonus_all_stats_6"
local ABILITY5 = "special_bonus_attack_damage_40"
local ABILITY6 = "special_bonus_hp_275"
local ABILITY7 = "special_bonus_unique_templar_assassin"
local ABILITY8 = "special_bonus_respawn_reduction_30"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_W,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X