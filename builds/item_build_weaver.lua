X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = {
				"item_tango",
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_boots_of_elves",
				"item_gloves",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_mithril_hammer",
				"item_gloves",
				"item_recipe_maelstrom",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_hyperstone",
				"item_recipe_mjollnir",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_demon_edge",
				"item_recipe_greater_crit",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "weaver_the_swarm";
local SKILL_W = "weaver_shukuchi";
local SKILL_E = "weaver_geminate_attack";
local SKILL_R = "weaver_time_lapse";    


local ABILITY1 = "special_bonus_unique_weaver_1"
local ABILITY2 = "special_bonus_strength_6"
local ABILITY3 = "special_bonus_all_stats_7"
local ABILITY4 = "special_bonus_attack_damage_25"
local ABILITY5 = "special_bonus_agility_15"
local ABILITY6 = "special_bonus_hp_200"
local ABILITY7 = "special_bonus_unique_weaver_2"
local ABILITY8 = "special_bonus_magic_resistance_35"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X