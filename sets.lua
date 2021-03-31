-----------------------
-- Namespaces
-----------------------
local SM, DB, DP, L, U = unpack(select(2, ...))

DB.armorTypes = {
	'Cloth', -- 1
	'Leather', -- 2
	'Mail', -- 3
	'Plate', -- 4
	'All', -- 5
	cloth = 1,
	leather = 2,
	mail = 3,
	plate = 4,
	all = 5,
}

DB.classes = {
	{armor = DB.armorTypes.plate}, -- 1 / Warrior
	{armor = DB.armorTypes.plate}, -- 2 / Paladin
	{armor = DB.armorTypes.mail}, -- 3 / Hunter
	{armor = DB.armorTypes.leather}, -- 4 / Rogue
	{armor = DB.armorTypes.cloth}, -- 5 / Priest
	{armor = DB.armorTypes.plate}, -- 6 / Death Knight
	{armor = DB.armorTypes.mail}, -- 7 / Shaman
	{armor = DB.armorTypes.cloth}, -- 8 / Mage
	{armor = DB.armorTypes.cloth}, -- 9 / Warlock
	{armor = DB.armorTypes.leather}, -- 10 / Monk
	{armor = DB.armorTypes.leather}, -- 11 / Druid
	{armor = DB.armorTypes.leather}, -- 12 / Demon Hunter
}

DB.setSources = {
	'Classic',
	'TBC',
	'WotLK',
	'Cata',
	'MoP',
	'WoD',
	'Legion',
	'BfA',
	sourceType = {
		'World', -- 1
		'Dungeon', -- 2
		'Event', -- 3
		'Garrison', -- 4
		'PvP', -- 5
		'Raid', -- 6
		'Questing', -- 7
		'Profession', -- 8
		'Vendor' -- 9
	},
}

DB.itemSlots = {
	[1] = 'HEADSLOT',
	[3] = 'SHOULDERSLOT', -- 3
	[4] = 'SHIRTSLOT', -- 4
	[5] = 'CHESTSLOT', -- 5
	[6] = 'WAISTSLOT', -- 6
	[7] = 'LEGSSLOT', -- 7
	[8] = 'FEETSLOT', -- 8
	[9] = 'WRISTSLOT', -- 9
	[10] = 'HANDSSLOT', -- 10
	[15] = 'BACKSLOT', -- 15
	[16] = 'MAINHANDSLOT', -- 16
	[17] = 'SECONDARYHANDSLOT', -- 17
	[19] = 'TABARDSLOT' -- 19

}

local b
local v = {setID = 0}
DB.minitest = {}
local mt = DB.minitest

b={name='Gossamer Regalia',description='White',setID=v.setID+1,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[3]={7523},[5]={7518},[6]={12466,24255}}};tinsert(mt,b)
v={name='Gossamer Regalia',description='Purple',setID=b.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[3]={10172,14298,21468,28075},[5]={30928},[7]={30929}}};tinsert(mt,v)
v={name='Gossamer Regalia',description='Black',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[3]={10210},[5]={19399},[6]={30932},[8]={21489}}};tinsert(mt,v)
v={name='Gossamer Regalia',description='Red',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[3]={16980,30514},[5]={7054},[6]={30923,31199}}};tinsert(mt,v)
v={name='Gossamer Regalia',description='Red Black',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[3]={8250},[5]={19156,30762},[6]={12589,19388,22730}}};tinsert(mt,v)
v={name='Gossamer Regalia',description='Black Black',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=true,items={[3]={13374,19849,24667},[5]={6324,22301,30928,31158},[6]={18809,22306},[7]={22303},[8]={18697,28179}}};tinsert(mt,v)
b={name='Arcane Regalia',description='Blue Sleeveless',setID=v.setID+1,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=true,items={[5]={14138},[7]={8289,14137},[8]={8284,15802}}}tinsert(mt,b)
v={name='Arcane Regalia',description='Blue Sleeved',setID=b.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,8},armorType=DB.armorTypes.cloth,limitedTimeSet=true,items={[5]={8283},[7]={8289,14137},[8]={8284,15802}}};tinsert(mt,v)
v={name='Arcane Regalia',description='Red',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,2,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[5]={7051},[7]={13008,18745},[8]={3076,10044,13282}}};tinsert(mt,v)
v={name='Arcane Regalia',description='Black',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,2,7,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[5]={9434,10246,21855},[7]={2277,10252,14632,21852},[8]={2232,10247,12050,21853,30519,35581}}};tinsert(mt,v)
v={name='Arcane Regalia',description='Gray',setID=v.setID+1,baseSetID=b.setID,expansionID=1,sourceTypes={1,2,7,8},armorType=DB.armorTypes.cloth,limitedTimeSet=false,items={[5]={10057},[7]={10064,17603,77691},[8]={10058,20054,20094,20095,20096,20159,20160,20161,20162},[9]={10059},[10]={10062}}};tinsert(mt,v)

DB.allSets = {
	{ -- 1
		name = 'Gossamer Regalia',
		description = 'White',
		setID = 1,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[3] = {7523},
			[5] = {7518}, 
			[6] = {12083, 12466, 24255},
			[16] = {81691}
		},
	},
	{ -- 2
		name = 'Gossamer Regalia',
		description = 'Purple',
		setID = 2,
		baseSetID = 1,
		minRequiredLevel = 58,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[3] = {10172, 14298, 21468, 28075},
			[5] = {30928},
			[7] = {30929}
		},
	},
	{ -- 3
		name = 'Gossamer Regalia',
		description = 'Black',
		setID = 3,
		baseSetID = 1,
		minRequiredLevel = 58,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[3] = {10210},
			[5] = {19399},
			[6] = {15707, 30932},
			[8] = {21489}
		},
	},
	{ -- 4
		name = 'Gossamer Regalia',
		description = 'Red',
		setID = 4,
		baseSetID = 1,
		minRequiredLevel = 58,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[3] = {16980, 30514},
			[5] = {7054},
			[6] = {4117, 30923, 31199}
		},
	},
	{ -- 5
		name = 'Gossamer Regalia',
		description = 'Red Black',
		setID = 5,
		baseSetID = 1,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[3] = {8250, 22405},
			[5] = {19156, 30762},
			[6] = {12589, 19388, 22730}
		},
	},
	{ -- 6 -- Going to be split. Set minRequiredLevel then
		name = 'Gossamer Regalia',
		description = 'Black Black',
		setID = 6,
		baseSetID = 1,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = true,
		items = {
			[3] = {13374, 19849, 24667},
			[5] = {6324, 22301, 31158},
			[6] = {6392, 18809, 22306, 166822},
			[7] = {22303, 166826},
			[8] = {18697, 28179, 166823}
		},
	},
	{ -- 7
		name = 'Arcane Regalia',
		description = 'Blue No sleeves',
		setID = 7,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = true,
		items = {
			[5] = {14138},
			[7] = {8289, 14137},
			[8] = {8284, 15802}
		},
	},
	{ -- 8
		name = 'Arcane Regalia',
		description = 'Blue Sleeved',
		setID = 8,
		baseSetID = 7,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = true,
		items = {
			[5] = {8283},
			[7] = {8289, 14137},
			[8] = {8284, 15802}
		},
	},
	{ -- 9
		name = 'Arcane Regalia',
		description = 'Red',
		setID = 9,
		baseSetID = 7,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 2, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[5] = {7051},
			[7] = {13008, 18745},
			[8] = {3076, 10044, 13282}
		},
	},
	{ -- 10
		name = 'Arcane Regalia',
		description = 'Black',
		setID = 10,
		baseSetID = 7,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 2, 7, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[5] = {9434, 10246, 21855},
			[7] = {2277, 10252, 14632, 21852},
			[8] = {2232, 10247, 12050, 21853, 30519, 35581}
		},
	},
	{ -- 11
		name = 'Arcane Regalia',
		description = 'Gray',
		setID = 11,
		baseSetID = 7,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 2, 7, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = {
			[5] = {10057},
			[7] = {10064, 17603, 77691},
			[8] = {10058, 11908, 20054, 20094, 20095, 20096, 20159, 20160, 20161, 20162},
			[9] = {10059},
			[10] = {10062}
		},
	},
	{ -- 12
		name = 'Aurora Regalia',
		description = 'Warm White',
		setID = 12,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 2, 7},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {4041, 10574, 24665},
			[3] = {4729, 1188, 17047},
			[5] = {6415, 52927, 54999, 57213, 57579}
		}
	},
	{ -- 13
		name = 'Aurora Regalia',
		description = 'Black',
		setID = 13,
		baseSetID = 12,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 2, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {6697, 11310, 39894, 20686},
			[5] = {2800, 4035}
		}
	},
	{ -- 14
		name = 'Aurora Regalia',
		description = 'Green',
		setID = 14,
		baseSetID = 12,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {7057, 14212},
			[5] = {4476},
			[6] = {4328},
		}
	},
	{ -- 15
		name = 'Aurora Regalia',
		description = 'Blue',
		setID = 15,
		baseSetID = 12,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {1, 7, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {4718, 5820, 9824, 14201, 15457, 22234, 24683, 24691},
			[5] = {5770, 53406, 59011, 59566},
			[6] = {7526},
		}
	},
	{ -- 16
		name = 'Aurora Regalia',
		description = 'Orange',
		setID = 16,
		baseSetID = 12,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {2},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {5820, 22234},
			[5] = {2566, 49541, 82891, 62846},
		}
	},
	{ -- 17
		name = 'Absolution Regalia',
		description = 'Orange',
		setID = 17,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {1, 6, 9},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {32329, 150481},
			[3] = {32273, 150469},
			[5] = {32340, 150492},
			[8] = {34926},
			[10] = {32353, 150505},
		}
	},
	{ -- 18
		name = 'Amani Regalia',
		description = 'Blue',
		setID = 18,
		minRequiredLevel = 80,
		expansionID = 2,
		sourceTypes = {1, 9},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {33463, 94066},
			[3] = {33489, 94067},
			[5] = {33203, 94064},
			[7] = {33585},
			[10] = {33587},
		}
	},
	{ -- 19
		name = 'Amani Regalia',
		description = 'Green',
		setID = 19,
		baseSetID = 18,
		minRequiredLevel = 80,
		expansionID = 4,
		sourceTypes = {2},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {69612},
			[5] = {69578},
			[9] = {69567},
			[10] = {69797},
		}
	},
	{ -- 20
		name = 'Amani Regalia',
		description = 'Red',
		setID = 20,
		baseSetID = 18,
		minRequiredLevel = 80,
		expansionID = 5,
		sourceTypes = {1, 2, 9},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {33453, 94262},
			[3] = {94029},
			[5] = {33317, 94065},
			[7] = {69550},
			[10] = {33586},
		}
	},
	{ -- 21
		name = 'Amani Regalia',
		description = 'Black',
		setID = 21,
		baseSetID = 18,
		minRequiredLevel = 80,
		expansionID = 4,
		sourceTypes = {2},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {69577},
			[5] = {69598},
			[7] = {69601},
		}
	},
	{ -- 22
		name = "Anraphet's Regalia",
		description = 'White Purple',
		setID = 22,
		minRequiredLevel = 80,
		expansionID = 4,
		sourceTypes = {1, 2, 7},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {55198, 56269, 57273, 65776, 113759, 133182},
			[3] = {55786, 56324, 63465, 67117},
			[5] = {57860, 57868, 67106, 101193},
			[6] = {55878, 56403, 61397, 133278},
			[7] = {55849, 56218, 56375, 59784, 63802, 63807, 65833, 101192, 133250, 133308},
			[8] = {56105, 56436, 63440, 67113, 101189, 113786, 151067},
			[10] = {55793, 56331, 63482, 67126, 101190, 113763, 133209},
		}
	},
	{ -- 23
		name = "Anraphet's Regalia",
		description = 'Purple',
		setID = 23,
		baseSetID = 22,
		minRequiredLevel = 80,
		expansionID = 4,
		sourceTypes = {1, 2, 7},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {57864, 57871, 63455, 66931},
			[3] = {55876, 56399, 59667, 59671, 63463, 66910, 133274, 133365, 157593},
			[5] = {55998, 56417, 63433, 63704, 63708, 65657, 66919}, --65174
			[6] = {63916, 63921, 66892, 66941},
			[7] = {55849, 55993, 56218, 56375, 56413, 59784, 63802, 63807, 65833, 66904, 101192, 113761, 133250, 133308},
			[8] = {61413, 66937, 67237},
			[10] = {55255, 56286, 59787, 66641, 133198},
		}
	},
	{ -- 24
		name = "Anraphet's Regalia",
		description = 'Blue',
		setID = 24,
		baseSetID = 22,
		minRequiredLevel = 80,
		expansionID = 4,
		sourceTypes = {2, 7},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {56133, 56460, 57263, 133302},
			[5] = {55278, 56311},
			[6] = {55275, 55830, 56305, 56356, 133232},
			[7] = {57280},
			[8] = {55817, 56348, 133225, 133370, 157605},
		}
	},
	{ -- 25
		name = 'Arcanist Regalia',
		description = 'Red',
		setID = 25,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {2},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {27488},
			[3] = {27816, 127235},
			[5] = {28252},
			[6] = {27742, 127207},
			[7] = {28212},
			[8] = {27848},
			[9] = {27746},
			[10] = {27764, 27889},
		}
	},
	{ -- 26
		name = 'Arcanist Regalia',
		description = 'Purple',
		setID = 26,
		baseSetID = 25,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {6, 7, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {24267, 28804},
			[3] = {30925},
			[5] = {28578, 28602},
			[7] = {24263, 28742, 49892},
			[10] = {28780},
		}
	},
	{ -- 27
		name = 'Arcanist Regalia',
		description = 'Blue',
		setID = 27,
		baseSetID = 25,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {1, 2, 6, 8},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {21869},
			[5] = {31340}, -- 21871 (Tucked sleeves)
			[6] = {27547, 127194},
			[8] = {21870},
			[10] = {28507, 28508},
		}
	},
	{ -- 28
		name = 'Arcanoshatter Regalia Lookalike',
		description = 'Heroic',
		setID = 28,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 1,
		items = 
		{
			[1] = {113868, 115553},
			[3] = {113609, 115551},
			[5] = {113850, 113898, 115550},
			[6] = {113967},
			[7] = {113914, 115554},
			[8] = {113942},
			[9] = {113642, 119332},
			[10] = {113933, 115552},
		}
	},
	{ -- 29
		name = 'Arcanoshatter Regalia Lookalike',
		description = 'Normal',
		setID = 29,
		baseSetID = 28,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {113868, 115553},
			[3] = {113609, 115551},
			[5] = {113850, 113898, 115550},
			[6] = {113967},
			[7] = {113914, 115554},
			[8] = {113942},
			[9] = {113642, 119332},
			[10] = {113933, 115552},
		}
	},
	{ -- 30
		name = 'Arcanoshatter Regalia Lookalike',
		description = 'Mythic',
		setID = 30,
		baseSetID = 28,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 3,
		items = 
		{
			[1] = {113868, 115553},
			[3] = {113609, 115551},
			[5] = {113850, 113898, 115550},
			[6] = {113967},
			[7] = {113914, 115554},
			[8] = {113942},
			[9] = {113642, 119332},
			[10] = {113933, 115552},
		}
	},
	{ -- 31
		name = 'Attire of Piety Lookalike',
		description = 'Heroic',
		setID = 31,
		expansionID = 6,
		minRequiredLevel = 90,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 1,
		items = 
		{
			[3] = {124175},
			[5] = {124170},
			[6] = {124180},
			[8] = {124149},
			[9] = {124183, 124185},
			[10] = {124153},
		}
	},
	{ -- 32
		name = 'Attire of Piety Lookalike',
		description = 'Mythic',
		setID = 32,
		baseSetID = 31,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 3,
		items = 
		{
			[3] = {124175},
			[5] = {124170},
			[6] = {124180},
			[8] = {124149},
			[9] = {124183, 124185},
			[10] = {124153},
		}
	},
	{ -- 33
		name = 'Attire of Piety Lookalike',
		description = 'Normal',
		setID = 33,
		baseSetID = 31,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {1, 6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {124175},
			[5] = {124170},
			[6] = {124180},
			[8] = {124149},
			[9] = {124183, 124185},
			[10] = {124153},
		}
	},
	{ -- 34
		name = 'Blessed Regalia of Undead Cleansing',
		description = '',
		setID = 34,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = true,
		items = 
		{
			[3] = {43074, 27796, 28612, 127208, 151886},
			[5] = {43072},
			[7] = {43075},
			[10] = {43073},
		}
	},
	{ -- 35
		name = "Bloodmage's Regalia Lookalike",
		description = 'Normal',
		setID = 35,
		minRequiredLevel = 58,
		expansionID = 3,
		sourceTypes = {6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {50276, 51554},
			[3] = {50279, 51020},
			[5] = {50278, 51790},
			[6] = {51017, 53118, 54562},
			[7] = {50277, 50990},
			[8] = {50804},
			[9] = {51007},
			[10] = {50275, 50782},
		}
	},
	{ -- 36
		name = 'Broken Shore Cloth',
		description = 'Purple',
		setID = 36,
		minRequiredLevel = 100,
		expansionID = 7,
		sourceTypes = {2},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {147517, "147517:1"},
			[3] = {144469, "144469:1"},
			[5] = {144473, "144473:1"},
			[6] = {144472, "144472:1"},
			[7] = {144474, "144474:1"},
			[8] = {144471, "144471:1"},
			[9] = {144475, "144475:1"},
			[10] = {144470, "144470:1"},
		}
	},
	{ -- 37
		name = 'Broken Shore Cloth',
		description = 'Green',
		setID = 37,
		baseSetID = 36,
		minRequiredLevel = 100,
		expansionID = 7,
		sourceTypes = {1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {146786},
			[3] = {146791},
			[5] = {146789},
			[6] = {146785},
			[7] = {146788},
			[8] = {146790},
			[9] = {146792},
			[10] = {146787},
		}
	},
	{ -- 38
		name = 'Broken Shore Cloth',
		description = 'Brown',
		setID = 38,
		baseSetID = 36,
		minRequiredLevel = 100,
		expansionID = 7,
		sourceTypes = {1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {146729, 146877},
			[3] = {146882},
			[5] = {146880},
			[6] = {146876},
			[7] = {146879},
			[8] = {146881},
			[9] = {146883},
			[10] = {146878},
		}
	},
	{ -- 39
		name = 'Ceremonial Karabor Regalia',
		description = 'Reputation',
		setID = 39,
		minRequiredLevel = 90,
		expansionID = 6,
		sourceTypes = {9},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {128468},
			[3] = {128463},
			[5] = {128464},
			[6] = {128467},
			[7] = {128470},
			[8] = {128465},
			[9] = {128469},
			[10] = {128466},
		}
	},
	{ -- 40
		name = 'Ceremonial Karabor Regalia',
		description = "Mac'Aree World",
		setID = 40,
		baseSetID = 39,
		minRequiredLevel = 100,
		expansionID = 7,
		sourceTypes = {1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {153271},
			[3] = {153276},
			[5] = {153288},
			[6] = {153270},
			[7] = {153273},
			[8] = {153275},
			[9] = {153277},
			[10] = {153272},
		}
	},
	{ -- 41
		name = 'Ceremonial Karabor Regalia',
		description = "Mac'Aree chests",
		setID = 41,
		baseSetID = 39,
		minRequiredLevel = 100,
		expansionID = 7,
		sourceTypes = {1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {153280},
			[3] = {153285},
			[5] = {153283},
			[6] = {153279},
			[7] = {153282},
			[8] = {153284},
			[9] = {153286},
			[10] = {153281},
		}
	},
	{ -- 42
		name = "Champion's Arcanum",
		description = '',
		setID = 42,
		minRequiredLevel = 1,
		expansionID = 1,
		sourceTypes = {5, 9},
		armorType = DB.armorTypes.cloth,
		requiredClassMask = bit.lshift(1, 8),
		limitedTimeSet = false,
		items = 
		{
			[1] = {16489, 23263, 77776, 77778},
			[3] = {16492, 23264, 77772, 77779},
			[5] = {16491, 22886, 77770, 77781},
			[6] = {120987},
			[7] = {16490, 22883, 77774, 77782},
			[8] = {16485, 22860, 77771, 77773},
			[9] = {77786, 77788},
			[10] = {16487, 22870, 77775, 77783},
		}
	},
	{ -- 43
		name = 'Chronomancer Regalia Lookalike',
		description = 'Mythic',
		setID = 43,
		minRequiredLevel = 80,
		expansionID = 5,
		sourceTypes = {6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 3,
		items = 
		{
			[1] = {104424, 104651, 105420, 105647, 112424, 112937},
			[3] = {104468, 104561, 105464, 105557, 112558, 112790},
			[5] = {104444, 104596, 105440, 105592, 112487, 112838},
			[6] = {104519, 105515, 112743},
			[8] = {104541, 105537, 112765},
			[9] = {104465, 104595, 105461, 105591},
			[10] = {104617, 105613, 105841, 112898, 113225},
		}
	},
	{ -- 44
		name = 'Chronomancer Regalia Lookalike',
		description = 'Normal/Heroic',
		setID = 44,
		baseSetID = 43,
		minRequiredLevel = 80,
		expansionID = 5,
		sourceTypes = {6, 1},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[1] = {103751, 103901, 104673, 104900, 105171, 105398, 112424, 112424, 112937, 112937},
			[5] = {103802, 103803, 104693, 104845, 105191, 105343, 105773, 112487, 112487, 112838, 112838},
			[3] = {103808, 103857, 104717, 104810, 105215, 105308, 105797, 112558, 112558, 112790, 112790},
			[6] = {103898, 104768, 105266, 105781, 112743, 112743},
			[8] = {103806, 104790, 105288, 112765, 112765},
			[9] = {103849, 103851, 104714, 104844, 105212, 105342, 105789},
			[10] = {103854, 103970, 104866, 105364, 105827, 112898, 112898, 113225, 113225},
		}
	},
	{ -- 45
		name = 'Chronomancer Regalia Lookalike',
		description = 'Raid Finder',
		setID = 45,
		baseSetID = 43,
		minRequiredLevel = 80,
		expansionID = 5,
		sourceTypes = {6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		modID = 4,
		items = 
		{
			[1] = {104922, 105149, 112424, 112937},
			[3] = {104966, 105059, 112558, 112790},
			[5] = {104942, 105094, 112487, 112838},
			[6] = {105017, 112743},
			[8] = {105039, 112765},
			[9] = {104963, 105093},
			[10] = {105115, 105813, 112898, 113225},
		}
	},
	{ -- 46
		name = 'Corruptor Raiment Lookalike',
		description = '',
		setID = 46,
		minRequiredLevel = 58,
		expansionID = 2,
		sourceTypes = {6},
		armorType = DB.armorTypes.cloth,
		limitedTimeSet = false,
		items = 
		{
			[3] = {30079},
			[5] = {30056},
			[6] = {30064},
			[8] = {30050},
		}
	}
}

