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
				"item_circlet",
				"item_slippers",
				"item_recipe_wraith_band",
				"item_boots",
				"item_ring_of_protection",
				"item_sobi_mask",
				"item_blades_of_attack",
				"item_blades_of_attack",
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
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_eagle",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_recipe_hurricane_pike"
			};

-- Set up Skill build
local SKILL_Q = "medusa_split_shot";
local SKILL_W = "medusa_mystic_snake";
local SKILL_E = "medusa_mana_shield";
local SKILL_R = "medusa_stone_gaze";    


local ABILITY1 = "special_bonus_attack_damage_15"
local ABILITY2 = "special_bonus_intelligence_12"
local ABILITY3 = "special_bonus_evasion_15"
local ABILITY4 = "special_bonus_attack_speed_20"
local ABILITY5 = "special_bonus_mp_600"
local ABILITY6 = "special_bonus_unique_medusa_1"
local ABILITY7 = "special_bonus_unique_medusa"
local ABILITY8 = "special_bonus_lifesteal_25"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_Q,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[4],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X