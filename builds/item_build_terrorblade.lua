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
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "terrorblade_reflection";
local SKILL_W = "terrorblade_conjure_image";
local SKILL_E = "terrorblade_metamorphosis";
local SKILL_R = "terrorblade_sunder";    

local ABILITY1 = "special_bonus_attack_speed_15"
local ABILITY2 = "special_bonus_hp_regen_6"
local ABILITY3 = "special_bonus_hp_200"
local ABILITY4 = "special_bonus_attack_damage_25"
local ABILITY5 = "special_bonus_movement_speed_25"
local ABILITY6 = "special_bonus_agility_15"
local ABILITY7 = "special_bonus_unique_terrorblade"
local ABILITY8 = "special_bonus_all_stats_15"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_E,
    SKILL_R,    SKILL_E,    SKILL_W,    SKILL_W,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X