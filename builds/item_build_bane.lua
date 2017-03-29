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
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_cloak",
				"item_shadow_amulet",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_belt_of_strength",
				"item_staff_of_wizardry",
				"item_recipe_necronomicon",
				"item_recipe_necronomicon",
				"item_recipe_necronomicon",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "bane_enfeeble";
local SKILL_W = "bane_brain_sap";
local SKILL_E = "bane_nightmare";
local SKILL_R = "bane_fiends_grip";    


local ABILITY1 = "special_bonus_mp_200"
local ABILITY2 = "special_bonus_armor_6"
local ABILITY3 = "special_bonus_exp_boost_25"
local ABILITY4 = "special_bonus_hp_250"
local ABILITY5 = "special_bonus_cast_range_175"
local ABILITY6 = "special_bonus_unique_bane_1"
local ABILITY7 = "special_bonus_unique_bane_2"
local ABILITY8 = "special_bonus_movement_speed_100"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X