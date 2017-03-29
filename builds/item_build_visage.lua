X = {};
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
X["items"] = { 
                "item_clarity",
                "item_tango",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_chainmail",
				"item_blight_stone",
				"item_sobi_mask",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_branches",
				"item_chainmail",
				"item_recipe_buckler",
				"item_recipe_mekansm",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_point_booster" ,
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_staff_of_wizardry",
				"item_talisman_of_evasion",
				"item_recipe_guardian_greaves",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "visage_grave_chill";
local SKILL_W = "visage_soul_assumption";
local SKILL_E = "visage_gravekeepers_cloak";
local SKILL_R = "visage_summon_familiars";    


local ABILITY1 = "special_bonus_gold_income_15"
local ABILITY2 = "special_bonus_exp_boost_30"
local ABILITY3 = "special_bonus_attack_damage_50"
local ABILITY4 = "special_bonus_cast_range_100"
local ABILITY5 = "special_bonus_hp_300"
local ABILITY6 = "special_bonus_respawn_reduction_40"
local ABILITY7 = "special_bonus_spell_amplify_20"
local ABILITY8 = "special_bonus_unique_visage_2"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[2],--"special_bonus_intelligence_8",
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],--"special_bonus_attack_damage_40",
    SKILL_Q,    "-1",       SKILL_R,    "-1",  		talents[5],--"special_bonus_spell_amplify_8",
    "-1",   	"-1",  	 	"-1",       "-1",       talents[8]--"special_bonus_gold_income_50"
};




return X