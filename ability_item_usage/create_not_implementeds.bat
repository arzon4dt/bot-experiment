set list="antimage" "axe" "bane" "batrider" "bloodseeker" "bounty_hunter" "bristleback" "broodmother" "chaos_knight" "chen" "crystal_maiden" "dark_seer" "dazzle" "death_prophet" "dragon_knight" "drow_ranger" "earthshaker" "jakiro" "juggernaut" "kunkka" "lich" "lina" "lion" "lone_druid" "luna" "morphling" "nevermore" "obsidian_destroyer" "omniknight" "oracle" "phantom_assassin" "pudge" "razor" "sand_king" "shredder" "skeleton_king" "skywrath_mage" "sniper" "sven" "tidehunter" "tiny" "vengefulspirit" "viper" "warlock" "weaver" "windrunner" "witch_doctor" "zuus"

for %%x in (%list%) do (
   copy "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\bots\ability_item_usage\ability_item_usage_main.lua" "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota\scripts\vscripts\bots\ability_item_usage\ability_item_usage_%%x.lua"
)
