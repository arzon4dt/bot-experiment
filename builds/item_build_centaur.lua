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
				"item_ring_of_protection",
				"item_boots",
				"item_ring_of_regen",
				"item_blink",
				--"item_chainmail",
				--"item_robe",
				--"item_broadsword",
				"item_cloak",
				"item_ring_of_health",
				"item_ring_of_regen",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				--"item_vitality_booster",
				--"item_ring_of_health",
				"item_ring_of_regen",
				"item_branches",
				"item_recipe_headdress",
				"item_recipe_pipe",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				---"item_chainmail",
				--"item_branches",
				--"item_recipe_buckler",
				--"item_recipe_crimson_guard",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "centaur_hoof_stomp";
local SKILL_W = "centaur_double_edge";
local SKILL_E = "centaur_return";
local SKILL_R = "centaur_stampede";    


local ABILITY1 = "special_bonus_mp_regen_2"
local ABILITY2 = "special_bonus_attack_damage_35"
local ABILITY3 = "special_bonus_magic_resistance_10"
local ABILITY4 = "special_bonus_evasion_10"
local ABILITY5 = "special_bonus_strength_15"
local ABILITY6 = "special_bonus_spell_amplify_10"
local ABILITY7 = "special_bonus_unique_centaur_2"
local ABILITY8 = "special_bonus_unique_centaur_1"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_W,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_Q,    talents[1],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X