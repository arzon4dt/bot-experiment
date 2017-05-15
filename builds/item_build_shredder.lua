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
				"item_stout_shield",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_boots",
				"item_energy_booster",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_sobi_mask",
				"item_ring_of_regen",
				"item_recipe_soul_ring",
				"item_recipe_bloodstone",
				"item_ring_of_health",
				"item_void_stone",
				"item_platemail",
				"item_energy_booster",
				"item_platemail",
				"item_mystic_staff",
				"item_recipe_shivas_guard",
				"item_staff_of_wizardry",
				"item_staff_of_wizardry",
				"item_vitality_booster",
				"item_point_booster",
				"item_vitality_booster",
				"item_energy_booster",
				"item_mystic_staff"
			};

-- Set up Skill build
local SKILL_Q = "shredder_whirling_death";
local SKILL_W = "shredder_timber_chain";
local SKILL_E = "shredder_reactive_armor";
local SKILL_R = "shredder_chakram";   


local ABILITY1 = "special_bonus_exp_boost_20"
local ABILITY2 = "special_bonus_hp_150"
local ABILITY3 = "special_bonus_intelligence_20"
local ABILITY4 = "special_bonus_hp_regen_14"
local ABILITY5 = "special_bonus_cast_range_150"
local ABILITY6 = "special_bonus_spell_amplify_5"
local ABILITY7 = "special_bonus_strength_20"
local ABILITY8 = "special_bonus_unique_timbersaw"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_E,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_W,
    SKILL_R,    SKILL_W,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_Q,    SKILL_Q,    talents[3],
    SKILL_Q,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X