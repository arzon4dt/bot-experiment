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
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_vitality_booster",
				"item_staff_of_wizardry",
				"item_staff_of_wizardry",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "skywrath_mage_arcane_bolt";
local SKILL_W = "skywrath_mage_concussive_shot";
local SKILL_E = "skywrath_mage_ancient_seal";
local SKILL_R = "skywrath_mage_mystic_flare";    


local ABILITY1 = "special_bonus_intelligence_7"
local ABILITY2 = "special_bonus_hp_125"
local ABILITY3 = "special_bonus_gold_income_15"
local ABILITY4 = "special_bonus_attack_damage_75"
local ABILITY5 = "special_bonus_magic_resistance_15"
local ABILITY6 = "special_bonus_movement_speed_20"
local ABILITY7 = "special_bonus_unique_skywrath"
local ABILITY8 = "special_bonus_mp_regen_14"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X