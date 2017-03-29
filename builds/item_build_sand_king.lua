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
				"item_blink",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "sandking_burrowstrike";
local SKILL_W = "sandking_sand_storm";
local SKILL_E = "sandking_caustic_finale";
local SKILL_R = "sandking_epicenter";    


local ABILITY1 = "special_bonus_armor_5"
local ABILITY2 = "special_bonus_magic_resistance_10"
local ABILITY3 = "special_bonus_respawn_reduction_30"
local ABILITY4 = "special_bonus_unique_sand_king_2"
local ABILITY5 = "special_bonus_gold_income_20"
local ABILITY6 = "special_bonus_hp_350"
local ABILITY7 = "special_bonus_unique_sand_king"
local ABILITY8 = "special_bonus_hp_regen_50"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X