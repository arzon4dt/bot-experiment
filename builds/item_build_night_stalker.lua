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
				"item_boots",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_gauntlets",
				"item_gauntlets",
				"item_sobi_mask",
				"item_recipe_urn_of_shadows",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_ogre_axe",
				"item_belt_of_strength",
				"item_recipe_sange",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_recipe_abyssal_blade",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "night_stalker_void";
local SKILL_W = "night_stalker_crippling_fear";
local SKILL_E = "night_stalker_hunter_in_the_night";
local SKILL_R = "night_stalker_darkness";    


local ABILITY1 = "special_bonus_cast_range_100"
local ABILITY2 = "special_bonus_strength_7"
local ABILITY3 = "special_bonus_attack_speed_25"
local ABILITY4 = "special_bonus_mp_300"
local ABILITY5 = "special_bonus_attack_damage_50"
local ABILITY6 = "special_bonus_movement_speed_30"
local ABILITY7 = "special_bonus_unique_night_stalker"
local ABILITY8 = "special_bonus_unique_armor_12"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X