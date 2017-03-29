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
				"item_blink",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "enigma_malefice";
local SKILL_W = "enigma_demonic_conversion";
local SKILL_E = "enigma_midnight_pulse";
local SKILL_R = "enigma_black_hole";    


local ABILITY1 = "special_bonus_magic_resistance_12"
local ABILITY2 = "special_bonus_movement_speed_20"
local ABILITY3 = "special_bonus_gold_income_20"
local ABILITY4 = "special_bonus_cooldown_reduction_15"
local ABILITY5 = "special_bonus_respawn_reduction_40"
local ABILITY6 = "special_bonus_hp_300"
local ABILITY7 = "special_bonus_unique_enigma"
local ABILITY8 = "special_bonus_armor_12"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X