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
				"item_clarity",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_gloves",
				"item_robe",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_ogre_axe",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_recipe_hurricane_pike",
				"item_staff_of_wizardry",
				"item_staff_of_wizardry",
				"item_vitality_booster",
				"item_ogre_axe",
				"item_mithril_hammer",
				"item_recipe_black_king_bar",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "obsidian_destroyer_arcane_orb";
local SKILL_W = "obsidian_destroyer_astral_imprisonment";
local SKILL_E = "obsidian_destroyer_essence_aura";
local SKILL_R = "obsidian_destroyer_sanity_eclipse";    


local ABILITY1 = "special_bonus_movement_speed_10"
local ABILITY2 = "special_bonus_mp_250"
local ABILITY3 = "special_bonus_attack_speed_20"
local ABILITY4 = "special_bonus_armor_5"
local ABILITY5 = "special_bonus_hp_275"
local ABILITY6 = "special_bonus_intelligence_15"
local ABILITY7 = "special_bonus_spell_amplify_8"
local ABILITY8 = "special_bonus_unique_outworld_devourer"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_E,    SKILL_W,
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_E,    talents[1],
    SKILL_R,    SKILL_E,    SKILL_R,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X