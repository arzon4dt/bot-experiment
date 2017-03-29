X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_branches",
				"item_branches",
				"item_boots",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_chainmail",
				"item_recipe_buckler",
				"item_energy_booster",
				"item_recipe_mekansm",
				"item_blink",
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_recipe_guardian_greaves",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "tidehunter_gush";
local SKILL_W = "tidehunter_kraken_shell";
local SKILL_E = "tidehunter_anchor_smash";
local SKILL_R = "tidehunter_ravage";    

local ABILITY1 = "special_bonus_hp_150"
local ABILITY2 = "special_bonus_attack_damage_50"
local ABILITY3 = "special_bonus_exp_boost_35"
local ABILITY4 = "special_bonus_armor_7"
local ABILITY5 = "special_bonus_strength_15"
local ABILITY6 = "special_bonus_mp_regen_6"
local ABILITY7 = "special_bonus_unique_tidehunter"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X