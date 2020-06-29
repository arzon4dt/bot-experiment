local U = {}

local dota2team = {

	[1] = {
		['name'] = "Team Liquid";
		['alias'] = "Liquid";
		['players'] = {
			'miCKe',
			'qojqva',
			'Boxi',
			'Taiga',
			'iNSaNiA'
		};
		['sponsorship'] = '';
	},
	[2] = {
		['name'] = "Newbee";
		['alias'] = "Newbee";
		['players'] = {
			'Fonte',
			'Aq',
			'Wizard',
			'Waixi',
			'Faith'
		};
		['sponsorship'] = 'G2A';
	},
	[3] = {
		['name'] = "Boom Esports";
		['alias'] = "Boom";
		['players'] = {
			'Dreamocel',
			'Mikoto',
			'Fbz',
			'Hyde',
			'Khezcute'
		};
		['sponsorship'] = 'G2A';
	},
	[4] = {
		['name'] = "PSG LGD";
		['alias'] = "PSG.LGD";
		['players'] = {
			'eLeVeN',
			'Somnus丶M',
			'Chalice',
			'fy',
			'xNova'
		};
		['sponsorship'] = 'G2A';
	},
	[5] = {
		['name'] = "Virtus.pro";
		['alias'] = "VP";
		['players'] = {
			'iLTW',
			'No[o]ne',
			'Resolut1on',
			'Zayac',
			'Solo'
		};
		['sponsorship'] = 'G2A';
	},
	[6] = {
		['name'] = "Team Secret";
		['alias'] = "Secret";
		['players'] = {
			'Nisha',
			'MATUMBAMAN',
			'zai',
			'YapzOr',
			'Puppey'
		};
		['sponsorship'] = 'G2A';
	},
	[7] = {
		['name'] = "Evil Geniuses";
		['alias'] = "EG";
		['players'] = {
			'Arteezy',
			'Abed',
			'RAMZES666',
			'Cr1t-',
			'Fly'
		};
		['sponsorship'] = 'G2A';
	},
	[8] = {
		['name'] = "OG";
		['alias'] = "OG";
		['players'] = {
			'N0tail',
			'SumaiL	',
			'Topson',
			'Saksa',
			'MidOne'
		};
		['sponsorship'] = 'G2A';
	},
	[9] = {
		['name'] = "Invictus Gaming";
		['alias'] = "IG";
		['players'] = {
			'flyfly',
			'Emo',
			'JT-',
			'Kaka',
			'Oli'
		};
		['sponsorship'] = 'G2A';
	},
	[10] = {
		['name'] = "Quincy Crew";
		['alias'] = "QCY";
		['players'] = {
			'YawaR',
			'Quinn',
			'Lelis',
			'MSS',
			'SVG'
		};
		['sponsorship'] = 'G2A';
	},
	[11] = {
		['name'] = "Demon Slayers";
		['alias'] = "DemSlay";
		['players'] = {
			'Oceania',
			'iAnnihilate',
			'oldWhite',
			'Jubei',
			'N/A'
		};
		['sponsorship'] = 'G2A';
	},
	[12] = {
		['name'] = "TNC Predator";
		['alias'] = "TNC";
		['players'] = {
			'Gabbi',
			'Armel',
			'kpii',
			'Tims',
			'March'
		};
		['sponsorship'] = 'G2A';
	},
	[13] = {
		['name'] = " Ninjas in Pyjamas";
		['alias'] = "NiP";
		['players'] = {
			'CharlieDota',
			'Supream^',
			'SabeRLight-',
			'Era',
			'SoNNeikO '
		};
		['sponsorship'] = 'G2A';
	},
	[14] = {
		['name'] = "Royal Never Give Up";
		['alias'] = "RNG";
		['players'] = {
			'Monet',
			'Setsu',
			'Flyby',
			'September',
			'Super'
		};
		['sponsorship'] = 'G2A';
	},
	[15] = {
		['name'] = "B8";
		['alias'] = "B8";
		['players'] = {
			'Crystallis	',
			'Dendi',
			'LastHero',
			'5up',
			'Fishman'
		};
		['sponsorship'] = 'G2A';
	},
	[16] = {
		['name'] = "Natus Vincere";
		['alias'] = "Na'Vi";
		['players'] = {
			'Crystallize',
			'young G',
			'9pasha',
			'Immersion',
			'illias'
		};
		['sponsorship'] = 'G2A';
	},
	[17] = {
		['name'] = "Vikin.gg";
		['alias'] = "Vikin.gg";
		['players'] = {
			'Shad',
			'BOOM',
			'Tobi',
			'Aramis',
			'Seleri'
		};
		['sponsorship'] = 'G2A';
	},
	[18] = {
		['name'] = "Nigma";
		['alias'] = "Nigma";
		['players'] = {
			'Miracle-',
			'w33',
			'MinD_ContRoL',
			'GH',
			'KuroKy'
		};
		['sponsorship'] = 'G2A';
	},
	[19] = {
		['name'] = "iG Vitality";
		['alias'] = "iG.V";
		['players'] = {
			'Dust',
			'ButterflyEffect',
			'BEYOND',
			'@dogf1ghts',
			'DoDo'
		};
		['sponsorship'] = 'G2A';
	},
	[20] = {
		['name'] = "Fnatic";
		['alias'] = "Fnatic";
		['players'] = {
			'23savage',
			'Moon',
			'iceiceice',
			'DJ',
			'Jabz'
		};
		['sponsorship'] = 'G2A';
	},
	[21] = {
		['name'] = "Alliance";
		['alias'] = "Alliance";
		['players'] = {
			'Nikobaby',
			'Limmp',
			's4 ',
			'Handsken',
			'fng'
		};
		['sponsorship'] = 'G2A';
	},
	[22] = {
		['name'] = "T1";
		['alias'] = "T1";
		['players'] = {
			'Meracle',
			'inYourdreaM',
			'Forev',
			'Jhocam',
			'Poloson'
		};
		['sponsorship'] = 'G2A';
	},
	[23] = {
		['name'] = "beastcoast";
		['alias'] = "bc";
		['players'] = {
			'K1',
			'Chris Luck',
			'Wisper',
			'Scofield',
			'MoOz '
		};
		['sponsorship'] = '';
	},
	[24] = {
		['name'] = "Geek Fam";
		['alias'] = "GeekFam";
		['players'] = {
			'Raven',
			'Karl',
			'Kuku',
			'Xepher',
			'Whitemon'
		};
		['sponsorship'] = 'G2A';
	},
	[25] = {
		['name'] = "HellRaisers";
		['alias'] = "HR";
		['players'] = {
			'xannii',
			'Nix',
			'RodjER',
			'Funn1k',
			'Miposhka '
		};
		['sponsorship'] = 'G2A';
	},
	[26] = {
		['name'] = "FlyToMoon";
		['alias'] = "FlyToMoon";
		['players'] = {
			'V-Tune',
			'Iceberg',
			'GeneRaL',
			'ALOHADANCE',
			'ALWAYSWANNAFLY'
		};
		['sponsorship'] = 'G2A';
	},
	[27] = {
		['name'] = "Team Unique";
		['alias'] = "Unique";
		['players'] = {
			'Palantimos',
			'19teen',
			'633',
			'illusion',
			'VANSKOR'
		};
		['sponsorship'] = 'G2A';
	},
	[28] = {
		['name'] = "Vici Gaming";
		['alias'] = "VG";
		['players'] = {
			'Eurus',
			'Ori',
			'Yang',
			'Pyw',
			'Dy'
		};
		['sponsorship'] = 'G2A';
	},
	[29] = {
		['name'] = "EHOME";
		['alias'] = "EHOME";
		['players'] = {
			'Sylar',
			'NothingToSay',
			'Faith_bian',
			'XinQ',
			'y`'
		};
		['sponsorship'] = 'G2A';
	},
	[30] = {
		['name'] = "Team Aster";
		['alias'] = "Aster";
		['players'] = {
			'Sccc',
			'ChYuan',
			'Xxs',
			'BoBoKa',
			'Fade'
		};
		['sponsorship'] = 'G2A';
	}
	
}

local sponsorship = {"GG.bet", "gg.bet", "VPGAME", "LOOT.bet", "loot.bet", "", "Esports.bet", "G2A", "Dota2.net"};

function U.GetDota2Team()
	local bot_names = {};
	local rand = RandomInt(1, #dota2team); 
	local srand = RandomInt(1, #sponsorship); 
	if GetTeam() == TEAM_RADIANT then
		while rand%2 ~= 0 do
			rand = RandomInt(1, #dota2team); 
		end
	else
		while rand%2 ~= 1 do
			rand = RandomInt(1, #dota2team); 
		end
	end
	local team = dota2team[rand];
	for _,player in pairs(team.players) do
		if sponsorship[srand] == "" then
			table.insert(bot_names, team.alias.."."..player);
		else
			table.insert(bot_names, team.alias.."."..player.."."..sponsorship[srand]);
		end
	end
	return bot_names;
end

return U