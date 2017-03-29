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
				"item_belt_of_strength",
				"item_boots",
				"item_staff_of_wizardry",
				"item_recipe_necronomicon",
				"item_recipe_necronomicon",
				"item_recipe_necronomicon",
				"item_blink",
				"item_recipe_travel_boots",
				"item_ring_of_health",
				"item_energy_booster",
				"item_recipe_aether_lens",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault"
			};

-- Set up Skill build
local SKILL_Q = "beastmaster_wild_axes";
local SKILL_W = "beastmaster_call_of_the_wild_boar";
local SKILL_E = "beastmaster_inner_beast";
local SKILL_R = "beastmaster_primal_roar";    

local ABILITY1 = "special_bonus_movement_speed_20"
local ABILITY2 = "special_bonus_exp_boost_20"
local ABILITY3 = "special_bonus_respawn_reduction_35"
local ABILITY4 = "special_bonus_strength_12"
local ABILITY5 = "special_bonus_hp_400"
local ABILITY6 = "special_bonus_cooldown_reduction_12"
local ABILITY7 = "special_bonus_unique_beastmaster"
local ABILITY8 = "special_bonus_attack_damage_120"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X