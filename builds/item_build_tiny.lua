X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);
--[[ warning if meepo does not have an item other than 
brown boots / power treads at any time he will think he 
is a clone and skill/item decisions will break! ]]
X["items"] = { 
				--carry tiny
                "item_flask",
				"item_tango",
				"item_stout_shield",
				"item_bottle",
				"item_boots",
				"item_blades_of_attack",
				"item_blades_of_attack",
				"item_blink",
				"item_ogre_axe",
				"item_quarterstaff",
				"item_robe",
				"item_sobi_mask",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_hyperstone",
				"item_platemail",
				"item_chainmail",
				"item_recipe_assault",
				"item_eagle",
				"item_quarterstaff",
				"item_talisman_of_evasion"
				
				--nuker tiny
				--[["item_tango",
				"item_stout_shield",
				"item_bottle",
				"item_branches",
				"item_branches",
				"item_magic_stick",
				"item_circlet",
				"item_circlet",
				"item_mantle",
				"item_recipe_null_talisman",
				"item_boots",
				"item_energy_booster",
				"item_staff_of_wizardry",
				"item_recipe_dagon",
				"item_blink",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_recipe_dagon",
				"item_point_booster",
				"item_ogre_axe",
				"item_staff_of_wizardry",
				"item_blade_of_alacrity",
				"item_void_stone",
				"item_ultimate_orb",
				"item_mystic_staff",
				"item_vitality_booster",
				"item_reaver",
				"item_recipe_heart"]]--
			};

-- Set up Skill build
local SKILL_Q = "tiny_avalanche";
local SKILL_W = "tiny_toss";
local SKILL_E = "tiny_craggy_exterior";
local SKILL_R = "tiny_grow";    

local ABILITY1 = "special_bonus_intelligence_12"
local ABILITY2 = "special_bonus_strength_6"
local ABILITY3 = "special_bonus_movement_speed_35"
local ABILITY4 = "special_bonus_attack_damage_60"
local ABILITY5 = "special_bonus_mp_regen_14"
local ABILITY6 = "special_bonus_attack_speed_25"
local ABILITY7 = "special_bonus_unique_tiny"
local ABILITY8 = "special_bonus_cooldown_reduction_20"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_Q,    SKILL_W,    SKILL_Q,    SKILL_W,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_W,    SKILL_W,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_E,    SKILL_E,    talents[3],
    SKILL_E,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X