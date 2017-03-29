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
				"item_clarity",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff",
				"item_ring_of_health",
				"item_void_stone",
				"item_ring_of_health",
				"item_void_stone",
				"item_recipe_refresher"
			};

-- Set up Skill build
local SKILL_Q = "zuus_arc_lightning";
local SKILL_W = "zuus_lightning_bolt";
local SKILL_E = "zuus_static_field";
local SKILL_R = "zuus_thundergods_wrath";    


local ABILITY1 = "special_bonus_hp_200"
local ABILITY2 = "special_bonus_mp_regen_2"
local ABILITY3 = "special_bonus_magic_resistance_10"
local ABILITY4 = "special_bonus_armor_5"
local ABILITY5 = "special_bonus_respawn_reduction_40"
local ABILITY6 = "special_bonus_movement_speed_35"
local ABILITY7 = "special_bonus_unique_zeus"
local ABILITY8 = "special_bonus_cast_range_200"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X