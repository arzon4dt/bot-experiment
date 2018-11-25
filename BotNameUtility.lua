local U = {}

local dota2team = {

	[1] = {
		['name'] = "Team Liquid";
		['alias'] = "Liquid";
		['players'] = {
			'MATUMBAMAN',
			'Miracle-',
			'MinD_ContRoL',
			'GH',
			'KuroKy'
		};
		['sponsorship'] = '';
	},
	[2] = {
		['name'] = "Newbee";
		['alias'] = "Newbee";
		['players'] = {
			'Moogy',
			'Sccc',
			'Inflame',
			'Waixi',
			'Faith'
		};
		['sponsorship'] = 'G2A';
	},
	[3] = {
		['name'] = "Tigers";
		['alias'] = "Tigers";
		['players'] = {
			'Ahjit',
			'inYourdreaM',
			'Moonmeander',
			'Xepher',
			'1437 '
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
			'RAMZES666',
			'No[o]ne',
			'9pasha',
			'RodjER',
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
			'Suma1L',
			'Fly',
			'Cr1t-',
			's4'
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
			'7ckngMad'
		};
		['sponsorship'] = 'G2A';
	},
	[9] = {
		['name'] = "Invictus Gaming";
		['alias'] = "IG";
		['players'] = {
			'ghost',
			'HAlf',
			'InJuly',
			'dogf1ghts',
			'Oli'
		};
		['sponsorship'] = 'G2A';
	},
	[10] = {
		['name'] = "Team Empire";
		['alias'] = "EmpireFaith";
		['players'] = {
			'Cooman',
			'G',
			'Miposhka',
			'velheor',
			'Maden'
		};
		['sponsorship'] = 'G2A';
	},
	[11] = {
		['name'] = "Mineski";
		['alias'] = "Mineski";
		['players'] = {
			'JT-',
			'Moon',
			'kpii',
			'Febby',
			'ninjaboogie'
		};
		['sponsorship'] = 'G2A';
	},
	[12] = {
		['name'] = "TNC Predator";
		['alias'] = "TNC";
		['players'] = {
			'Gabbi',
			'Armel',
			'Kuku',
			'Tims',
			'ninjaboogie'
		};
		['sponsorship'] = 'G2A';
	},
	[13] = {
		['name'] = " Ninjas in Pyjamas";
		['alias'] = "NiP";
		['players'] = {
			'Ace',
			'Fata',
			'33',
			'Saksa',
			'ppd'
		};
		['sponsorship'] = 'G2A';
	},
	[14] = {
		['name'] = "compLexity Gaming";
		['alias'] = "coL";
		['players'] = {
			'Skem',
			'Limmp',
			'Sneyking',
			'EternaLEnVy',
			'Zfreek'
		};
		['sponsorship'] = 'G2A';
	},
	[15] = {
		['name'] = "Team Spirit";
		['alias'] = "TSpirit";
		['players'] = {
			'oliver',
			'Nine',
			'HesteJoe-Rotten',
			'Biver',
			'fng'
		};
		['sponsorship'] = 'G2A';
	},
	[16] = {
		['name'] = "Natus Vincere";
		['alias'] = "Na'Vi";
		['players'] = {
			'Crystallize',
			'MagicaL',
			'Blizzy',
			'Chuvash',
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
		['name'] = "Vega Squadron";
		['alias'] = "Vega";
		['players'] = {
			'Madara',
			'MagE-',
			'KheZu',
			'Maybe Next Time',
			'Peksu'
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
			'mianmian',
			'Llenn'
		};
		['sponsorship'] = 'G2A';
	},
	[20] = {
		['name'] = "Fnatic";
		['alias'] = "Fnatic";
		['players'] = {
			'MP',
			'Abed',
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
			'qojqva',
			'miCKe',
			'Boxi',
			'iNSaNiA',
			'Taiga'
		};
		['sponsorship'] = 'G2A';
	},
	[22] = {
		['name'] = "paiN Gaming";
		['alias'] = "paiN";
		['players'] = {
			'hFn',
			'w33',
			'tavo',
			'Kingrd',
			'MISERY'
		};
		['sponsorship'] = 'G2A';
	},
	[23] = {
		['name'] = "paiN X";
		['alias'] = "paiN X";
		['players'] = {
			'Ritsu',
			'CCnC',
			'4dr',
			'Liposa',
			'FLee'
		};
		['sponsorship'] = '';
	},
	[24] = {
		['name'] = "The Final Tribe";
		['alias'] = "TFT";
		['players'] = {
			'Frost',
			'Chessie',
			'jonassomfan',
			'Handsken',
			'Era'
		};
		['sponsorship'] = 'G2A';
	},
	[25] = {
		['name'] = "Winstrike Team";
		['alias'] = "Winstrike";
		['players'] = {
			'Silent',
			'Iceberg',
			'nongrata',
			'ALWAYSWANNAFLY',
			'Nofear '
		};
		['sponsorship'] = 'G2A';
	},
	[26] = {
		['name'] = "J.Storm";
		['alias'] = "J.Storm";
		['players'] = {
			'Moo',
			'Bryle',
			'FoREv',
			'MiLAN',
			'March'
		};
		['sponsorship'] = 'G2A';
	},
	[27] = {
		['name'] = "Gambit Esports";
		['alias'] = "Gambit";
		['players'] = {
			'Daxak',
			'Afoninje',
			'AfterLife',
			'KingR',
			'VANSKOR'
		};
		['sponsorship'] = 'G2A';
	},
	[28] = {
		['name'] = "Vici Gaming";
		['alias'] = "VG";
		['players'] = {
			'Paparazi灬',
			'Ori',
			'Yang',
			'Fade',
			'Dy'
		};
		['sponsorship'] = 'G2A';
	},
	[29] = {
		['name'] = "EHOME";
		['alias'] = "EHOME";
		['players'] = {
			'eGo',
			'ASD',
			'Faith_bian',
			'天命',
			'y`'
		};
		['sponsorship'] = 'G2A';
	},
	[30] = {
		['name'] = "Team Aster";
		['alias'] = "Aster";
		['players'] = {
			'Sylar',
			'loveyouloveme',
			'Xxs',
			'BoBoKa',
			'Fenrir'
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