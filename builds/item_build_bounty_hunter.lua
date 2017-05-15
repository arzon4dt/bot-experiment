X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
				"item_tango",
				"item_flask",
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_blight_stone",
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_sobi_mask",
				"item_chainmail",
				"item_mithril_hammer",
				"item_mithril_hammer",
				"item_blight_stone",
				"item_talisman_of_evasion",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn"
			};

-- Set up Skill build
local SKILL_Q = "bounty_hunter_shuriken_toss";
local SKILL_W = "bounty_hunter_jinada";
local SKILL_E = "bounty_hunter_wind_walk";
local SKILL_R = "bounty_hunter_track";    


local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_hp_175"
local ABILITY3 = "special_bonus_movement_speed_15"
local ABILITY4 = "special_bonus_attack_speed_40"
local ABILITY5 = "special_bonus_attack_damage_120"
local ABILITY6 = "special_bonus_unique_bounty_hunter_2"
local ABILITY7 = "special_bonus_unique_bounty_hunter"
local ABILITY8 = "special_bonus_evasion_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_W,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X