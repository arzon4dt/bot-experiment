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
				"item_gauntlets",
				"item_gauntlets",
				"item_sobi_mask",
				"item_recipe_urn_of_shadows",
				"item_energy_booster",
				"item_branches",
				"item_ring_of_regen",
				"item_recipe_headdress",
				"item_branches",
				"item_chainmail",
				"item_recipe_buckler",
				"item_recipe_mekansm",
				"item_cloak",
				"item_shadow_amulet",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_recipe_guardian_greaves",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "wisp_tether";
local SKILL_W = "wisp_spirits";
local SKILL_E = "wisp_overcharge";
local SKILL_R = "wisp_relocate";    


local ABILITY1 = "special_bonus_armor_6"
local ABILITY2 = "special_bonus_magic_resistance_10"
local ABILITY3 = "special_bonus_strength_10"
local ABILITY4 = "special_bonus_mp_regen_10"
local ABILITY5 = "special_bonus_gold_income_20"
local ABILITY6 = "special_bonus_hp_regen_20"
local ABILITY7 = "special_bonus_unique_wisp"
local ABILITY8 = "special_bonus_respawn_reduction_50"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X