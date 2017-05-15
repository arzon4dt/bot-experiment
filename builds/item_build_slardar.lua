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
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_blink",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_chainmail",
				"item_branches",
				"item_recipe_buckler",
				"item_recipe_crimson_guard",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "slardar_sprint";
local SKILL_W = "slardar_slithereen_crush";
local SKILL_E = "slardar_bash";
local SKILL_R = "slardar_amplify_damage";    


local ABILITY1 = "special_bonus_mp_175"
local ABILITY2 = "special_bonus_hp_regen_6"
local ABILITY3 = "special_bonus_attack_speed_25"
local ABILITY4 = "special_bonus_hp_225"
local ABILITY5 = "special_bonus_armor_7"
local ABILITY6 = "special_bonus_attack_damage_35"
local ABILITY7 = "special_bonus_unique_slardar"
local ABILITY8 = "special_bonus_strength_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_W,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X