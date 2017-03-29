X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
                "item_tango",
				"item_bottle",
				"item_sobi_mask",
				"item_ring_of_regen",
				"item_recipe_soul_ring",
				"item_boots",
				"item_gloves",
				"item_belt_of_strength",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_quarterstaff",
				"item_sobi_mask",
				"item_robe",
				"item_recipe_orchid",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_recipe_bloodstone",
				"item_ring_of_health",
				"item_void_stone",
				"item_ultimate_orb",
				"item_recipe_sphere",
				"item_broadsword",
				"item_blades_of_attack",
				"item_recipe_lesser_crit",
				"item_recipe_bloodthorn",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "storm_spirit_static_remnant";
local SKILL_W = "storm_spirit_electric_vortex";
local SKILL_E = "storm_spirit_overload";
local SKILL_R = "storm_spirit_ball_lightning";    


local ABILITY1 = "special_bonus_mp_regen_3"
local ABILITY2 = "special_bonus_attack_damage_20"
local ABILITY3 = "special_bonus_intelligence_10"
local ABILITY4 = "special_bonus_hp_200"
local ABILITY5 = "special_bonus_armor_8"
local ABILITY6 = "special_bonus_attack_speed_40"
local ABILITY7 = "special_bonus_unique_storm_spirit"
local ABILITY8 = "special_bonus_spell_amplify_10"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_E,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_Q,    SKILL_Q,    talents[2],
    SKILL_Q,    SKILL_R,    SKILL_E,    SKILL_E,    talents[4],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[7]
};

return X