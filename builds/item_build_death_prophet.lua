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
				"item_mantle",
				"item_recipe_null_talisman",
				"item_boots",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_helm_of_iron_will",
				"item_recipe_veil_of_discord",
				"item_wind_lace",
				"item_staff_of_wizardry",
				"item_void_stone",
				"item_recipe_cyclone",
				"item_staff_of_wizardry",
				"item_staff_of_wizardry",
				"item_vitality_booster",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard"
			};

-- Set up Skill build
local SKILL_Q = "death_prophet_carrion_swarm";
local SKILL_W = "death_prophet_silence";
local SKILL_E = "death_prophet_spirit_siphon";
local SKILL_R = "death_prophet_exorcism";    


local ABILITY1 = "special_bonus_magic_resistance_10"
local ABILITY2 = "special_bonus_spell_amplify_5"
local ABILITY3 = "special_bonus_cast_range_100"
local ABILITY4 = "special_bonus_unique_death_prophet_2"
local ABILITY5 = "special_bonus_movement_speed_50"
local ABILITY6 = "special_bonus_cooldown_reduction_10"
local ABILITY7 = "special_bonus_unique_death_prophet"
local ABILITY8 = "special_bonus_hp_600"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[1],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[5],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X