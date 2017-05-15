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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_blink",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "earthshaker_fissure";
local SKILL_W = "earthshaker_enchant_totem";
local SKILL_E = "earthshaker_aftershock";
local SKILL_R = "earthshaker_echo_slam";    


local ABILITY1 = "special_bonus_mp_250"
local ABILITY2 = "special_bonus_strength_10"
local ABILITY3 = "special_bonus_attack_damage_50"
local ABILITY4 = "special_bonus_movement_speed_20"
local ABILITY5 = "special_bonus_respawn_reduction_35"
local ABILITY6 = "special_bonus_unique_earthshaker_2"
local ABILITY7 = "special_bonus_unique_earthshaker"
local ABILITY8 = "special_bonus_hp_600"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X