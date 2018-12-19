local role = require(GetScriptDirectory() .. "/RoleUtility");
local heroStrength = {}; -- 1-3
local counters = {};
randomValues = {}

counters['npc_dota_hero_abaddon'] = { 'npc_dota_hero_slark', 'npc_dota_hero_undying' , 'npc_dota_hero_viper', 'npc_dota_hero_abyssal_underlord'}
heroStrength['npc_dota_hero_abaddon'] = 5

counters['npc_dota_hero_alchemist'] = { 'npc_dota_hero_bloodseeker', 'npc_dota_hero_huskar', 'npc_dota_hero_slark', 'npc_dota_hero_ursa', 'npc_dota_hero_dazzle', 'npc_dota_hero_ancient_apparition'}
heroStrength['npc_dota_hero_alchemist'] = 1

counters['npc_dota_hero_ancient_apparition'] = { 'npc_dota_hero_antimage', 'npc_dota_hero_brewmaster', 'npc_dota_hero_chaos_knight'}
heroStrength['npc_dota_hero_ancient_apparition'] = 2

counters['npc_dota_hero_arc_warden'] = {'npc_dota_hero_broodmother', 'npc_dota_hero_phantom_lancer',	'npc_dota_hero_lycan', 'npc_dota_hero_slark', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_antimage', 'npc_dota_hero_abaddon', 'npc_dota_hero_centaur', 'npc_dota_hero_brewmaster'}
heroStrength['npc_dota_hero_arc_warden'] = 3

counters['npc_dota_hero_antimage'] = {'npc_dota_hero_meepo', 'npc_dota_hero_phantom_assassin', 'npc_dota_hero_axe', 'npc_dota_hero_drow_ranger', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_luna', 'npc_dota_hero_spirit_breaker', 'npc_dota_hero_terrorblade'}
heroStrength['npc_dota_hero_antimage'] = 1

counters['npc_dota_hero_axe'] = {'npc_dota_hero_necrolyte', 'npc_dota_hero_zuus', 'npc_dota_hero_ursa', 'npc_dota_hero_jakiro', 'npc_dota_hero_warlock', 'npc_dota_hero_skeleton_king', 'npc_dota_hero_phoenix','npc_dota_hero_witch_doctor'}
heroStrength['npc_dota_hero_axe'] = 5

counters['npc_dota_hero_bane'] = {'npc_dota_hero_naga_siren', 'npc_dota_hero_leshrac', 'npc_dota_hero_meepo', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_winter_wyvern', 'npc_dota_hero_omniknight', 'npc_dota_hero_abyssal_underlord', 'npc_dota_hero_tidehunter', 'npc_dota_hero_spirit_breaker', 'npc_dota_hero_beastmaster'}
heroStrength['npc_dota_hero_bane'] = 2

counters['npc_dota_hero_batrider'] = {'npc_dota_hero_enigma', 'npc_dota_hero_leshrac', 'npc_dota_hero_abaddon', 'npc_dota_hero_slark', 'npc_dota_hero_omniknight', 'npc_dota_hero_clinkz', 'npc_dota_hero_warlock', 'npc_dota_hero_huskar',	'npc_dota_hero_vengefulspirit', 'npc_dota_hero_jakiro'}
heroStrength['npc_dota_hero_batrider'] = 1

counters['npc_dota_hero_beastmaster'] = {'npc_dota_hero_elder_titan', 'npc_dota_hero_winter_wyvern', 'npc_dota_hero_axe', 'npc_dota_hero_dark_seer', 'npc_dota_hero_abyssal_underlord', 'npc_dota_hero_terrorblade', 'npc_dota_hero_jakiro', 'npc_dota_hero_spectre', 'npc_dota_hero_warlock', 'npc_dota_hero_tidehunter', 'npc_dota_hero_necrolyte'}
heroStrength['npc_dota_hero_beastmaster'] = 2

counters['npc_dota_hero_bloodseeker'] = {'npc_dota_hero_storm_spirit','npc_dota_hero_pudge', 'npc_dota_hero_zuus','npc_dota_hero_brewmaster', 'npc_dota_hero_axe', 'npc_dota_hero_ursa'}
heroStrength['npc_dota_hero_bloodseeker'] = 5

counters['npc_dota_hero_bounty_hunter'] = {'npc_dota_hero_slardar', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_meepo', 'npc_dota_hero_slark', 'npc_dota_hero_oracle', 'npc_dota_hero_huskar', 'npc_dota_hero_crystal_maiden', 'npc_dota_hero_luna'}
heroStrength['npc_dota_hero_bounty_hunter'] = 1

counters['npc_dota_hero_brewmaster'] = {'npc_dota_hero_sand_king', 'npc_dota_hero_luna', 'npc_dota_hero_skywrath_mage', 'npc_dota_hero_faceless_void', 'npc_dota_hero_magnataur', 'npc_dota_hero_leshrac'}
heroStrength['npc_dota_hero_brewmaster'] = -5 -- during teamfights this hero becomes ineffective

counters['npc_dota_hero_bristleback'] = {'npc_dota_hero_slark', 'npc_dota_hero_viper', 'npc_dota_hero_necrolyte', 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_legion_commander', 'npc_dota_hero_silencer', 'npc_dota_hero_dazzle', 'npc_dota_hero_slardar'}
heroStrength['npc_dota_hero_bristleback'] = 5

counters['npc_dota_hero_broodmother'] = {'npc_dota_hero_earthshaker', 'npc_dota_hero_meepo', 'npc_dota_hero_kunkka', 'npc_dota_hero_monkey_king', 'npc_dota_hero_legion_commander','npc_dota_hero_sven', 'npc_dota_hero_axe', 'npc_dota_hero_magnataur', 'npc_dota_hero_leshrac', 'npc_dota_hero_crystal_maiden', 'npc_dota_hero_tidehunter', 'npc_dota_hero_sand_king', 'npc_dota_hero_necrolyte', 'npc_dota_hero_bristleback'}
heroStrength['npc_dota_hero_broodmother'] = 3

counters['npc_dota_hero_huskar'] = {'npc_dota_hero_axe', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_viper', 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_riki', 'npc_dota_hero_clinkz', 'npc_dota_hero_broodmother', 'npc_dota_hero_bristleback', 'npc_dota_hero_ursa', 'npc_dota_hero_necrolyte', 'npc_dota_hero_witch_doctor'}
heroStrength['npc_dota_hero_huskar'] = 3

counters['npc_dota_hero_necrolyte'] = {'npc_dota_hero_pugna', 'npc_dota_hero_drow_ranger', 'npc_dota_hero_sniper', 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_skywrath_mage'}
heroStrength['npc_dota_hero_necrolyte'] = 7

counters['npc_dota_hero_jakiro'] = {'npc_dota_hero_life_stealer', 'npc_dota_hero_clinkz', 'npc_dota_hero_sniper', 'npc_dota_hero_alchemist', 'npc_dota_hero_antimage', 'npc_dota_hero_elder_titan', 'npc_dota_hero_silencer', 'npc_dota_hero_bloodseeker'}
heroStrength['npc_dota_hero_jakiro'] = 7

counters['npc_dota_hero_warlock'] = {'npc_dota_hero_drow_ranger', 'npc_dota_hero_broodmother', 'npc_dota_hero_huskar', 'npc_dota_hero_bristleback', 'npc_dota_hero_slark', 'npc_dota_hero_lich', 'npc_dota_hero_ursa', 'npc_dota_hero_riki'}
heroStrength['npc_dota_hero_warlock'] = 4

counters['npc_dota_hero_lich'] = {'npc_dota_hero_sand_king', 'npc_dota_hero_slark', 'npc_dota_hero_antimage'}
heroStrength['npc_dota_hero_lich'] = 5

counters['npc_dota_hero_chaos_knight'] = {'npc_dota_hero_sven', 'npc_dota_hero_enigma', 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_shredder',	'npc_dota_hero_warlock', 'npc_dota_hero_undying','npc_dota_hero_earthshaker', 'npc_dota_hero_brewmaster','npc_dota_hero_witch_doctor', 'npc_dota_hero_abyssal_underlord', 'npc_dota_hero_phoenix', 'npc_dota_hero_tidehunter'}
heroStrength['npc_dota_hero_chaos_knight'] = 3

counters['npc_dota_hero_slardar'] = {'npc_dota_hero_terrorblade', 'npc_dota_hero_luna', 'npc_dota_hero_tidehunter', 'npc_dota_hero_omniknight', 'npc_dota_hero_jakiro'}
heroStrength['npc_dota_hero_slardar'] = 4

counters['npc_dota_hero_sven'] = {'npc_dota_hero_spectre', 'npc_dota_hero_phoenix', 'npc_dota_hero_medusa', 'npc_dota_hero_undying', 'npc_dota_hero_razor', 'npc_dota_hero_sniper', 'npc_dota_hero_abaddon', 'npc_dota_hero_treant','npc_dota_hero_witch_doctor'}
heroStrength['npc_dota_hero_sven'] = 2

counters['npc_dota_hero_venomancer'] = {'npc_dota_hero_huskar', 'npc_dota_hero_broodmother', 'npc_dota_hero_arc_warden', 'npc_dota_hero_antimage', 'npc_dota_hero_pudge', 'npc_dota_hero_lycan', 'npc_dota_hero_warlock', 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_abaddon', 'npc_dota_hero_juggernaut', 'npc_dota_hero_slark'}
heroStrength['npc_dota_hero_venomancer'] = 3

counters['npc_dota_hero_sniper'] = {'npc_dota_hero_storm_spirit','npc_dota_hero_pudge','npc_dota_hero_morphling', 'npc_dota_hero_spectre', 'npc_dota_hero_centaur', 'npc_dota_hero_phantom_assassin', 'npc_dota_hero_spirit_breaker'}
heroStrength['npc_dota_hero_sniper'] = 5

counters['npc_dota_hero_drow_ranger'] = {'npc_dota_hero_spectre', 'npc_dota_hero_centaur', 'npc_dota_hero_phantom_assassin', 'npc_dota_hero_spirit_breaker', 'npc_dota_hero_slark', 'npc_dota_hero_pudge', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_axe', 'npc_dota_hero_riki', 'npc_dota_hero_bounty_hunter', 'npc_dota_hero_broodmother'}
heroStrength['npc_dota_hero_drow_ranger'] = 2

counters['npc_dota_hero_riki'] = {'npc_dota_hero_slardar', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_zuus', 'npc_dota_hero_bounty_hunter'}
heroStrength['npc_dota_hero_riki'] = 2

counters['npc_dota_hero_nevermore'] = {'npc_dota_hero_zuus', 'npc_dota_hero_arc_warden', 'npc_dota_hero_terrorblade', 'npc_dota_hero_pudge', 'npc_dota_hero_ursa', 'npc_dota_hero_axe', 'npc_dota_hero_skywrath_mage', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_spirit_breaker'}
heroStrength['npc_dota_hero_nevermore'] = 2

counters['npc_dota_hero_zuus'] = {'npc_dota_hero_broodmother', 'npc_dota_hero_antimage', 'npc_dota_hero_huskar', 'npc_dota_hero_lycan'}
heroStrength['npc_dota_hero_zuus'] = 2

counters['npc_dota_hero_viper'] = {'npc_dota_hero_terrorblade', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_riki', 'npc_dota_hero_clinkz', 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_juggernaut', 'npc_dota_hero_brewmaster','npc_dota_hero_furion','npc_dota_hero_bloodseeker','npc_dota_hero_naga_siren','npc_dota_hero_morphling','npc_dota_hero_drow_ranger','npc_dota_hero_broodmother'}
heroStrength['npc_dota_hero_viper'] = 3

counters['npc_dota_hero_phantom_lancer'] = {'npc_dota_hero_axe', 'npc_dota_hero_sven', 'npc_dota_hero_earthshaker', 'npc_dota_hero_sand_king', 'npc_dota_hero_ember_spirit', 'npc_dota_hero_shredder', 'npc_dota_hero_jakiro', 'npc_dota_hero_legion_commander', 'npc_dota_hero_centaur', 'npc_dota_hero_crystal_maiden'}
heroStrength['npc_dota_hero_phantom_lancer'] = -10 -- hero is buggy, sometimes just stucks at the fountain

counters['npc_dota_hero_centaur'] = {'npc_dota_hero_dazzle', 'npc_dota_hero_undying', 'npc_dota_hero_warlock', 'npc_dota_hero_lycan', 'npc_dota_hero_witch_doctor', 'npc_dota_hero_abyssal_underlord', 'npc_dota_hero_bristleback'}
heroStrength['npc_dota_hero_centaur'] = 3

counters['npc_dota_hero_chen'] = {'npc_dota_hero_lycan', 'npc_dota_hero_leshrac', 'npc_dota_hero_lone_druid', 'npc_dota_hero_oracle', 'npc_dota_hero_naga_siren', 'npc_dota_hero_slark', 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_medusa', 'npc_dota_hero_faceless_void', 'npc_dota_hero_skywrath_mage'}
heroStrength['npc_dota_hero_chen'] = 1

counters['npc_dota_hero_clinkz'] = {'npc_dota_hero_meepo', 'npc_dota_hero_slark', 'npc_dota_hero_phantom_assassin', 'npc_dota_hero_abaddon', 'npc_dota_hero_bounty_hunter', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_naga_siren', 'npc_dota_hero_zuus', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_spirit_breaker', 'npc_dota_hero_legion_commander', 'npc_dota_hero_morphling', 'npc_dota_hero_spectre', 'npc_dota_hero_dragon_knight', 'npc_dota_hero_bristleback', 'npc_dota_hero_phantom_lancer'}
heroStrength['npc_dota_hero_clinkz'] = 3

counters['npc_dota_hero_rattletrap'] = {'npc_dota_hero_broodmother', 'npc_dota_hero_antimage', 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_huskar', 'npc_dota_hero_visage', 'npc_dota_hero_chaos_knight', 'npc_dota_hero_phoenix', 'npc_dota_hero_ember_spirit', 'npc_dota_hero_undying',	'npc_dota_hero_juggernaut',}
heroStrength['npc_dota_hero_rattletrap'] = 1

counters['npc_dota_hero_crystal_maiden'] = {'npc_dota_hero_bristleback',	'npc_dota_hero_pudge', 	'npc_dota_hero_zuus', 'npc_dota_hero_phoenix', 'npc_dota_hero_centaur', 'npc_dota_hero_undying', 'npc_dota_hero_axe', 'npc_dota_hero_silencer','npc_dota_hero_witch_doctor'}
heroStrength['npc_dota_hero_crystal_maiden'] = 2

counters['npc_dota_hero_ember_spirit'] = { 'npc_dota_hero_huskar',	'npc_dota_hero_drow_ranger', 'npc_dota_hero_slark', 'npc_dota_hero_dazzle', 'npc_dota_hero_juggernaut', 'npc_dota_hero_viper', 'npc_dota_hero_ursa', 'npc_dota_hero_sven', 'npc_dota_hero_clinkz', 'npc_dota_hero_oracle', 'npc_dota_hero_legion_commander', 'npc_dota_hero_shadow_shaman', 'npc_dota_hero_skywrath_mage', 'npc_dota_hero_faceless_void', 'npc_dota_hero_troll_warlord'}
heroStrength['npc_dota_hero_ember_spirit'] = 0

counters['npc_dota_hero_riki'] = { 'npc_dota_hero_ogre_magi', 'npc_dota_hero_bounty_hunter', 'npc_dota_hero_bristleback', 'npc_dota_hero_abyssal_underlord', 'npc_dota_hero_slardar', 'npc_dota_hero_zuus', 'npc_dota_hero_centaur', 'npc_dota_hero_axe', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_dazzle', 'npc_dota_hero_abaddon', 'npc_dota_hero_treant'}
heroStrength['npc_dota_hero_riki'] = 3

counters['npc_dota_hero_skywrath_mage'] = { 'npc_dota_hero_chaos_knight','npc_dota_hero_pugna','npc_dota_hero_templar_assassin','npc_dota_hero_lycan', 'npc_dota_hero_skeleton_king', 'npc_dota_hero_antimage', 'npc_dota_hero_bristleback', 'npc_dota_hero_tidehunter', 'npc_dota_hero_broodmother', 'npc_dota_hero_phantom_lancer'}
heroStrength['npc_dota_hero_skywrath_mage'] = 2

counters['npc_dota_hero_dark_seer'] = {'npc_dota_hero_ursa', 'npc_dota_hero_crystal_maiden', 'npc_dota_hero_enigma', 'npc_dota_hero_spirit_breaker', 'npc_dota_hero_zuus', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_antimage', 'npc_dota_hero_earthshaker', 'npc_dota_hero_clinkz', 'npc_dota_hero_sniper', 'npc_dota_hero_legion_commander', 'npc_dota_hero_kunkka', 'npc_dota_hero_faceless_void'}
heroStrength['npc_dota_hero_dark_seer'] = 1

counters['npc_dota_hero_dark_willow'] = {'npc_dota_hero_phantom_lancer','npc_dota_hero_venomancer','npc_dota_hero_arc_warden','npc_dota_hero_clinkz','npc_dota_hero_axe','npc_dota_hero_broodmother',
	'npc_dota_hero_antimage','npc_dota_hero_bloodseeker','npc_dota_hero_zuus', 'npc_dota_hero_juggernaut','npc_dota_hero_centaur','npc_dota_hero_pugna', 'npc_dota_hero_jakiro'}
heroStrength['npc_dota_hero_dark_willow'] = 1

counters['npc_dota_hero_dazzle'] = {'npc_dota_hero_luna','npc_dota_hero_ancient_apparition','npc_dota_hero_silencer','npc_dota_hero_grimstroke','npc_dota_hero_faceless_void','npc_dota_hero_magnataur','npc_dota_hero_venomancer','npc_dota_hero_viper','npc_dota_hero_obsidian_destroyer','npc_dota_hero_shadow_demon'}
heroStrength['npc_dota_hero_dazzle'] = 3

counters['npc_dota_hero_death_prophet'] = {'npc_dota_hero_medusa','npc_dota_hero_sniper', 'npc_dota_hero_luna','npc_dota_hero_mirana','npc_dota_hero_vengefulspirit','npc_dota_hero_undying','npc_dota_hero_ancient_apparition','npc_dota_hero_abyssal_underlord','npc_dota_hero_slark', 'npc_dota_hero_dazzle'}
heroStrength['npc_dota_hero_death_prophet'] = 1

counters['npc_dota_hero_disruptor'] = {'npc_dota_hero_warlock','npc_dota_hero_phantom_assassin','npc_dota_hero_oracle','npc_dota_hero_chaos_knight','npc_dota_hero_elder_titan','npc_dota_hero_huskar','npc_dota_hero_viper','npc_dota_hero_abaddon','npc_dota_hero_abyssal_underlord','npc_dota_hero_broodmother','npc_dota_hero_spirit_breaker'}
heroStrength['npc_dota_hero_disruptor'] = 1

counters['npc_dota_hero_doom_bringer'] = {'npc_dota_hero_meepo','npc_dota_hero_antimage','npc_dota_hero_huskar','npc_dota_hero_chaos_knight','npc_dota_hero_bloodseeker','npc_dota_hero_slardar','npc_dota_hero_dazzle'}
heroStrength['npc_dota_hero_doom_bringer'] = 2

counters['npc_dota_hero_earth_spirit'] = {'npc_dota_hero_death_prophet','npc_dota_hero_lycan','npc_dota_hero_leshrac','npc_dota_hero_enchantress','npc_dota_hero_life_stealer','npc_dota_hero_weaver','npc_dota_hero_bloodseeker','npc_dota_hero_clinkz','npc_dota_hero_sven','npc_dota_hero_viper','npc_dota_hero_elder_titan','npc_dota_hero_faceless_void','npc_dota_hero_huskar','npc_dota_hero_slark','npc_dota_hero_centaur','npc_dota_hero_kunkka','npc_dota_hero_juggernaut','npc_dota_hero_slardar','npc_dota_hero_ursa','npc_dota_hero_omniknight','npc_dota_hero_antimage','npc_dota_hero_necrolyte','npc_dota_hero_medusa'}
heroStrength['npc_dota_hero_earth_spirit'] = 1

counters['npc_dota_hero_earthshaker'] = {'npc_dota_hero_life_stealer','npc_dota_hero_spectre','npc_dota_hero_viper','npc_dota_hero_templar_assassin','npc_dota_hero_rattletrap', 'npc_dota_hero_sniper','npc_dota_hero_venomancer','npc_dota_hero_monkey_king','npc_dota_hero_night_stalker','npc_dota_hero_zuus','npc_dota_hero_riki',}
heroStrength['npc_dota_hero_earthshaker'] = 2

counters['npc_dota_hero_luna'] = { 'npc_dota_hero_bristleback', 'npc_dota_hero_shadow_demon', 'npc_dota_hero_dark_seer','npc_dota_hero_rattletrap','npc_dota_hero_abyssal_underlord', 'npc_dota_hero_sand_king','npc_dota_hero_spirit_breaker'}
heroStrength['npc_dota_hero_luna'] = 2

counters['npc_dota_hero_juggernaut'] = { 'npc_dota_hero_morphling', 'npc_dota_hero_antimage', 'npc_dota_hero_night_stalker', 'npc_dota_hero_axe', 'npc_dota_hero_ursa', 'npc_dota_hero_faceless_void', 'npc_dota_hero_sven', 'npc_dota_hero_dragon_knight', 'npc_dota_hero_drow_ranger', 'npc_dota_hero_sniper'}
heroStrength['npc_dota_hero_juggernaut'] = 2

counters['npc_dota_hero_tidehunter'] = { 'npc_dota_hero_huskar', 'npc_dota_hero_bloodseeker', 'npc_dota_hero_slark', 'npc_dota_hero_necrolyte', 'npc_dota_hero_undying', 'npc_dota_hero_juggernaut', 'npc_dota_hero_antimage', 	'npc_dota_hero_ursa','npc_dota_hero_abyssal_underlord'}
heroStrength['npc_dota_hero_tidehunter'] = 3

counters['npc_dota_hero_ursa'] = { 'npc_dota_hero_phantom_lancer', 'npc_dota_hero_venomancer', 'npc_dota_hero_naga_siren', 'npc_dota_hero_brewmaster', 'npc_dota_hero_sand_king', 'npc_dota_hero_lich', 'npc_dota_hero_visage', 'npc_dota_hero_slark',	'npc_dota_hero_chaos_knight'}
heroStrength['npc_dota_hero_ursa'] = 3

counters['npc_dota_hero_troll_warlord'] = {'npc_dota_hero_tinker','npc_dota_hero_batrider','npc_dota_hero_pugna','npc_dota_hero_axe','npc_dota_hero_razor','npc_dota_hero_shadow_demon','npc_dota_hero_lion','npc_dota_hero_abaddon','npc_dota_hero_brewmaster','npc_dota_hero_luna','npc_dota_hero_lich','npc_dota_hero_phoenix','npc_dota_hero_abyssal_underlord', 'npc_dota_hero_sand_king','npc_dota_hero_slark'}
heroStrength['npc_dota_hero_troll_warlord'] = 1

counters['npc_dota_hero_grimstroke'] = {'npc_dota_hero_sniper','npc_dota_hero_lycan','npc_dota_hero_clinkz','npc_dota_hero_bloodseeker','npc_dota_hero_huskar','npc_dota_hero_spectre', 'npc_dota_hero_chaos_knight','npc_dota_hero_antimage','npc_dota_hero_elder_titan'}
heroStrength['npc_dota_hero_grimstroke'] = 1

counters['npc_dota_hero_dragon_knight'] = {'npc_dota_hero_slark','npc_dota_hero_meepo','npc_dota_hero_necrolyte','npc_dota_hero_shredder','npc_dota_hero_huskar','npc_dota_hero_obsidian_destroyer','npc_dota_hero_abyssal_underlord', 'npc_dota_hero_viper','npc_dota_hero_undying','npc_dota_hero_enigma','npc_dota_hero_lich','npc_dota_hero_razor','npc_dota_hero_phoenix','npc_dota_hero_warlock','npc_dota_hero_ancient_apparition', 'npc_dota_hero_dazzle','npc_dota_hero_beastmaster', 'npc_dota_hero_tidehunter', 'npc_dota_hero_luna', 'npc_dota_hero_bloodseeker','npc_dota_hero_witch_doctor','npc_dota_hero_omniknight','npc_dota_hero_drow_ranger','npc_dota_hero_sniper'}
heroStrength['npc_dota_hero_dragon_knight'] = 1

counters['npc_dota_hero_slark'] = {'npc_dota_hero_necrolyte','npc_dota_hero_bloodseeker', 'npc_dota_hero_sand_king', 'npc_dota_hero_earthshaker','npc_dota_hero_faceless_void','npc_dota_hero_lion','npc_dota_hero_grimstroke','npc_dota_hero_omniknight','npc_dota_hero_disruptor','npc_dota_hero_ancient_apparition','npc_dota_hero_huskar','npc_dota_hero_pugna', 'npc_dota_hero_centaur','npc_dota_hero_techies'}
heroStrength['npc_dota_hero_slark'] = -5

counters['npc_dota_hero_razor'] = {'npc_dota_hero_gyrocopter','npc_dota_hero_bristleback','npc_dota_hero_morphling','npc_dota_hero_sniper','npc_dota_hero_bloodseeker','npc_dota_hero_terrorblade','npc_dota_hero_enigma', 'npc_dota_hero_witch_doctor','npc_dota_hero_chaos_knight','npc_dota_hero_antimage','npc_dota_hero_skywrath_mage','npc_dota_hero_luna'}
heroStrength['npc_dota_hero_razor'] = 1

counters['npc_dota_hero_pudge'] = {'npc_dota_hero_undying','npc_dota_hero_dazzle','npc_dota_hero_chaos_knight','npc_dota_hero_ursa', 'npc_dota_hero_skeleton_king','npc_dota_hero_slardar','npc_dota_hero_lycan','npc_dota_hero_antimage','npc_dota_hero_witch_doctor','npc_dota_hero_sven','npc_dota_hero_kunkka','npc_dota_hero_bristleback','npc_dota_hero_life_stealer','npc_dota_hero_lone_druid','npc_dota_hero_weaver','npc_dota_hero_chen','npc_dota_hero_phantom_lancer','npc_dota_hero_treant','npc_dota_hero_broodmother','npc_dota_hero_weaver'}
heroStrength['npc_dota_hero_pudge'] = 1

counters['npc_dota_hero_treant'] = {'npc_dota_hero_slark', 'npc_dota_hero_undying', 'npc_dota_hero_dazzle','npc_dota_hero_ursa','npc_dota_hero_necrolyte', 'npc_dota_hero_tidehunter','npc_dota_hero_huskar','npc_dota_hero_slardar','npc_dota_hero_shredder','npc_dota_hero_broodmother','npc_dota_hero_phantom_lancer','npc_dota_hero_juggernaut','npc_dota_hero_dark_seer','npc_dota_hero_terrorblade','npc_dota_hero_batrider','npc_dota_hero_shadow_demon'}
heroStrength['npc_dota_hero_treant'] = 2

counters['npc_dota_hero_spectre'] = {'npc_dota_hero_undying','npc_dota_hero_dazzle','npc_dota_hero_chen','npc_dota_hero_life_stealer','npc_dota_hero_antimage','npc_dota_hero_broodmother','npc_dota_hero_treant','npc_dota_hero_necrolyte','npc_dota_hero_alchemist','npc_dota_hero_viper','npc_dota_hero_juggernaut','npc_dota_hero_centaur', 'npc_dota_hero_huskar','npc_dota_hero_lycan','npc_dota_hero_abaddon','npc_dota_hero_witch_doctor'}
heroStrength['npc_dota_hero_spectre'] = 3

counters['npc_dota_hero_meepo'] = {'npc_dota_hero_leshrac','npc_dota_hero_elder_titan', 'npc_dota_hero_earthshaker','npc_dota_hero_winter_wyvern','npc_dota_hero_shredder','npc_dota_hero_jakiro','npc_dota_hero_sven', 'npc_dota_hero_lich','npc_dota_hero_sand_king','npc_dota_hero_warlock','npc_dota_hero_venomancer','npc_dota_hero_crystal_maiden'}
heroStrength['npc_dota_hero_meepo'] = 1

counters['npc_dota_hero_phantom_assassin'] = {'npc_dota_hero_shredder','npc_dota_hero_morphling','npc_dota_hero_tinker','npc_dota_hero_razor','npc_dota_hero_troll_warlord', 'npc_dota_hero_omniknight','npc_dota_hero_dragon_knight','npc_dota_hero_meepo','npc_dota_hero_axe'}
heroStrength['npc_dota_hero_phantom_assassin'] = 3

counters['npc_dota_hero_terrorblade'] = {'npc_dota_hero_shredder','npc_dota_hero_zuus','npc_dota_hero_tinker','npc_dota_hero_axe','npc_dota_hero_ember_spirit','npc_dota_hero_phantom_lancer','npc_dota_hero_dark_seer','npc_dota_hero_warlock','npc_dota_hero_sand_king', 'npc_dota_hero_lich','npc_dota_hero_slark','npc_dota_hero_gyrocopter'}
heroStrength['npc_dota_hero_terrorblade'] = 2

counters['npc_dota_hero_shredder'] = {'npc_dota_hero_pugna','npc_dota_hero_bloodseeker','npc_dota_hero_ursa','npc_dota_hero_skywrath_mage', 'npc_dota_hero_drow_ranger','npc_dota_hero_silencer','npc_dota_hero_necrolyte','npc_dota_hero_pudge','npc_dota_hero_doom_bringer','npc_dota_hero_faceless_void', 'npc_dota_hero_luna', 'npc_dota_hero_ancient_apparition','npc_dota_hero_obsidian_destroyer','npc_dota_hero_death_prophet'}
heroStrength['npc_dota_hero_shredder'] = 2

counters['npc_dota_hero_omniknight'] = {'npc_dota_hero_enigma', 'npc_dota_hero_necrolyte', 'npc_dota_hero_obsidian_destroyer','npc_dota_hero_ancient_apparition','npc_dota_hero_luna','npc_dota_hero_lich','npc_dota_hero_abyssal_underlord','npc_dota_hero_faceless_void','npc_dota_hero_undying','npc_dota_hero_grimstroke','npc_dota_hero_huskar', 'npc_dota_hero_skywrath_mage','npc_dota_hero_sand_king','npc_dota_hero_meepo', 'npc_dota_hero_shredder'}
heroStrength['npc_dota_hero_omniknight'] = 3

counters['npc_dota_hero_spirit_breaker'] = {'npc_dota_hero_necrolyte', 'npc_dota_hero_abyssal_underlord','npc_dota_hero_undying','npc_dota_hero_meepo'}
heroStrength['npc_dota_hero_spirit_breaker'] = 0

counters['npc_dota_hero_gyrocopter'] = {'npc_dota_hero_spectre', 'npc_dota_hero_warlock','npc_dota_hero_juggernaut','npc_dota_hero_abaddon','npc_dota_hero_antimage','npc_dota_hero_skeleton_king','npc_dota_hero_doom_bringer','npc_dota_hero_tidehunter','npc_dota_hero_bristleback','npc_dota_hero_zuus','npc_dota_hero_tinker','npc_dota_hero_clinkz','npc_dota_hero_arc_warden','npc_dota_hero_pudge','npc_dota_hero_sniper','npc_dota_hero_omniknight','npc_dota_hero_life_stealer'}
heroStrength['npc_dota_hero_gyrocopter'] = 2

counters['npc_dota_hero_lycan'] = {'npc_dota_hero_naga_siren','npc_dota_hero_bristleback','npc_dota_hero_bloodseeker','npc_dota_hero_sven','npc_dota_hero_troll_warlord', 'npc_dota_hero_phantom_assassin','npc_dota_hero_gyrocopter','npc_dota_hero_kunkka','npc_dota_hero_shredder','npc_dota_hero_slardar','npc_dota_hero_axe','npc_dota_hero_dazzle','npc_dota_hero_earthshaker','npc_dota_hero_tidehunter','npc_dota_hero_meepo','npc_dota_hero_abyssal_underlord','npc_dota_hero_terrorblade','npc_dota_hero_vengefulspirit','npc_dota_hero_crystal_maiden','npc_dota_hero_jakiro'}
heroStrength['npc_dota_hero_lycan'] = 2

counters['npc_dota_hero_magnataur'] = {'npc_dota_hero_clinkz','npc_dota_hero_bloodseeker','npc_dota_hero_huskar','npc_dota_hero_sniper','npc_dota_hero_doom_bringer'}
heroStrength['npc_dota_hero_magnataur'] = 2

counters['npc_dota_hero_medusa'] = {'npc_dota_hero_broodmother','npc_dota_hero_sniper','npc_dota_hero_antimage','npc_dota_hero_clinkz','npc_dota_hero_nyx_assassin','npc_dota_hero_huskar','npc_dota_hero_terrorblade','npc_dota_hero_riki','npc_dota_hero_ursa','npc_dota_hero_jakiro'}
heroStrength['npc_dota_hero_medusa'] = 2

counters['npc_dota_hero_witch_doctor'] = {'npc_dota_hero_morphling','npc_dota_hero_phantom_assassin','npc_dota_hero_phantom_lancer','npc_dota_hero_clinkz','npc_dota_hero_furion','npc_dota_hero_riki','npc_dota_hero_brewmaster','npc_dota_hero_juggernaut','npc_dota_hero_slark','npc_dota_hero_drow_ranger','npc_dota_hero_silencer','npc_dota_hero_warlock'}
heroStrength['npc_dota_hero_witch_doctor'] = 0

counters['npc_dota_hero_elder_titan'] = {'npc_dota_hero_clinkz','npc_dota_hero_life_stealer','npc_dota_hero_juggernaut','npc_dota_hero_sniper','npc_dota_hero_huskar','npc_dota_hero_dark_seer','npc_dota_hero_skywrath_mage','npc_dota_hero_phantom_assassin'}
heroStrength['npc_dota_hero_elder_titan'] = 2

counters['npc_dota_hero_silencer'] = {'npc_dota_hero_broodmother','npc_dota_hero_naga_siren','npc_dota_hero_abaddon','npc_dota_hero_phantom_lancer','npc_dota_hero_huskar','npc_dota_hero_lycan','npc_dota_hero_arc_warden','npc_dota_hero_slark','npc_dota_hero_luna','npc_dota_hero_meepo','npc_dota_hero_tidehunter','npc_dota_hero_chaos_knight','npc_dota_hero_juggernaut','npc_dota_hero_spirit_breaker','npc_dota_hero_bloodseeker','npc_dota_hero_skeleton_king','npc_dota_hero_drow_ranger','npc_dota_hero_sniper','npc_dota_hero_brewmaster'}
heroStrength['npc_dota_hero_silencer'] = 3

counters['npc_dota_hero_enchantress'] = {'npc_dota_hero_naga_siren','npc_dota_hero_phantom_assassin','npc_dota_hero_pudge','npc_dota_hero_morphling','npc_dota_hero_phantom_lancer','npc_dota_hero_batrider','npc_dota_hero_bristleback','npc_dota_hero_crystal_maiden','npc_dota_hero_pugna','npc_dota_hero_furion','npc_dota_hero_ursa','npc_dota_hero_tinker','npc_dota_hero_windrunner','npc_dota_hero_alchemist','npc_dota_hero_techies','npc_dota_hero_nevermore','npc_dota_hero_troll_warlord','npc_dota_hero_skywrath_mage','npc_dota_hero_shadow_shaman','npc_dota_hero_luna','npc_dota_hero_lion','npc_dota_hero_dazzle','npc_dota_hero_zuus'}
heroStrength['npc_dota_hero_enchantress'] = 1

counters['npc_dota_hero_enigma'] = {'npc_dota_hero_sniper','npc_dota_hero_spectre','npc_dota_hero_medusa','npc_dota_hero_clinkz','npc_dota_hero_riki','npc_dota_hero_death_prophet','npc_dota_hero_warlock','npc_dota_hero_rubick','npc_dota_hero_morphling','npc_dota_hero_bristleback','npc_dota_hero_silencer','npc_dota_hero_juggernaut','npc_dota_hero_abaddon','npc_dota_hero_skeleton_king','npc_dota_hero_phantom_assassin','npc_dota_hero_winter_wyvern','npc_dota_hero_drow_ranger','npc_dota_hero_kunkka','npc_dota_hero_jakiro','npc_dota_hero_skywrath_mage'}
heroStrength['npc_dota_hero_enigma'] = -1 

counters['npc_dota_hero_phoenix'] = {'npc_dota_hero_drow_ranger','npc_dota_hero_clinkz','npc_dota_hero_juggernaut','npc_dota_hero_huskar','npc_dota_hero_skywrath_mage','npc_dota_hero_silencer','npc_dota_hero_bloodseeker','npc_dota_hero_tidehunter','npc_dota_hero_oracle','npc_dota_hero_antimage'}
heroStrength['npc_dota_hero_phoenix'] = -1


counters['npc_dota_hero_undying'] = {'npc_dota_hero_medusa','npc_dota_hero_clinkz','npc_dota_hero_broodmother','npc_dota_hero_antimage','npc_dota_hero_drow_ranger','npc_dota_hero_weaver','npc_dota_hero_pangolier','npc_dota_hero_sniper',}
heroStrength[''] = 2


--[[



	'npc_dota_hero_riki',
	'npc_dota_hero_lycan',
	'npc_dota_hero_clinkz',


counters[''] = {}
heroStrength[''] = 1

counters[''] = {}
heroStrength[''] = 1]]--



function GetHeroStrength(heroName, enemies)
	local score = 0;

	if heroStrength[heroName] ~= nil then
	score = heroStrength[heroName];
	end

	-- am I countered?
	if counters[heroName] ~= nil then
	for i, enemyName in pairs(enemies) do
		for ci, cname in pairs(counters[heroName]) do
			if cname == enemyName then score = score - 1 - role.GetRoleLevel(enemyName, 'carry') - role.GetRoleLevel(heroName, 'carry') end
		end
	end
	end
	
	-- am I counter them?
	for i, enemyName in pairs(enemies) do
	if counters[enemyName] ~= nil then
		 for ci, cname in pairs(counters[enemyName]) do
		if cname == heroName then score = score + 1 + role.GetRoleLevel(enemyName, 'carry') + role.GetRoleLevel(heroName, 'carry') end
		 end
	end
	end
	--print("hero str of "..	heroName .. " " .. score)
	return score
end

local allBotHeroes = {
	'npc_dota_hero_pangolier',
	'npc_dota_hero_dark_willow',
	'npc_dota_hero_ember_spirit',
	'npc_dota_hero_earth_spirit',
	'npc_dota_hero_phoenix',
	'npc_dota_hero_terrorblade',
	'npc_dota_hero_morphling',
	'npc_dota_hero_shredder',
	'npc_dota_hero_broodmother',
	'npc_dota_hero_antimage',
	'npc_dota_hero_dark_seer',
	'npc_dota_hero_weaver',
	'npc_dota_hero_obsidian_destroyer',
	'npc_dota_hero_batrider',
	'npc_dota_hero_lone_druid',
	'npc_dota_hero_wisp',
	'npc_dota_hero_chen',
	'npc_dota_hero_troll_warlord',
	'npc_dota_hero_alchemist',
	'npc_dota_hero_tinker',
	'npc_dota_hero_furion',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_rubick',
	'npc_dota_hero_keeper_of_the_light',
	'npc_dota_hero_ancient_apparition',
	'npc_dota_hero_mirana',
	'npc_dota_hero_medusa',
	'npc_dota_hero_spectre',
	'npc_dota_hero_enigma',
	'npc_dota_hero_visage',
	'npc_dota_hero_riki',
	'npc_dota_hero_lycan',
	'npc_dota_hero_clinkz',
	'npc_dota_hero_techies',
	'npc_dota_hero_winter_wyvern',
	'npc_dota_hero_pugna',
	'npc_dota_hero_queenofpain',
	'npc_dota_hero_silencer',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_enchantress',
	'npc_dota_hero_nyx_assassin',
	'npc_dota_hero_storm_spirit',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_abyssal_underlord',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_spirit_breaker',
	'npc_dota_hero_axe',
	'npc_dota_hero_bane',
	'npc_dota_hero_beastmaster',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_bounty_hunter',
	'npc_dota_hero_brewmaster',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_centaur',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_death_prophet',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_doom_bringer',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_drow_ranger',
	'npc_dota_hero_earthshaker',
	'npc_dota_hero_elder_titan',
	'npc_dota_hero_faceless_void',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_gyrocopter',
	'npc_dota_hero_huskar',
	'npc_dota_hero_invoker',
	'npc_dota_hero_jakiro',
	'npc_dota_hero_juggernaut',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_legion_commander',
	'npc_dota_hero_lich',
	'npc_dota_hero_life_stealer',
	'npc_dota_hero_lina',
	'npc_dota_hero_lion',
	'npc_dota_hero_luna',
	'npc_dota_hero_magnataur',
	'npc_dota_hero_meepo',
	'npc_dota_hero_monkey_king',
	'npc_dota_hero_naga_siren',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_night_stalker',
	'npc_dota_hero_ogre_magi',
	'npc_dota_hero_omniknight',
	'npc_dota_hero_oracle',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_phantom_lancer',
	'npc_dota_hero_puck',
	'npc_dota_hero_pudge',
	'npc_dota_hero_rattletrap',
	'npc_dota_hero_razor',
	'npc_dota_hero_sand_king',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_shadow_shaman',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_skywrath_mage',
	'npc_dota_hero_slardar',
	'npc_dota_hero_slark',
	'npc_dota_hero_sniper',
	'npc_dota_hero_sven',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_tiny',
	'npc_dota_hero_treant',
	'npc_dota_hero_treant',
	'npc_dota_hero_tusk',
	'npc_dota_hero_undying',
	'npc_dota_hero_ursa',
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_venomancer',
	'npc_dota_hero_viper',
	'npc_dota_hero_warlock',
	'npc_dota_hero_windrunner',
	'npc_dota_hero_witch_doctor',
	'npc_dota_hero_zuus'
};

function GetNthBestHero(N)
	local enemies = {nil, 'npc_dota_hero_antimage', "npc_dota_hero_arc_warden", 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_bristleback'}
	local heroScores = {}
	
	for i, hero in pairs(allBotHeroes) do
		heroScores[#heroScores+1] = { hero , GetHeroStrength(hero, enemies), randomValues[hero] }
	end
	
	table.sort(heroScores, strCompare)
	
	--[[for i, hero_score in pairs(heroScores) do
		print(hero_score[1] .. " " .. hero_score[2])
	end]]--
	
	return heroScores[N][1]
end

function strCompare(a,b)
	if a[2] == b[2] and a[3] == b[3] then
	return a[1] > b[1]
	end
	
	if a[2] == b[2]	then
	return a[3] > b[3]
	end
	
	return a[2] > b[2]
end

function FillRandomValues()
	for i, hero in pairs(allBotHeroes) do
		randomValues[hero] = RandomInt(1,100)
	end
end


function test()
	mukk = {nil, 'npc_dota_hero_antimage', "npc_dota_hero_arc_warden", 'npc_dota_hero_ancient_apparition', 'npc_dota_hero_bristleback'}
	GetHeroStrength('npc_dota_hero_necrolyte', mukk)
	GetHeroStrength('npc_dota_hero_bristleback', mukk)
	GetHeroStrength('npc_dota_hero_chaos_knight', mukk)
	
	print(GetNthBestHero(1));
	print(GetNthBestHero(2));
	print(GetNthBestHero(3));
	print(GetNthBestHero(4));
end

--test()
FillRandomValues()

