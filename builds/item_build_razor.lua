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
				"item_stout_shield",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_chainmail",
				"item_robe",
				"item_broadsword",
				"item_chainmail",
				"item_branches",
				"item_recipe_buckler",
				"item_recipe_crimson_guard",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "razor_plasma_field";
local SKILL_W = "razor_static_link";
local SKILL_E = "razor_unstable_current";
local SKILL_R = "razor_eye_of_the_storm";    


local ABILITY1 = "special_bonus_agility_15"
local ABILITY2 = "special_bonus_movement_speed_20"
local ABILITY3 = "special_bonus_cast_range_150"
local ABILITY4 = "special_bonus_unique_razor_2"
local ABILITY5 = "special_bonus_attack_speed_30"
local ABILITY6 = "special_bonus_hp_275"
local ABILITY7 = "special_bonus_unique_razor"
local ABILITY8 = "special_bonus_attack_range_175"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X