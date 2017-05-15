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
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_gloves",
				"item_boots_of_elves",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_robe",
				"item_recipe_diffusal_blade",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_recipe_abyssal_blade",
				"item_recipe_diffusal_blade",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_eagle",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom"
			};

-- Set up Skill build
local SKILL_Q = "riki_smoke_screen";
local SKILL_W = "riki_blink_strike";
local SKILL_E = "riki_permanent_invisibility";
local SKILL_R = "riki_tricks_of_the_trade";    


local ABILITY1 = "special_bonus_movement_speed_15"
local ABILITY2 = "special_bonus_hp_150"
local ABILITY3 = "special_bonus_exp_boost_30"
local ABILITY4 = "special_bonus_agility_10"
local ABILITY5 = "special_bonus_all_stats_8"
local ABILITY6 = "special_bonus_cast_range_250"
local ABILITY7 = "special_bonus_unique_riki_1"
local ABILITY8 = "special_bonus_unique_riki_2"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X