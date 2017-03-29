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
				"item_energy_booster",
				"item_blink",
				"item_point_booster",
				"item_ogre_axe",
				"item_blade_of_alacrity",
				"item_staff_of_wizardry",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"
			};

-- Set up Skill build
local SKILL_Q = "brewmaster_thunder_clap";
local SKILL_W = "brewmaster_drunken_haze";
local SKILL_E = "brewmaster_drunken_brawler";
local SKILL_R = "brewmaster_primal_split";    


local ABILITY1 = "special_bonus_mp_regen_3"
local ABILITY2 = "special_bonus_attack_speed_30"
local ABILITY3 = "special_bonus_magic_resistance_12"
local ABILITY4 = "special_bonus_unique_brewmaster_2"
local ABILITY5 = "special_bonus_strength_20"
local ABILITY6 = "special_bonus_respawn_reduction_35"
local ABILITY7 = "special_bonus_unique_brewmaster"
local ABILITY8 = "special_bonus_attack_damage_75"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_W,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X