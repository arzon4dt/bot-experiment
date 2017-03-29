-- generic database
----------------------------------------------------------------------------------------------------

local X = {}

----------------------------------------------------------------------------------------------------

-- ["carry"] will become more useful later in the game if they gain a significant gold advantage.
-- ["durable"] has the ability to last longer in teamfights.
-- ["support"] can focus less on amassing gold and items, and more on using their abilities to gain an advantage for the team.
-- ["escape"] has the ability to quickly avoid death.
-- ["nuker"] can quickly kill enemy heroes using high damage spells with low cooldowns.
-- ["pusher"] can quickly siege and destroy towers and barracks at all points of the game.
-- ["disabler"] has a guaranteed disable for one or more of their spells.
-- ["initiator"] good at starting a teamfight.
-- ["jungler"] can farm effectively from neutral creeps inside the jungle early in the game.

X["hero_roles"] = {
	["npc_dota_hero_abaddon"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_alchemist"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_axe"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_beastmaster"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_brewmaster"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_bristleback"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_centaur"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_chaos_knight"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_rattletrap"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_doom_bringer"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_dragon_knight"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_earth_spirit"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_earthshaker"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_elder_titan"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_huskar"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_wisp"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_kunkka"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_legion_commander"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_life_stealer"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_lycan"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_magnataur"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_night_stalker"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_omniknight"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_phoenix"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_pudge"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_sand_king"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_slardar"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_spirit_breaker"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_sven"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_tidehunter"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_shredder"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_tiny"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_treant"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_tusk"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_abyssal_underlord"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_undying"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_skeleton_king"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_antimage"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_arc_warden"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_bloodseeker"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_bounty_hunter"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_broodmother"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_clinkz"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_drow_ranger"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_ember_spirit"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_faceless_void"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_gyrocopter"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_juggernaut"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_lone_druid"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_luna"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_medusa"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_meepo"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_mirana"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_monkey_king"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_morphling"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_naga_siren"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_nyx_assassin"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_phantom_assassin"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_phantom_lancer"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_razor"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_riki"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_nevermore"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_slark"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_sniper"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_spectre"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_templar_assassin"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_terrorblade"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_troll_warlord"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_ursa"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_vengefulspirit"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_venomancer"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_viper"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_weaver"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_ancient_apparition"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_bane"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_batrider"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_chen"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_crystal_maiden"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_dark_seer"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_dazzle"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_death_prophet"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_disruptor"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_enchantress"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_enigma"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_invoker"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_jakiro"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_keeper_of_the_light"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_leshrac"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_lich"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_lina"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_lion"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_furion"] = {
		['midlaner'] = 0,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_necrolyte"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_ogre_magi"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 1
	},

	["npc_dota_hero_oracle"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_obsidian_destroyer"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_puck"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_pugna"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_queenofpain"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_rubick"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_shadow_demon"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_shadow_shaman"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_silencer"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_skywrath_mage"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_storm_spirit"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_techies"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_tinker"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 0,
		['support'] = 0
	},

	["npc_dota_hero_visage"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_warlock"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_windrunner"] = {
		['midlaner'] = 1,
		['carry'] = 1,
		['offlaner'] = 1,
		['support'] = 0
	},

	["npc_dota_hero_winter_wyvern"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_witch_doctor"] = {
		['midlaner'] = 0,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 1
	},

	["npc_dota_hero_zuus"] = {
		['midlaner'] = 1,
		['carry'] = 0,
		['offlaner'] = 0,
		['support'] = 0
	}
}

----------------------------------------------------------------------------------------------------

return X