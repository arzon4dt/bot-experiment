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
				"item_quelling_blade",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_claymore",
				"item_shadow_amulet",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_lifesteal",
				"item_mithril_hammer",
				"item_reaver"
			};

-- Set up Skill build
local SKILL_Q = "dragon_knight_breathe_fire";
local SKILL_W = "dragon_knight_dragon_tail";
local SKILL_E = "dragon_knight_dragon_blood";
local SKILL_R = "dragon_knight_elder_dragon_form";    


local ABILITY1 = "special_bonus_attack_speed_25"
local ABILITY2 = "special_bonus_strength_9"
local ABILITY3 = "special_bonus_attack_damage_40"
local ABILITY4 = "special_bonus_exp_boost_35"
local ABILITY5 = "special_bonus_hp_300"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_dragon_knight"
local ABILITY8 = "special_bonus_movement_speed_75"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X