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
				"item_boots_of_elves",
				"item_gloves",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_point_booster",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_staff_of_wizardry",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "viper_poison_attack";
local SKILL_W = "viper_nethertoxin";
local SKILL_E = "viper_corrosive_skin";
local SKILL_R = "viper_viper_strike";    

local ABILITY1 = "special_bonus_attack_damage_15"
local ABILITY2 = "special_bonus_hp_150"
local ABILITY3 = "special_bonus_strength_8"
local ABILITY4 = "special_bonus_agility_14"
local ABILITY5 = "special_bonus_armor_7"
local ABILITY6 = "special_bonus_attack_range_75"
local ABILITY7 = "special_bonus_unique_viper_1"
local ABILITY8 = "special_bonus_unique_viper_2"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X