X = {}
local IBUtil = require(GetScriptDirectory() .. "/ItemBuildUtility");
local npcBot = GetBot();
local talents = IBUtil.FillTalenTable(npcBot);

X["items"] = {
"item_flask",
"item_tango",
"item_branches",--magic wand
"item_branches",--magic wand
"item_magic_stick",--magic wand
"item_stout_shield",  -- vangaurd
"item_circlet",--magic wand
"item_boots", -- phase boots
"item_blades_of_attack", -- phase boots
"item_blades_of_attack", -- phase boots
"item_robe",
"item_chainmail",
"item_broadsword",
"item_ring_of_regen", -- force staff
"item_staff_of_wizardry",-- force staff
"item_recipe_force_staff", -- force staff
"item_platemail",
"item_ring_of_health",
"item_void_stone",
"item_energy_booster",
"item_point_booster",-- aghs
"item_ogre_axe",-- aghs
"item_blade_of_alacrity", -- aghs
"item_staff_of_wizardry",-- aghs
"item_platemail",
"item_mystic_staff",
"item_recipe_shivas_guard"
}

-- Set up Skill build
local SKILL_Q = "rattletrap_battery_assault";
local SKILL_W = "rattletrap_power_cogs";
local SKILL_E = "rattletrap_rocket_flare";
local SKILL_R = "rattletrap_hookshot";    

local ABILITY1  = "special_bonus_armor_4"
local ABILITY2  = "special_bonus_mp_200"
local ABILITY3  = "special_bonus_attack_damage_50"
local ABILITY4  = "special_bonus_unique_clockwerk_2"
local ABILITY5  = "special_bonus_respawn_reduction_25"
local ABILITY6  = "special_bonus_magic_resistance_12"
local ABILITY7  = "special_bonus_hp_400"
local ABILITY8  = "special_bonus_unique_clockwerk"

--use -1 for levels that shouldn't level a skill
X["skills"] = {
    SKILL_W,    SKILL_E,    SKILL_Q,    SKILL_E,    SKILL_Q,
    SKILL_R,    SKILL_Q,    SKILL_E,    SKILL_Q,    talents[2],
    SKILL_E,    SKILL_R,    SKILL_W,    SKILL_W,    talents[4],
    SKILL_W,    "-1",       SKILL_R,    "-1",   	talents[6],
    "-1",   	"-1",   	"-1",       "-1",       talents[8]
};

return X