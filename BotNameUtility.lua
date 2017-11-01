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
			'kpii',
			'Kaka',
			'Faith'
		};
		['sponsorship'] = 'G2A';
	},
	[3] = {
		['name'] = "LGD.Forever Young";
		['alias'] = "LFY";
		['players'] = {
			'Monet',
			'Super',
			'Inflame',
			'Ahfu',
			'ddc'
		};
		['sponsorship'] = 'G2A';
	},
	[4] = {
		['name'] = "LGD Gaming";
		['alias'] = "LGD";
		['players'] = {
			'Ame',
			'Maybe',
			'fy',
			'Yao',
			'Victoria'
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
			'Lil',
			'Solo'
		};
		['sponsorship'] = 'G2A';
	},
	[6] = {
		['name'] = "Team Secret";
		['alias'] = "Secret";
		['players'] = {
			'Ace',
			'MidOne',
			'Fata',
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
			'UNiVeRsE',
			'Cr1t-',
			'Fear'
		};
		['sponsorship'] = 'G2A';
	},
	[8] = {
		['name'] = "OG";
		['alias'] = "OG";
		['players'] = {
			'N0tail',
			'Resolut1on',
			's4',
			'JerAx',
			'Fly'
		};
		['sponsorship'] = 'G2A';
	},
	[9] = {
		['name'] = "Invictus Gaming";
		['alias'] = "IG";
		['players'] = {
			'GazEoD',
			'Op',
			'Xxs',
			'BoBoKa',
			'Q'
		};
		['sponsorship'] = 'G2A';
	},
	[10] = {
		['name'] = "Team Empire";
		['alias'] = "Empire";
		['players'] = {
			'Chappie',
			'fn',
			'Ghostik',
			'Miposhka',
			'VANSKOR'
		};
		['sponsorship'] = 'G2A';
	},
	[11] = {
		['name'] = "Mineski";
		['alias'] = "Mineski";
		['players'] = {
			'NaNa',
			'Mushi',
			'iceiceice',
			'Jabz',
			'ninjaboogie'
		};
		['sponsorship'] = 'G2A';
	},
	[12] = {
		['name'] = "TNC Pro Team";
		['alias'] = "TNC";
		['players'] = {
			'Raven',
			'Kuku',
			'Sam_H',
			'Tims',
			'1437'
		};
		['sponsorship'] = 'G2A';
	},
	[13] = {
		['name'] = "Vici Gaming";
		['alias'] = "VG";
		['players'] = {
			'Paparazi灬',
			'Ori',
			'eLeVeN',
			'LaNm',
			'Fenrir'
		};
		['sponsorship'] = 'G2A';
	},
	[14] = {
		['name'] = "compLexity Gaming";
		['alias'] = "coL";
		['players'] = {
			'Chessie',
			'Limmp',
			'Moo',
			'Zfreek',
			'melonzz'
		};
		['sponsorship'] = 'G2A';
	},
	[15] = {
		['name'] = "Team Spirit";
		['alias'] = "TSpirit";
		['players'] = {
			'iLTW',
			'Iceberg',
			'DkPhobos',
			'fng',
			'Biver'
		};
		['sponsorship'] = 'G2A';
	},
	[16] = {
		['name'] = "Natus Vincere";
		['alias'] = "Na'Vi";
		['players'] = {
			'Crystallize',
			'Dendi',
			'GeneRaL',
			'RodjER',
			'SoNNeikO'
		};
		['sponsorship'] = 'G2A';
	},
	[17] = {
		['name'] = "Digital Chaos";
		['alias'] = "DC";
		['players'] = {
			'mason',
			'Abed',
			'MSS',
			'BuLba',
			'MoonMeander'
		};
		['sponsorship'] = 'G2A';
	},
	[18] = {
		['name'] = "Vega Squadron";
		['alias'] = "Vega";
		['players'] = {
			'ALOHADANCE',
			'G',
			'AfterLife',
			'Silent',
			'CemaTheSlayeR'
		};
		['sponsorship'] = 'G2A';
	},
	[19] = {
		['name'] = "iG Vitality";
		['alias'] = "iG.V";
		['players'] = {
			'Flyby',
			'Sakata',
			'Srf',
			'dogf1ghts',
			'super'
		};
		['sponsorship'] = 'G2A';
	},
	[20] = {
		['name'] = "Fnatic";
		['alias'] = "Fnatic";
		['players'] = {
			'EternaLEnVy',
			'Xcalibur',
			'Ohaiyo',
			'DJ',
			'pieliedie'
		};
		['sponsorship'] = 'G2A';
	},
	[21] = {
		['name'] = "SFT e-sports";
		['alias'] = "SFT";
		['players'] = {
			'Niqua',
			'IllidanSTR',
			'Topson',
			'Peksu',
			'ST_ST'
		};
		['sponsorship'] = 'G2A';
	},
	[22] = {
		['name'] = "Infamous";
		['alias'] = "Infamous";
		['players'] = {
			'Kotarō Hayama',
			'LeoStyle-',
			'Papita',
			'StingeR',
			'Accel'
		};
		['sponsorship'] = 'G2A';
	},
	[23] = {
		['name'] = "WarriorsGaming.Unity";
		['alias'] = "WG";
		['players'] = {
			'Syeonix',
			'Feero',
			'Velo',
			'Meracle',
			'xNova-'
		};
		['sponsorship'] = '捕食者';
	},
	[24] = {
		['name'] = "Execration";
		['alias'] = "XctN";
		['players'] = {
			'Gabbi',
			'CartMaN',
			'RagingPotato',
			'RR',
			'Kim0'
		};
		['sponsorship'] = 'G2A';
	},
	[25] = {
		['name'] = "Comm1";
		['alias'] = "Standin";
		['players'] = {
			'Machine',
			'Weppas',
			'Kaci',
			'SirActionSlacks',
			'Capitalist'
		};
		['sponsorship'] = 'G2A';
	},
	[26] = {
		['name'] = "Comm2";
		['alias'] = "Standin";
		['players'] = {
			'Draskyl',
			'Fogged',
			'GoDz',
			'LD',
			'Luminous'
		};
		['sponsorship'] = 'G2A';
	},
	[27] = {
		['name'] = "Comm3";
		['alias'] = "Standin";
		['players'] = {
			'Merlini',
			'ODPixel',
			'Purge',
			'Sheever',
			'syndereN'
		};
		['sponsorship'] = 'G2A';
	},
	[28] = {
		['name'] = "Comm4";
		['alias'] = "Standin";
		['players'] = {
			'TobiWan',
			'WinteR',
			'CaspeRRR',
			'Blitz',
			'v1lat'
		};
		['sponsorship'] = 'G2A';
	},
	[29] = {
		['name'] = "The Dire";
		['alias'] = "Standin";
		['players'] = {
			'Pajkatt',
			'CC&C',
			'Zai',
			'MiSeRy',
			'ppd'
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