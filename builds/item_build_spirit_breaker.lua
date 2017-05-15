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
				"item_boots",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_belt_of_strength",
				"item_gloves",
				"item_gauntlets",
				"item_gauntlets",
				"item_sobi_mask",
				"item_recipe_urn_of_shadows",
				"item_claymore",
				"item_shadow_amulet",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ultimate_orb",
				"item_recipe_silver_edge",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "spirit_breaker_charge_of_darkness";
local SKILL_W = "spirit_breaker_empowering_haste";
local SKILL_E = "spirit_breaker_greater_bash";
local SKILL_R = "spirit_breaker_nether_strike";    


local ABILITY1 = "special_bonus_strength_5"
local ABILITY2 = "special_bonus_attack_speed_15"
local ABILITY3 = "special_bonus_attack_damage_25"
local ABILITY4 = "special_bonus_armor_7"
local ABILITY5 = "special_bonus_gold_income_20"
local ABILITY6 = "special_bonus_hp_300"
local ABILITY7 = "special_bonus_unique_faceless_void"
local ABILITY8 = "special_bonus_evasion_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X