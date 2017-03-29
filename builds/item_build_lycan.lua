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
				"item_blight_stone",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
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
				"item_mithril_hammer",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_recipe_abyssal_blade",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "lycan_summon_wolves";
local SKILL_W = "lycan_howl";
local SKILL_E = "lycan_feral_impulse";
local SKILL_R = "lycan_shapeshift";    

local ABILITY1 = "special_bonus_hp_175"
local ABILITY2 = "special_bonus_attack_damage_15"
local ABILITY3 = "special_bonus_strength_12"
local ABILITY4 = "special_bonus_respawn_reduction_25"
local ABILITY5 = "special_bonus_cooldown_reduction_15"
local ABILITY6 = "special_bonus_evasion_15"
local ABILITY7 = "special_bonus_unique_lycan_2"
local ABILITY8 = "special_bonus_unique_lycan_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X