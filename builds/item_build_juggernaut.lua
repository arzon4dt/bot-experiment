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
				"item_boots",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_blade_of_alacrity",
				"item_blade_of_alacrity",
				"item_robe",
				"item_recipe_diffusal_blade",
				"item_blade_of_alacrity",
				"item_boots_of_elves",
				"item_recipe_yasha",
				"item_ultimate_orb",
				"item_recipe_manta",
				"item_recipe_diffusal_blade",
				"item_javelin",
				"item_belt_of_strength",
				"item_recipe_basher",
				"item_ring_of_health",
				"item_vitality_booster",
				"item_recipe_abyssal_blade",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion",
				"item_ultimate_orb",
				"item_ultimate_orb",
				"item_point_booster",
				"item_orb_of_venom"
			};

-- Set up Skill build
local SKILL_Q = "juggernaut_blade_fury";
local SKILL_W = "juggernaut_healing_ward";
local SKILL_E = "juggernaut_blade_dance";
local SKILL_R = "juggernaut_omni_slash";    


local ABILITY1 = "special_bonus_attack_damage_20"
local ABILITY2 = "special_bonus_hp_175"
local ABILITY3 = "special_bonus_armor_7"
local ABILITY4 = "special_bonus_attack_speed_20"
local ABILITY5 = "special_bonus_all_stats_8"
local ABILITY6 = "special_bonus_movement_speed_20"
local ABILITY7 = "special_bonus_unique_juggernaut"
local ABILITY8 = "special_bonus_agility_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_E,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_E,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[3],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X