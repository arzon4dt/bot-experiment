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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_belt_of_strength",
				"item_boots",
				"item_gloves",
				"item_ogre_axe",
				"item_quarterstaff",
				"item_robe",
				"item_sobi_mask",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_blink",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "monkey_king_boundless_strike";
local SKILL_W = "monkey_king_tree_dance";
local SKILL_E = "monkey_king_jingu_mastery";
local SKILL_R = "monkey_king_wukongs_command";    


local ABILITY1 = "special_bonus_armor_5"
local ABILITY2 = "special_bonus_attack_speed_20"
local ABILITY3 = "special_bonus_unique_monkey_king_2"
local ABILITY4 = "special_bonus_hp_275"
local ABILITY5 = "special_bonus_magic_resistance_20"
local ABILITY6 = "special_bonus_attack_damage_40"
local ABILITY7 = "special_bonus_unique_monkey_king"
local ABILITY8 = "special_bonus_strength_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X