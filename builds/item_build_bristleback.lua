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
				"item_quelling_blade",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_chainmail",
				"item_robe",
				"item_broadsword", 
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_chainmail",
				"item_branches",
				"item_recipe_buckler",
				"item_recipe_crimson_guard",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_platemail",
				"item_hyperstone",
				"item_chainmail",
				"item_recipe_assault",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "bristleback_viscous_nasal_goo";
local SKILL_W = "bristleback_quill_spray";
local SKILL_E = "bristleback_bristleback";
local SKILL_R = "bristleback_warpath";    


local ABILITY1 = "special_bonus_mp_regen_2"
local ABILITY2 = "special_bonus_strength_8"
local ABILITY3 = "special_bonus_hp_200"
local ABILITY4 = "special_bonus_unique_bristleback"
local ABILITY5 = "special_bonus_respawn_reduction_40"
local ABILITY6 = "special_bonus_attack_speed_50"
local ABILITY7 = "special_bonus_unique_bristleback_2"
local ABILITY8 = "special_bonus_hp_regen_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X