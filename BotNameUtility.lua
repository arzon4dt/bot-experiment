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
		['name'] = "Cignal Ultra";
		['alias'] = "Cignal";
		['players'] = {
			'Nando',
			'Jamesy',
			'Van',
			'Erice',
			'Grimzx '
		};
		['sponsorship'] = 'G2A';
	},
	[4] = {
		['name'] = "PSG LGD";
		['alias'] = "PSG.LGD";
		['players'] = {
			'Ame',
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
			'epileptick1d',
			'No[o]ne',
			'Resolut1on',
			'Save-',
			'Solo'
		};
		['sponsorship'] = 'G2A';
	},
	[6] = {
		['name'] = "Team Secret";
		['alias'] = "Secret";
		['players'] = {
			'Nisha',
			'MidOne',
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
			'ana',
			'Topson',
			'JerAx',
			'Ceb'
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
			'CCnC',
			'SabeRLight-',
			'MSS',
			'SVG'
		};
		['sponsorship'] = 'G2A';
	},
	[11] = {
		['name'] = "Demon Slayers";
		['alias'] = "DemSlay";
		['players'] = {
			'Costabile',
			'iAnnihilate',
			'oldWhite',
			'FrancisLee',
			'xuan'
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
			'Skiter',
			'Gunnar',
			'Universe',
			'Biver',
			'ppd'
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
			'dogf1ghts',
			'Fenrir'
		};
		['sponsorship'] = 'G2A';
	},
	[15] = {
		['name'] = "Team Spirit";
		['alias'] = "TSpirit";
		['players'] = {
			'iLTW',
			'Ergon',
			'Ghostik',
			'Immersion',
			'Misha'
		};
		['sponsorship'] = 'G2A';
	},
	[16] = {
		['name'] = "Natus Vincere";
		['alias'] = "Na'Vi";
		['players'] = {
			'Crystallize',
			'MagicaL',
			'9pasha',
			'Zayac',
			'SoNNeikO'
		};
		['sponsorship'] = 'G2A';
	},
	[17] = {
		['name'] = "Forward Gaming";
		['alias'] = "FWD";
		['players'] = {
			'YawaR',
			'Resolut1on',
			'UNiVeRsE',
			'MSS',
			'SVG'
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
			'InJuly',
			'白马',
			'mianmian'
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
			'33',
			'Handsken',
			'Fata'
		};
		['sponsorship'] = 'G2A';
	},
	[22] = {
		['name'] = "paiN Gaming";
		['alias'] = "paiN";
		['players'] = {
			'hFn',
			'4dr',
			'Lelis ',
			'Thiolicor',
			'444'
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
			'Stinger '
		};
		['sponsorship'] = '';
	},
	[24] = {
		['name'] = "Geek Fam";
		['alias'] = "GeekFam";
		['players'] = {
			'Raven',
			'Ryoya',
			'Kuku',
			'Xepher',
			'DuBu'
		};
		['sponsorship'] = 'G2A';
	},
	[25] = {
		['name'] = "HellRaisers";
		['alias'] = "HR";
		['players'] = {
			'V-Tune',
			'Nix',
			'DM',
			'ALOHADANCE',
			'Miposhka '
		};
		['sponsorship'] = 'G2A';
	},
	[26] = {
		['name'] = "J.Storm";
		['alias'] = "J.Storm";
		['players'] = {
			'Moo',
			'Nine',
			'Brax',
			'MoOz',
			'Fear'
		};
		['sponsorship'] = 'G2A';
	},
	[27] = {
		['name'] = "Gambit Esports";
		['alias'] = "Gambit";
		['players'] = {
			'dream`',
			'gpk',
			'Shachlo',
			'XSvamp1Re',
			'fng'
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
			'vtFαded',
			'897',
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