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
				"item_boots",
				"item_ring_of_protection",
				"item_ring_of_regen",
				"item_blink",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_chainmail",
				"item_robe",
				"item_broadsword",
				"item_chainmail",
				"item_branches",
				"item_recipe_buckler",
				"item_recipe_crimson_guard",
				"item_platemail",
				"item_ring_of_health",
				"item_void_stone",
				"item_energy_booster",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "axe_berserkers_call";
local SKILL_W = "axe_battle_hunger";
local SKILL_E = "axe_counter_helix";
local SKILL_R = "axe_culling_blade";    


local ABILITY1 = "special_bonus_mp_regen_3"
local ABILITY2 = "special_bonus_strength_6"
local ABILITY3 = "special_bonus_hp_250"
local ABILITY4 = "special_bonus_attack_damage_75"
local ABILITY5 = "special_bonus_movement_speed_35"
local ABILITY6 = "special_bonus_hp_regen_25"
local ABILITY7 = "special_bonus_unique_axe"
local ABILITY8 = "special_bonus_armor_15"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X