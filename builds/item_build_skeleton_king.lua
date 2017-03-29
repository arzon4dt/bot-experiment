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
				"item_quelling_blade",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_ogre_axe",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_blink",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_vitality_booster",
				"item_ring_of_health",
				"item_recipe_abyssal_blade",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "skeleton_king_hellfire_blast";
local SKILL_W = "skeleton_king_vampiric_aura";
local SKILL_E = "skeleton_king_mortal_strike";
local SKILL_R = "skeleton_king_reincarnation";    


local ABILITY1 = "special_bonus_intelligence_10"
local ABILITY2 = "special_bonus_attack_damage_15"
local ABILITY3 = "special_bonus_unique_wraith_king_3"
local ABILITY4 = "special_bonus_movement_speed_15"
local ABILITY5 = "special_bonus_strength_20"
local ABILITY6 = "special_bonus_attack_speed_40"
local ABILITY7 = "special_bonus_unique_wraith_king_2"
local ABILITY8 = "special_bonus_unique_wraith_king_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X