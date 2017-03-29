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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_belt_of_strength",
				"item_boots",
				"item_gloves",
				"item_lifesteal",
				"item_ogre_axe",
				"item_quarterstaff",
				"item_robe",
				"item_sobi_mask",
				"item_blink",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_mithril_hammer",
				"item_reaver"
			};

-- Set up Skill build
local SKILL_Q = "sven_storm_bolt";
local SKILL_W = "sven_great_cleave";
local SKILL_E = "sven_warcry";
local SKILL_R = "sven_gods_strength";    

local ABILITY1 = "special_bonus_mp_200"
local ABILITY2 = "special_bonus_strength_6"
local ABILITY3 = "special_bonus_all_stats_8"
local ABILITY4 = "special_bonus_movement_speed_20"
local ABILITY5 = "special_bonus_evasion_15"
local ABILITY6 = "special_bonus_attack_speed_30"
local ABILITY7 = "special_bonus_unique_sven"
local ABILITY8 = "special_bonus_attack_damage_65"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X