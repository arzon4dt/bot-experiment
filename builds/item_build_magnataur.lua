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
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_blink",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_ring_of_health",
				"item_void_stone",
				"item_ring_of_health",
				"item_void_stone",
				"item_recipe_refresher",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar"
			};

-- Set up Skill build
local SKILL_Q = "magnataur_shockwave";
local SKILL_W = "magnataur_empower";
local SKILL_E = "magnataur_skewer";
local SKILL_R = "magnataur_reverse_polarity";    


local ABILITY1 = "special_bonus_spell_amplify_15"
local ABILITY2 = "special_bonus_attack_speed_25"
local ABILITY3 = "special_bonus_strength_12"
local ABILITY4 = "special_bonus_gold_income_15"
local ABILITY5 = "special_bonus_movement_speed_40"
local ABILITY6 = "special_bonus_unique_magnataur_2"
local ABILITY7 = "special_bonus_unique_magnataur"
local ABILITY8 = "special_bonus_respawn_reduction_35"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X