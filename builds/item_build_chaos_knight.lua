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
				"item_robe",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_recipe_diffusal_blade",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_talisman_of_evasion",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_recipe_diffusal_blade",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "chaos_knight_chaos_bolt";
local SKILL_W = "chaos_knight_reality_rift";
local SKILL_E = "chaos_knight_chaos_strike";
local SKILL_R = "chaos_knight_phantasm";    


local ABILITY1 = "special_bonus_intelligence_8"
local ABILITY2 = "special_bonus_attack_speed_15"
local ABILITY3 = "special_bonus_strength_10"
local ABILITY4 = "special_bonus_movement_speed_20"
local ABILITY5 = "special_bonus_all_stats_12"
local ABILITY6 = "special_bonus_gold_income_20"
local ABILITY7 = "special_bonus_unique_chaos_knight"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_E,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X