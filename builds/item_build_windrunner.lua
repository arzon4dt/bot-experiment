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
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_staff_of_wizardry",
				"item_ring_of_regen",
				"item_recipe_force_staff",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_boots_of_elves",
				"item_boots_of_elves",
				"item_ogre_axe",
				"item_recipe_hurricane_pike",
				"item_ring_of_health",
				"item_void_stone",
				"item_ultimate_orb",
				"item_recipe_sphere",
				"item_demon_edge",
				"item_javelin",
				"item_javelin"
			};

-- Set up Skill build
local SKILL_Q = "windrunner_shackleshot";
local SKILL_W = "windrunner_powershot";
local SKILL_E = "windrunner_windrun";
local SKILL_R = "windrunner_focusfire";    


local ABILITY1 = "special_bonus_mp_regen_4"
local ABILITY2 = "special_bonus_unique_windranger_2"
local ABILITY3 = "special_bonus_intelligence_20"
local ABILITY4 = "special_bonus_movement_speed_40"
local ABILITY5 = "special_bonus_magic_resistance_20"
local ABILITY6 = "special_bonus_spell_amplify_15"
local ABILITY7 = "special_bonus_unique_windranger"
local ABILITY8 = "special_bonus_attack_range_100"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X