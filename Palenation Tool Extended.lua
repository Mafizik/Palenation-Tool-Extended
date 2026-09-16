
script_name('Palenation Tool Extended') 
script_author('Tima_Mafizik') 
script_version("16.09.2026")
script_moonloader(19)
status_sampev, sampev = pcall(require, 'lib.samp.events')
status_inicfg, inicfg = pcall(require, 'inicfg')
status_moonloader, moonloader = pcall(require, "moonloader")
local copas_success, copas = pcall(require, "copas")
 local status_requests, requests = pcall(require, 'requests')
 local status_hotkey, hotkey = pcall(require, 'plr_mimgui_hotkeys')
 local status_fa, fa = pcall(require, 'fAwesome6_solid')
 local status_addons, imadd = pcall(require, 'plr_mimgui_addons')
 local status_encoding, encoding = pcall(require, 'encoding')
 local wsModuleOk, websocket = pcall(require, "websocket")
local status_memory, memory = pcall(require, "memory")
 local status_imgui, imgui = pcall(require, 'mimgui')
 local status_ffi, ffi = pcall(require, 'ffi')
 local status_keys, keys =  pcall(require, 'vkeys')
local squad_members = {}
local squad_onlines = 0
local squad_pos_x = 0
local help_squad = false
local color_squad = {}
local Russian_Flag = nil
local English_Flag = nil
require"lib.moonloader"
require"lib.sampfuncs"
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
local loading_libraries = false
local target_players = {}
local pr_removed_peds = {}
local wsOperationBusy = false
dlStatus = moonloader.download_status
local list_lib = {
	["plr_mimgui_hotkeys"] = status_hotkey,
	["fAwesome6_solid"] = status_fa,
	["plr_mimgui_addons"] = status_addons,
	["requests"] = status_requests,
	["encoding"] = status_encoding,
	["event"] = status_sampev,
	["ini"] = status_inicfg,
	['memory'] = status_memory,
	['mimgui'] = status_imgui,
	['ffi'] = status_ffi,
	['keys'] = status_keys,
	["websocket"] = wsModuleOk,
    ["copas_success"] = copas_success
}
download_lib = false
	for key, value in pairs(list_lib) do
		if not value then
			download_lib = true
		end
	end
if download_lib then
		local requiredFiles = {
		"base64.dll",
		"cjson.dll",
		"effil.lua",
		"lfs.dll",
		"libeffil.dll",
		"ltn12.lua",
		"mimgui_hotkeys.lua",
		"requests.lua",
		"socket.lua",
		"ssl.dll",
		"ssl.lua",
		"synchronization.lua",
		"vkeys.lua",
		"gauth.lua",
		"plr_mimgui_addons.lua",
		"fAwesome6_solid.lua",
		"plr_mimgui_addons.lua",
		"plr_mimgui_hotkeys.lua",
		"fAwesome6.lua",
		"encoding.lua",
		"websocket.lua",
        "copas.lua",
        copas = {
            "ftp.lua",
            "http.lua",
            "limit.lua",
            "lock.lua",
            "semaphore.lua",
            "smpt.lua",
            "timer.lua",
        },
        websocket = {
            "bit.lua",
            "client.lua",
            "client_copas.lua",
            "client_ev.lua",
            "client_sync.lua",
            "ev_common.lua",
            "frame.lua",
            "handshake.lua",
            "server.lua",
            "server_copas.lua",
            "server_ev.lua",
            "sync.lua",
            "tools.lua",
        },
		cjson = {
			"util.lua",
		},
		lub = {
			"Autoload.lua",
			"init.lua",
		},
		md5 = {
			"core.dll",
		},
		mime = {
			"core.dll",
		},
		mimgui = {
			"cdefs.lua",
			"cimguidx9.dll",
			"dx9.lua",
			"imgui.lua",
			"init.lua",
		},
		samp = {
			"events.lua",
			"raknet.lua",
			"synchronization.lua",
			events = {
				"bitstream_io.lua",
				"core.lua",
				"extra_types.lua",
				"handlers.lua",
				"utils.lua",
			},
		},
		socket = {
			"core.dll",
			"ftp.lua",
			"headers.lua",
			"http.lua",
			"smtp.lua",
			"tp.lua",
			"url.lua",
		},
		ssl = {
			"https.lua",
		},
		xml = {
			"core.dll",
			"init.lua",
			"Parser.lua",
		},
	}
	local githubBaseUrl = "https://github.com/Mafizik"
	local missingFilesList = {}
	local downloadedFilesCount = 0

	function checkAndFindMissingLibraries(currentPath, filesTree)
		for key, value in pairs(filesTree) do
			if type(value) == "table" then
				local fullDirectoryPath = getWorkingDirectory() .. currentPath .. "/" .. key
				if not doesDirectoryExist(fullDirectoryPath) then
					createDirectory(fullDirectoryPath)
				end

				checkAndFindMissingLibraries(currentPath .. "/" .. key, value)
			else
				local fullFilePath = getWorkingDirectory() .. currentPath .. "/" .. value
				if not doesFileExist(fullFilePath) then
					table.insert(missingFilesList, currentPath .. "/" .. value)
				end
			end
		end
	end

	checkAndFindMissingLibraries("/lib", requiredFiles)

	for _, relativeFilePath in pairs(missingFilesList) do
		relativeFilePath2 = relativeFilePath:gsub("lib/", "lib/blob/main/")
		local downloadUrl = githubBaseUrl .. relativeFilePath2 .. "?raw=true"
		local targetLocalPath = getWorkingDirectory() .. relativeFilePath

		downloadUrlToFile(downloadUrl, targetLocalPath, function(id, status, p1, p2)
			if status == dlStatus.STATUSEX_ENDDOWNLOAD then
				downloadedFilesCount = downloadedFilesCount + 1


				if downloadedFilesCount == #missingFilesList then
					thisScript():reload()
				end
			elseif status == dlStatus.STATUSEX_ENDDOWNLOADFAIL then
				downloadedFilesCount = downloadedFilesCount + 1
			end
		end)
	end

end
if status_hotkey then
	hotkey.Text.NoKey = "< нажмите для бинда клавиши >"
end
local autoreptext = {}
local capture_on_command = false
local capture_biz = nil

local lictgiverank = {}
killerId = -1
local healme = false
ffi.cdef[[
    int SetCursorPos(int X, int Y);
]]
sw, sh = getScreenResolution()
local pov = {
  x = sw/2,
  y = sh/(3/4),
}
local fam_check = false

local table_nick_uc = {}
idinvite = 0

autoheal = false
local fmask = false
FIREBASE_URL = "https://pte-samp-default-rtdb.europe-west1.firebasedatabase.app/"
SECONDS_IN_WEEK = 604800
myNick = ""
serverIP = ""
isInitialized = false
hasSentJoinPacket = false
local hudPlayers = {} 

authorization = true
local antiflood = 0
local truck_flooder = false
local truck_choice = false

local function bitwise_xor(a, b) 
	local result = 0 
	local bit = 1 
	while a > 0 or b > 0 do 
	 local a_bit = a % 2 
	 local b_bit = b % 2 
	 if a_bit ~= b_bit then 
	  result = result + bit 
	 end 
	 a = math.floor(a / 2) 
	 b = math.floor(b / 2) 
	 bit = bit * 2 
	end 
	return result 
end

local function xor_decrypt(data, key) 
	local key_len = #key 
	local encrypted = {} 
	for i = 1, #data do 
	 local data_byte = string.byte(data, i) 
	 local key_byte = string.byte(key, (i - 1) % key_len + 1) 
	 local xor_byte = bitwise_xor(data_byte, key_byte) 
	 encrypted[i] = string.char(xor_byte) 
	end 
	return table.concat(encrypted) 
end

local list = {}
list.player = {}
list.authorization = {}
list.date = {}
list.time = {}

local check_users = false
local nawa_inta = 0

local zaxod = true

local open_sklad = false
local help_notifications = false

local cho_gang = "{$CLR}RIFA{FFFFFF}: $CNT {$CLR}GROVE{FFFFFF}: $CNT {$CLR}AZTEC{FFFFFF}: $CNT {$CLR}VAGOS{FFFFFF}: $CNT {$CLR}BALLAS{FFFFFF}: $CNT "
local cho_biker = "{$CLR}MONGOLS{FFFFFF}: $CNT {$CLR}PAGANS{FFFFFF}: $CNT {$CLR}WARLOCKS{FFFFFF}: $CNT "
local cho_maf = "{$CLR}RM{FFFFFF}: $CNT {$CLR}LCN{FFFFFF}: $CNT {$CLR}YAKUZA:{FFFFFF} $CNT"


local flood = false
bflooder = false
mflooder = false
local render_M4 = false
local render_AK47 = false
local render_Deagle = false
new = imgui.new
local check_M4 = true
local check_AK47 = true
local check_Deagle = true
local netfmem = false
local helpeee = false

local check_inventory, drugs_timer, not_drugs_timer, renderText, d = 1, 0, false, {}, {}
local sleep = 0
local check_get_mats = true
local helpfordnk = false
local check_boostinfo = 0

local check_squad_members = false

local helpipi = false

local color_castom_squad = nil

local biz_check = true
local AutoCapterstart = false

local efcs_autoexit = false

local fsafes = false
local fslastd = false
local get_guns_status = false
 
local withdraw = {
    summ = 0,
    process = false,
}

local deposit = {
    summ = 0,
    process = false,
}

local transfer = {
    summ = 0,
    nick = '',
    process = false,
}
--[[local function getCurrentFileContent()
    local response = requests.get(table_url)
    assert(response.status_code == 200, response.status_code .. '\n' .. response.text)
    return json.decode(response.text)
end]]

--local fileInfo = getCurrentFileContent()
--local mass = json.decode(base64.decode(fileInfo.content))
--local sha = fileInfo.sha



local check_rank = false

local warlocks = " - WARLOCKS MC"
local mongols = " - MONGOLS MC"
local pagans = " - PAGANS MC"
encoding.default = 'CP1251'
local u82 = encoding.UTF8
local u8 = encoding.CP1251

safeNumbers = {}
safeGunsTD = {}
fsGunStatus = {}
inputFsafeCode = false
fhouseExist = false
fsClickExist = false
local var_0_8 = false
local var_0_9
local var_0_14 = 4294967295
local var_0_142 = 4294967295
local lines_status = imgui.new.bool(false)

local only_evolv = imgui.new.bool(true)
local time_capt = imgui.new.bool(false)
local radar_lines = imgui.new.bool(false)


id1_status = imgui.new.bool(true)
id2_status = imgui.new.bool(true)
id3_status = imgui.new.bool(true)
id4_status = imgui.new.bool(true)
id5_status = imgui.new.bool(true)
id6_status = imgui.new.bool(true)
id7_status = imgui.new.bool(true)
zone_blueberry = imgui.new.bool(true)
zone_montgomery = imgui.new.bool(true)
zone_palomino_creek = imgui.new.bool(true)
zone_dillimore = imgui.new.bool(true)
zone_fort_carson = imgui.new.bool(true)
zone_las_barrancas = imgui.new.bool(true)
zone_el_quebrados = imgui.new.bool(true)
zone_angel_pine = imgui.new.bool(true)
local var_0_26 = imgui.new.bool(true)
b_var_0_26 = imgui.new.bool(true)
local var_0_27 = imgui.new.int(3)
b_var_0_27 = imgui.new.int(3)
local var_0_28 = imgui.new.int(800)
b_var_0_28 = imgui.new.int(800)
local var_0_30 = imgui.new.int(-9)
b_var_0_30 = imgui.new.int(-9)
local castom_color_squad = imgui.new.float[4](1, 1, 1, 1)
local color_ld = imgui.new.float[4](1, 1, 1, 1)
local help_m4_net = false
local help_deagle_net = false
local help_ak_net = false


local ev0 = imgui.new.int(255)
local ev1 = imgui.new.int(1)
local ev2 = imgui.new.float[4](1, 1, 1, 1)
b_ev0 = imgui.new.int(255)
b_ev1 = imgui.new.int(1) 
b_ev2 = imgui.new.float[4](1, 1, 1, 1)
b_ev2 = imgui.new.float[4](1, 1, 1, 1)
local ev4 = {}
local ev5
local ev6
local var_0_29 = new.int()
b_var_0_29 = new.int()
local type_radar = new.int()
local combotwo = {"Статичный цвет", "Радуга"}
local combo_two = imgui.new['const char*'][#combotwo](combotwo)
local combolist = {"Круглый", "Квадратный"}
local combo_list = imgui.new['const char*'][#combolist](combolist)

local b_type_radar = new.int()
local b_combotwo = {"Статичный цвет", "Радуга"}
local b_combo_two = imgui.new['const char*'][#b_combotwo](b_combotwo)
local b_combolist = {"Круглый", "Квадратный"}
local b_combo_list = imgui.new['const char*'][#b_combolist](b_combolist)

ffi.cdef[[
struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	uint32_t				clKillerColor; // D3DCOLOR
	uint32_t				clVictimColor; // D3DCOLOR
	uint8_t					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
	int 					iLongestNickLength;
  	int 					iOffsetX;
  	int 					iOffsetY;
	void			    	*pD3DFont; // ID3DXFont
	void		    		*pWeaponFont1; // ID3DXFont
	void		   	    	*pWeaponFont2; // ID3DXFont
	void					*pSprite;
	void					*pD3DDevice;
	int 					iAuxFontInited;
    void 		    		*pAuxFont1; // ID3DXFont
    void 			    	*pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]

ffi.cdef("\t\tstruct CVector2D { float x, y; };\n\t\tstruct CVector { float x, y, z; };    \n\t")
ffi.cdef([[

    struct stGangzone
    {
        float    fPosition[4];
        uint32_t    dwColor;
        uint32_t    dwAltColor;
    };

    struct stGangzonePool
    {
        struct stGangzone    *pGangzone[1024];
        int iIsListed[1024];
    };

]])
local ev7 = ffi.cast("void (__cdecl*)(struct CVector2D*, struct CVector2D*)", 5780784)
local ev8 = ffi.cast("void (__cdecl*)(struct CVector2D*, struct CVector2D*)", 5780608)
local ev9 = ffi.cast("bool (__cdecl*)(struct CVector2D*)", 5786944)

local clist_gang = {
	{
        4280979824, -- RIFA
		2852167424, -- GROVE
        3355573503, -- AZTEC
        4294958628, -- VAGOS        
	 	4289926119, -- BALLAS
	}
}

local clist_maf = {
	{
        4290033079, -- RM        
		4292716289, -- LCN
		2868838400, -- YAKUZA
	}
}

local clist_biker = {
	{
        4281545523, -- MONGOLS
        4281110935, -- PAGANS
		4294201344, -- WARLOCKS
	}
}

ffi.cdef [[
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef const char *LPCTSTR;
    HWND GetActiveWindow(void);
    bool SetWindowTextA(HWND hWnd, LPCTSTR lpString);
]]

--------------------------------------------------------------------------------
------------------------------------Save-In-Ini---------------------------------
--------------------------------------------------------------------------------
--#save #ini
directIni = 'Palenation Tool Extended.ini'

possX, possY = convertGameScreenCoordsToWindowScreenCoords(11, 65)
possX2, possY2 = convertGameScreenCoordsToWindowScreenCoords(110, 90)
possX3, possY3 = convertGameScreenCoordsToWindowScreenCoords(100, 80)
posX, posY = convertGameScreenCoordsToWindowScreenCoords(88.081993103027, 322.58331298828)
PosSquadX, PosSquadY = convertGameScreenCoordsToWindowScreenCoords(4, 177)
PosUcX, PosUcY = convertGameScreenCoordsToWindowScreenCoords(4, 100)
math.randomseed(os.time())
autoreport_random = math.random(1000, 5000)
config = {}
config.data = {}
config.default = {
	["Default_nickname"] = {
		settings = {
			nickname = "",
		}
	},
	["Default"] = {
	language = {
		number = 1
	},
	--#render
    render = {
        font = 'Segoe UI',
        size = 10,
        flag = 13,
        align = 2,
        x = posX,
        y = posY,
        height = 4
    },
	--#drugtimer #narkotimer
    drugtimer = {
        hp = 160,
        hp_one_gram = 10, 
        max_use_gram = 16,
        seconds = 60,
        status = false,
        drugs = 0,
        mats = 0,
        server_cmd = 'usedrugs',
        inventory = true,
        boostinfo = true,
        key = {},
        death = false,
		int = 3,
    },
	--#lines
    lines = {
        one = '{1a9614}drugs !a!n{dedede}mats !m',
        two = '{e81526}cooldown !s!n{dedede}mats !m'
    },
	--#fastcarfx #fc 
    fastcarfx = {
        status = false,
        status_exit = false,
        key = {}
    },
	--#autocapt #capter
    AutoCapt = {
        status = false,
        key = {},
        wait = 1000,
        biz = 1,
        com = "",
		flooder_com = "flood",
		flooder_status = false,
		autodrug = false,
		bautocapt = "bcapture",
		mautocapt = "mcapture"
    },
	--#fsafe #safe
    fsafe = {
        status = false,
        key = {},
        shotgun = 0,
        deagle = 0,
        rifle = 0,
        pin = 9999,
        drugs = 0,
		take_drugs = 500,
        wait = 75,
        ak = 0,
        m4 = 0,
		drugs_status = false,
		dnkdrugs_status = false,
		dnk_status = false,
	--	dnk_key = "[]",
		dnk_shotgun = 0,
        dnk_deagle = 0,
        dnk_rifle = 0,
        dnk_pin = 9999,
        dnk_wait = 75,
		dnk_ak = 0,
        dnk_m4 = 0
    },
	--#gg #getguns
    getguns = {
        status = false,
        key = {},
        ak = 0,
        m4 = 0,
        deagle = 0,
        rifle = 0,
        shotgun = 0,
		armor = false,
        auto_get_drink = true,
        auto_get_drugs = true,
		mafia_status = false,
		mafia_shotgun = 0,
		mafia_m4 = 0,
		mafia_rifle = 0,
		mafia_key = {},
		mafia_deagle = 0,
		autoheal = false
    },
	--#ld #leadermanagement
    LeaderManagement = {
		warehouse_request = false,
    },
	--#eblochecker #checker
    eblochecker = {
        gang_status = false,
        gang_stream = false,
        x_gang = posX - 352,
        y_gang = posY - 237,
        maf_status = false,
        maf_stream = false,
        x_maf = posX - 352,
        y_maf = posY - 117,
        biker_status = false,
        biker_stream = false,
        x_biker = posX - 352,
        y_biker = posY - 37,
        style = 0,
		families = false,
		fam_status = false,
		statuses = false,
		status = true
    },
	statuses = {
		x = possX2,
		y = possY2,
	},
	families = {
		x = possX3,
		y = possY3,
	},

	--#sbiv
    small_tweaks = {
        autoinv = false,
		autogiverank = false,
		antiafk = false,
		antiafk_cmd = "pafk",
		collision = false,
		collision_all = false,
		car = false,
		spawncar = false,
        takegun = false,
		smuggler = false,
        sbiv_status = false,
		sbiv_int = 0,
        sbiv_key = {82},
		truck = false,
		truck_command = "amat",
		autoheal = false,
	    driftmod_status = false,
		driftmod_speed = 0.2,
        driftmod_key = {16},
		bank = true,
		pmask = true,
		otkat = false,
		exit = true,
		pautogiverank = true,
		notifications = true,
    },
	--#mafialines
    mafialines = {
		onlyServer = only_evolv[0],
		onlyCapture = time_capt[0],
		radarRender = radar_lines[0],
		radarMode = type_radar[0],
		width = var_0_27[0],
		distancedraw = var_0_28[0],
		color = encodeJson({
			ev2[0],
			ev2[1],
			ev2[2],
			ev2[3]
		}),
		rainbowc = var_0_26[0],
		mode = var_0_29[0],
		trailalpha = ev0[0],
		trailspeed = ev1[0],
		activated = lines_status[0],
		quarryed = id1_status[0],
		villaged = id2_status[0],
		airported = id3_status[0],
		mined = id4_status[0],
		buildinged = id5_status[0],
        piligrim = id6_status[0],
        rokwor = id7_status[0],
		render_height = var_0_30[0],
		kv_render = false,
		kv_x = 500,
		kv_y = 500,
	},

	bikerlines = {
		radarRender = false,
		width = b_var_0_27[0],
		distancedraw = b_var_0_28[0],
		color = encodeJson({
			b_ev2[0],
			b_ev2[1],
			b_ev2[2],
			b_ev2[3]
		}),
		rainbowc = b_var_0_26[0],
		mode = b_var_0_29[0],
		trailalpha = b_ev0[0],
		trailspeed = b_ev1[0],
		activated = false,
        zone_blueberry = zone_blueberry[0],
		zone_montgomery = zone_montgomery[0],
		zone_palomino_creek = zone_palomino_creek[0],
		zone_dillimore = zone_dillimore[0],
		zone_fort_carson = zone_fort_carson[0],
		zone_las_barrancas = zone_las_barrancas[0],
		zone_el_quebrados = zone_el_quebrados[0],
		zone_angel_pine = zone_angel_pine[0],
		render_height = b_var_0_30[0],
		kv_render = false,
		kv_x = 500,
		kv_y = 500,
	},

	
	autogetguns = {
		status = false,
	},
	--#squad
	squad = {
		status = false,
		x_pos = PosUcX,
		y_pos = PosUcY,
        font = 'Arial',
        size = 12,
        flag = 13,
		online_status = false,
		int = 2,
		rank = 0,
		name_squad = 1,
		color = 4294967295,
		language = 0,
		players = true,
		intfont = 0,
	},


	delete_melee_weapon = {
		status = false,
		bat = true,
		kiy = true,
		katana = true,
		stick = true,
		knuckles = true,
	},

	users = {
		status = false,
		x_pos = PosSquadX,
		y_pos = PosSquadY,
        font = 'Arial',
        size = 12,
        flag = 5,
		online_status = false,
		int = 2,
		rank = 0,
		name_squad = 1,
		color = 4294967295,
		language = 0,
		line = 19,
		wapka2 = "Пользователи онлайн:",
	},

	clickwarp = {
		status = false,
		cmd = "cw"
	},

	dlcar = {
        status = false,
        dist = 20,
    },
    perevorot = {
        status = false,
        key_one = {219},
        key_two = {221},
        speed = 15,
    },

	good_drive = {
		status = false,
		cmd = "gd",
	},
	bank = {
		withdraw = "bwd",
		transfer = "btr",
		deposit = "bdp",
	},

	--[[AutoLomka = {
        Command = "ptelomka",
    },

	AutoSkill = {
		Command = "pteskills",
	},

    FullCycle = {
        Command = "ptebotsall",
    },]]

    autoschool = {
        status = true,
		playeer_remove = false,
    },
	render_gun = {
		render = false,
        x = 25,
        y = 120,
		font = "Tahoma",
		size = 10,
		flag = 5,
		color = 4294967295,
		int = 2,
	},

	bikerlist = {
        status = true,
        command = "/bikerlist",
        key = {}
    },

	pr = {
		status = false,
		marker = false,
		family = false,
		aztec = false,
		ballac = false,
		grove = false,
		rifa = false,
		vagos = false,
		lcn = false,
		yakudza = false,
		rm = false,
		mongols = false,
		pagans = false,
		warlocks = false,
		bich = false,
	},
	autoreport = {
        status = false,
        wait = autoreport_random,
		capture = true,
        list_prichin = {
            "aim",
            "aimbot",
            "salo",
            "fast anim",
            "bpl",
			"наводка",
            "fast deagle",
			"cheat", 
			"нпсит",
			"стрельба сбивом",
            "аимит",
			"нарушает",
            "аимботик",
			"вх",
			"wh",
			"чит",
			"читер",
			"читак nps",
			"+C",
			"нпс",
			"сбив",
			"саим",
			"вне кв",
			"аим",
			"фастит",
			"аимбот",
			"nps",
			"бреет",
			"сбил анимку",
			"подрубил",
			"все попадает",
			"fbv",
			"нрп",
			"фшь",
			"cало"
        }
    },
	flashlight = {
        status = false,
		dist = 100,
    },

	ReplacingWindowWithNickName = {
        status = false,
    },

	remove_fence = {
        status = false,
        dist_onfoot = 100,
        dist_car = 100,
    },

	hideweapon = {
        status = false,
    },

	camhack = {
        status = false,
        key = {17, 49},
        bubble = false,
        antiwarning = true,
		xyi = true
    },

	marker = {
		key = {74},
		status = true,
	},
	
    id_killlist = {
        status = false,
    },

    glonass = {
        status = true,
        key = {77},
        size = 900,
        font = 1,
        nick = 8,
        hp = 10,
        marker_size = 24,
        matavoz_size = 36,
        people_size = 20,
        tip = 1,
        marker = 0,
    },

	NoInteriorFreeze = {
		status = true
	},

	hidechar = {
		status = true,
	},

    adminchecker = {
        status = false,
    }
},
}
config.directory = getWorkingDirectory().."\\Palenation Tool Extended"
-- =========================
-- SAFE PROFILE / CONFIG HELPERS
-- =========================
local function deepCopy(value, seen)
    if type(value) ~= "table" then
        return value
    end
    seen = seen or {}
    if seen[value] then
        return seen[value]
    end
    local copy = {}
    seen[value] = copy
    for k, v in pairs(value) do
        copy[deepCopy(k, seen)] = deepCopy(v, seen)
    end
    return copy
end

-- SA-MP иногда на короткое время возвращает локальный ник в виде
-- "Nickname(ID)". ID не является частью профиля, поэтому никогда
-- не используем его как отдельное имя секции в settings.json.
local function normalizeProfileNick(nicko)
    if type(nicko) ~= "string" then
        return nicko
    end

    -- Убираем случайные пробелы и временный SA-MP суффикс вида (711).
    -- Например: "Chechenzo_Montgomery(429)" -> "Chechenzo_Montgomery".
    -- Обычные скобки внутри ника не затрагиваются.
    normalized = nicko:gsub("^%s+", ""):gsub("%s+$", "")
    normalized = normalized:gsub("%s*%(%d+%)$", "")
    normalized = normalized:gsub("%s+$", "")
    return normalized
end

-- Чистит уже существующие профили вида Nickname(ID).
-- Если нормальный профиль уже есть, временный просто удаляется.
-- Если нормального профиля нет, настройки временного профиля переносятся
-- под нормальное имя, чтобы пользователь ничего не потерял.
local function cleanupProfileNames()
    if type(config.data) ~= "table" then
        return false
    end

    local changed = false
    local toRemove = {}
    local toRename = {}

    for key, value in pairs(config.data) do
        if key ~= "Default" and key ~= "Default_nickname" and key ~= "Default_int" then
            local normalized = normalizeProfileNick(key)
            if normalized ~= key and normalized ~= "" then
                if config.data[normalized] ~= nil then
                    -- Нормальный профиль уже существует. Сохраняем именно его.
                    table.insert(toRemove, key)
                else
                    -- Нормального профиля нет: переносим существующие настройки.
                    table.insert(toRename, { old = key, new = normalized, value = value })
                end
            end
        end
    end

    for _, key in ipairs(toRemove) do
        config.data[key] = nil
        changed = true
    end

    for _, item in ipairs(toRename) do
        if config.data[item.new] == nil then
            config.data[item.new] = item.value
        end
        config.data[item.old] = nil
        changed = true
    end

    -- Если главный ник когда-то тоже сохранился с (ID), исправляем ссылку.
    local selected = config.data["Default_nickname"]
        and config.data["Default_nickname"].settings
        and config.data["Default_nickname"].settings.nickname

    if selected then
        local normalized = normalizeProfileNick(selected)
        if normalized ~= selected then
            config.data["Default_nickname"].settings.nickname = normalized
            changed = true
        end
    end

    return changed
end

local function getDefaultProfile()
    local selected = config.data
        and config.data["Default_nickname"]
        and config.data["Default_nickname"].settings
        and normalizeProfileNick(config.data["Default_nickname"].settings.nickname)

    if selected and selected ~= "" and config.data[selected] then
        return config.data[selected]
    end

    return config.data["Default"] or config.default["Default"]
end

local function ensureProfile(nick)
    nick = normalizeProfileNick(nick)

    if not nick or nick == "" then
        return false
    end

    if config.data[nick] ~= nil then
        return false
    end

    -- Новый аккаунт получает НЕ ссылку, а независимую копию
    -- настроек выбранного главного ника.
    config.data[nick] = deepCopy(getDefaultProfile())
    config_save(config.data)
    return true
end

function config_init()
    if not doesDirectoryExist(config.directory) then
        createDirectory(config.directory)
    end

    config.address = string.format("%s\\settings.json", config.directory)
    config.backup = string.format("%s\\settings.json.bak", config.directory)
    config.temp = string.format("%s\\settings.json.tmp", config.directory)

    if not doesFileExist(config.address) then
        config.data = deepCopy(config.default)
        config_save(config.data)
    else
        config_read()
    end

    if type(config.data) ~= "table" then
        config.data = deepCopy(config.default)
        config_save(config.data)
    end

    -- Добавляем только отсутствующие ключи/параметры.
    -- Уже сохраненные значения пользователя никогда не заменяем дефолтами.
    local function mergeConfigs(defaultTable, dataTable)
        if type(defaultTable) ~= "table" or type(dataTable) ~= "table" then
            return
        end

        for k, v in pairs(defaultTable) do
            if dataTable[k] == nil then
                dataTable[k] = deepCopy(v)
            elseif type(v) == "table" and type(dataTable[k]) == "table" and k ~= "binder" then
                mergeConfigs(v, dataTable[k])
            end
        end
    end

    -- Сначала обновляем сам служебный Default-профиль.
    mergeConfigs(config.default, config.data)

    -- ВАЖНО: config.data содержит отдельные профили пользователей.
    -- Раньше mergeConfigs() проходил только по верхнему уровню config.data,
    -- поэтому новый параметр из config.default.Default (например camhack.xyi)
    -- попадал в Default, но не в уже существующие профили.
    --
    -- Теперь каждый пользовательский профиль получает все новые параметры
    -- из config.default.Default, при этом его сохраненные значения не меняются.
    local defaultProfile = config.default["Default"]
    if type(defaultProfile) == "table" then
        for profileName, profileData in pairs(config.data) do
            if profileName ~= "Default"
                and profileName ~= "Default_nickname"
                and profileName ~= "Default_int"
                and type(profileData) == "table" then
                mergeConfigs(defaultProfile, profileData)
            end
        end
    end

    -- Убираем уже накопившиеся профили Nickname(ID) и нормализуем
    -- выбранный главный ник. Это выполняется один раз при загрузке.
    cleanupProfileNames()
    config_save(config.data)
end

function config_save(data, force_full, deleted_profiles)
    if type(data) ~= "table" or not config.address then
        return false
    end

    -- ВАЖНО: несколько копий PTE могут одновременно использовать один
    -- settings.json. Нельзя делать wait() или busy-wait здесь: config_save()
    -- вызывается в том числе во время config_init(), а блокировка потока
    -- приводит к зависанию SA-MP.
    -- Вместо этого перед каждым обычным сохранением перечитываем актуальный
    -- settings.json и заменяем только профиль текущего аккаунта.
    local function readLatest(path)
        local file = io.open(path, "r")
        if not file then
            return nil
        end
        local text = file:read("*a")
        io.close(file)
        if not text or text:gsub("%s", "") == "" then
            return nil
        end
        local ok, decoded = pcall(decodeJson, text)
        if ok and type(decoded) == "table" then
            return decoded
        end
        return nil
    end

    local function mergeMissing(dst, src)
        if type(dst) ~= "table" or type(src) ~= "table" then
            return
        end
        for k, v in pairs(src) do
            if dst[k] == nil then
                dst[k] = deepCopy(v)
            elseif type(dst[k]) == "table" and type(v) == "table" then
                mergeMissing(dst[k], v)
            end
        end
    end

    local latest = readLatest(config.address)

    -- Для удаления профиля нельзя полагаться только на обычный config_save().
    -- Он специально сохраняет остальные профили из свежего settings.json,
    -- поэтому удаленный ключ иначе снова появится из latest.
    if type(latest) == "table" and type(deleted_profiles) == "table" then
        for _, profileName in ipairs(deleted_profiles) do
            profileName = normalizeProfileNick(profileName)
            if profileName and profileName ~= ""
                and profileName ~= "Default"
                and profileName ~= "Default_nickname"
                and profileName ~= "Default_int" then
                latest[profileName] = nil
            end
        end
    end

    if type(latest) == "table" then
        if not force_full then
            local currentNick = nil
            if type(mynick) == "function" then
                local okNick, nick = pcall(mynick)
                if okNick and type(nick) == "string" then
                    currentNick = normalizeProfileNick(nick)
                end
            end

            if currentNick and currentNick ~= "" and type(data[currentNick]) == "table" then
                -- Обновляем только текущий профиль. Профили других аккаунтов
                -- берутся из свежего settings.json и поэтому не затираются.
                latest[currentNick] = deepCopy(data[currentNick])

                -- Если текущий аккаунт является выбранным "Дефолт настройками",
                -- его изменения должны одновременно обновлять базовый профиль
                -- Default. Иначе новые аккаунты продолжат получать старую копию.
                local defaultNick = nil
                if type(data.Default_nickname) == "table"
                    and type(data.Default_nickname.settings) == "table" then
                    defaultNick = normalizeProfileNick(data.Default_nickname.settings.nickname)
                end
                if defaultNick == currentNick and type(data[currentNick]) == "table" then
                    latest.Default = deepCopy(data[currentNick])
                end

                -- Сохраняем общий служебный параметр, если он присутствует.
                if type(data.Default_nickname) == "table" then
                    latest.Default_nickname = deepCopy(data.Default_nickname)
                elseif data.Default_nickname ~= nil then
                    latest.Default_nickname = deepCopy(data.Default_nickname)
                end
            else
                -- Во время config_init() mynick() ещё может быть недоступен.
                -- В этом случае добавляем только отсутствующие ключи.
                mergeMissing(latest, data)
            end
        else
            -- Полное сохранение используется только для инициализации/
            -- восстановления. Не удаляем при этом профили, появившиеся
            -- из другой копии скрипта.
            mergeMissing(latest, data)
        end
    end

    local saveData = latest or data
    local raw_json = encodeJson(saveData)
    if not raw_json then
        print("[PTE] Ошибка сериализации settings.json")
        return false
    end

    local result = {}
    local indent = 0
    local in_string = false
    local escape = false

    for i = 1, #raw_json do
        local char = raw_json:sub(i, i)

        if in_string then
            table.insert(result, char)
            if escape then
                escape = false
            elseif char == "\\" then
                escape = true
            elseif char == '"' then
                in_string = false
            end
        else
            if char == '"' then
                in_string = true
                table.insert(result, char)
            elseif char == '{' or char == '[' then
                indent = indent + 1
                table.insert(result, char .. "\n" .. string.rep("\t", indent))
            elseif char == '}' or char == ']' then
                indent = indent - 1
                local last = #result
                if result[last] == "\t" or result[last]:match("^\t+$") then
                    table.remove(result)
                end
                table.insert(result, "\n" .. string.rep("\t", indent) .. char)
            elseif char == ',' then
                table.insert(result, char .. "\n" .. string.rep("\t", indent))
            elseif char == ':' then
                table.insert(result, char .. " ")
            else
                table.insert(result, char)
            end
        end
    end

    local final_str = table.concat(result):gsub("%{\n%s*%}", "{}"):gsub("%[\n%s*%]", "[]")

    local tmp = config.temp or (config.address .. ".tmp")
    local backup = config.backup or (config.address .. ".bak")

    local file, err = io.open(tmp, "w")
    if not file then
        print("[PTE] Не удалось записать временный config: " .. tostring(err))
        return false
    end

    local ok, writeErr = pcall(function()
        file:write(final_str)
        file:flush()
        io.close(file)
    end)

    if not ok then
        pcall(function() io.close(file) end)
        os.remove(tmp)
        print("[PTE] Ошибка записи config: " .. tostring(writeErr))
        return false
    end

    os.remove(backup)
    if doesFileExist(config.address) then
        os.rename(config.address, backup)
    end

    local renamed = os.rename(tmp, config.address)
    if not renamed then
        os.remove(config.address)
        if doesFileExist(backup) then
            os.rename(backup, config.address)
        end
        os.remove(tmp)
        print("[PTE] Не удалось заменить settings.json")
        return false
    end

    return true
end

function config_read()
    local function readFile(path)
        local file = io.open(path, "r")
        if not file then
            return nil
        end
        local text = file:read("*a")
        io.close(file)
        if not text or text:gsub("%s", "") == "" then
            return nil
        end
        local ok, data = pcall(decodeJson, text)
        if ok and type(data) == "table" then
            return data
        end
        return nil
    end

    local data = readFile(config.address)
    if data then
        config.data = data
        config.error = false
        return true
    end

    -- Поврежденный/пустой основной файл больше НЕ заменяет настройки дефолтами.
    -- Сначала восстанавливаем последнюю рабочую копию.
    if config.backup and doesFileExist(config.backup) then
        local backupData = readFile(config.backup)
        if backupData then
            config.data = backupData
            config.error = true
            config_save(config.data)
            return true
        end
    end

    -- Только если рабочих данных вообще нет, создаем чистый конфиг.
    config.data = deepCopy(config.default)
    config.error = true
    config_save(config.data)
    return true
end
config_init()


local renderpatron = {
    cfg = {},
    FamilySafeInfo = {
        de = 0,
        ak = 0,
        m4 = 0,
        sh = 0,
        ri = 0
    },

    tdCache = {},

    font = renderCreateFont("Tahoma", 10, 5)
}

function IsNearZero(a, b)
    return math.abs(a - b) < 0.5
end

function shouldDraw(value)
    if value < 1000 then
        local phase = os.clock() % 1.0
        return phase < 0.70
    end
    return true
end

function saveConfig()
    config.data[mynick()].render_gun.render = renderpatron.cfg.render[0]

    config_save(config.data)
end

function UpdateSafeAmmo(td)
    if not td then return end

    local text = td.text or ""

    if IsNearZero(261.7994, td.position.x)
    and IsNearZero(191.2850, td.position.y) then
        local ammo = text:match("(%d+)%/%d+")
        if ammo then renderpatron.FamilySafeInfo.de = tonumber(ammo) end
    end

    if IsNearZero(367.7662, td.position.x)
    and IsNearZero(191.2850, td.position.y) then
        local ammo = text:match("(%d+)%/%d+")
        if ammo then renderpatron.FamilySafeInfo.ak = tonumber(ammo) end
    end

    if IsNearZero(332.4328, td.position.x)
    and IsNearZero(191.2850, td.position.y) then
        local ammo = text:match("(%d+)%/%d+")
        if ammo then renderpatron.FamilySafeInfo.m4 = tonumber(ammo) end
    end

    if IsNearZero(402.7662, td.position.x)
    and IsNearZero(191.2850, td.position.y) then
        local ammo = text:match("(%d+)%/%d+")
        if ammo then renderpatron.FamilySafeInfo.sh = tonumber(ammo) end
    end

    if IsNearZero(297.1326, td.position.x)
    and IsNearZero(231.6517, td.position.y) then
        local ammo = text:match("(%d+)%/%d+")
        if ammo then renderpatron.FamilySafeInfo.ri = tonumber(ammo) end
    end
end


local capture_status = false
--------------------------------------------------------------------------------
-------------------------------------For-Window---------------------------------
--------------------------------------------------------------------------------


if status_addons then imgui.ToggleButton = require('plr_mimgui_addons').ToggleButton end

local Menu = new.bool()
local BikerlistMenu = new.bool()
sizeof = ffi.sizeof
str = ffi.string

local AI_PAGE = {}
local page = 1

efcs = {}
efcs.list_create = {}
efcs.list_remove = {}
efcs.start = 0

ToU32 = imgui.ColorConvertFloat4ToU32
gg_evolve = {}
 
local getguns = {}
local fsafe = {}


function sort_by_count(t)
    local sorted = {}
    for _, v in pairs(t) do
        table.insert(sorted, v)
    end
    table.sort(sorted, function(a, b)
        return a.count > b.count
    end)
    return sorted
end


local script_enabled = imgui.new.bool()
local window_enabled = imgui.new.bool()


local statuses = {}
local families = {}
script_enabled[0] = true



ffi.cdef [[
    int __stdcall VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
]]


--------------------------------------------------------------------------------
------------------------------------MAFIALINES----------------------------------
--------------------------------------------------------------------------------

function set_areas_by_server(servak)
	if servak == "Saint-Louis" then
		zone_blueberry2 = {
	{
		z = 3.3571,
		x = 355.5124,
		y = -269.8308
	},
	{
		z = 7.6701,
		x = 355.5081,
		y = -247.6185
	},
	{
		z = 7.3414,
		x = 355.4475,
		y = -239.0429
	},
	{
		z = 5.7159,
		x = 355.3877,
		y = -230.7417
	},
	{
		z = 6.4812,
		x = 355.2985,
		y = -218.1298
	},
	{
		z = 6.1694,
		x = 355.2801,
		y = -215.588
	},
	{
		z = 6.9681,
		x = 355.2583,
		y = -212.4259
	},
	{
		z = 8.3275,
		x = 354.9937,
		y = -175.0912
	},
	{
		z = 6.8344,
		x = 354.9354,
		y = -166.979
	},
	{
		z = 6.3123,
		x = 354.9047,
		y = -162.7271
	},
	{
		z = 1.8534,
		x = 354.8369,
		y = -152.0165
	},
	{
		z = 1.9436,
		x = 355.2636,
		y = -132.6299
	},
	{
		z = 1.9243,
		x = 355.3118,
		y = -131.2371
	},
	{
		z = 4.6056,
		x = 355.5004,
		y = -127.2016
	},
	{
		z = 5.416,
		x = 355.5518,
		y = -124.5879
	},
	{
		z = 4.6122,
		x = 355.6046,
		y = -121.8991
	},
	{
		z = 1.2809,
		x = 355.6305,
		y = -120.6047
	},
	{
		z = 1.2654,
		x = 355.6779,
		y = -118.1706
	},
	{
		z = 1.4134,
		x = 356.5313,
		y = -62.7528
	},
	{
		z = 6.266,
		x = 357.416,
		y = 19.9541
	},
	{
		z = 6.2987,
		x = 357.5025,
		y = 24.7134
	},
	{
		z = 6.3283,
		x = 357.3393,
		y = 27.1731
	},
	{
		z = 6.3747,
		x = 326.8081,
		y = 26.3947
	},
	{
		z = 3.5717,
		x = 305.8532,
		y = 26.1956
	},
	{
		z = 2.5669,
		x = 288.169,
		y = 25.795
	},
	{
		z = 2.4429,
		x = 278.0686,
		y = 25.4226
	},
	{
		z = 2.4315,
		x = 276.779,
		y = 25.3662
	},
	{
		z = 6.8531,
		x = 274.1392,
		y = 25.0959
	},
	{
		z = 8.1396,
		x = 255.81,
		y = 25.3197
	},
	{
		z = 2.4493,
		x = 254.3667,
		y = 25.2801
	},
	{
		z = 2.5717,
		x = 243.495,
		y = 25.3201
	},
	{
		z = 2.5781,
		x = 242.3493,
		y = 25.5219
	},
	{
		z = 2.5708,
		x = 209.1448,
		y = 25.8196
	},
	{
		z = 2.4297,
		x = 200.7659,
		y = 25.3755
	},
	{
		z = 1.3078,
		x = 137.1242,
		y = 26.565
	},
	{
		z = 1.1157,
		x = 129.7349,
		y = 24.5157
	},
	{
		z = 1.5554,
		x = 127.8259,
		y = -26.1861
	},
	{
		z = 1.5858,
		x = 127.3255,
		y = -63.8571
	},
	{
		z = 1.5781,
		x = 127.3689,
		y = -70.3428
	},
	{
		z = 1.4297,
		x = 128.362,
		y = -131.2543
	},
	{
		z = 1.4297,
		x = 128.2759,
		y = -134.4769
	},
	{
		z = 1.5781,
		x = 113.3993,
		y = -134.1375
	},
	{
		z = 1.5821,
		x = 107.8869,
		y = -137.7366
	},
	{
		z = 0.6627,
		x = 49.9167,
		y = -135.9141
	},
	{
		z = 0.6094,
		x = 18.6489,
		y = -139.1693
	},
	{
		z = 1.5849,
		x = 18.1348,
		y = -197.0941
	},
	{
		z = 1.5478,
		x = 18.0823,
		y = -218.3689
	},
	{
		z = 2.546,
		x = 18.225,
		y = -219.63
	},
	{
		z = 2.5443,
		x = 18.226,
		y = -291.0854
	},
	{
		z = 2.5444,
		x = 18.225,
		y = -344.991
	},
	{
		z = 5.4737,
		x = 18.3254,
		y = -358.4097
	},
	{
		z = 5.9876,
		x = 55.8737,
		y = -360.3459
	},
	{
		z = 5.3315,
		x = 112.3267,
		y = -361.049
	},
	{
		z = 4.3081,
		x = 161.3846,
		y = -361.382
	},
	{
		z = 4.6829,
		x = 195.6444,
		y = -361.9248
	},
	{
		z = 4.4818,
		x = 202.3666,
		y = -359.5683
	},
	{
		z = 2.8884,
		x = 202.1521,
		y = -345.8137
	},
	{
		z = 4.9199,
		x = 202.1584,
		y = -345.1548
	},
	{
		z = 1.5781,
		x = 202.153,
		y = -343.3527
	},
	{
		z = 5.0234,
		x = 202.2724,
		y = -340.8846
	},
	{
		z = 1.9809,
		x = 202.3359,
		y = -330.6309
	},
	{
		z = 1.4306,
		x = 202.5166,
		y = -286.2332
	},
	{
		z = 1.5781,
		x = 202.8757,
		y = -273.1897
	},
	{
		z = 1.5781,
		x = 242.0913,
		y = -273.5067
	},
	{
		z = 1.5781,
		x = 243.6938,
		y = -273.5481
	},
	{
		z = 1.5836,
		x = 248.8396,
		y = -273.6479
	},
	{
		z = 4.6077,
		x = 250.0278,
		y = -273.6331
	},
	{
		z = 4.0571,
		x = 252.7708,
		y = -273.5316
	},
	{
		z = 1.5781,
		x = 253.5114,
		y = -273.2831
	},
	{
		z = 1.5781,
		x = 273.3654,
		y = -273.2785
	},
	{
		z = 2.4687,
		x = 278.0128,
		y = -273.2785
	},
	{
		z = 4.7594,
		x = 316.2863,
		y = -272.8071
	},
	{
		z = 5.9347,
		x = 319.435,
		y = -272.7474
	},
	{
		z = 6.0013,
		x = 332.6071,
		y = -272.4984
	},
	{
		z = 5.0591,
		x = 344.3316,
		y = -272.2776
	},
	{
		z = 3.6949,
		x = 352.0224,
		y = -272.1328
	},
	{
		z = 3.1088,
		x = 355.438,
		y = -271.9113
	},
	{
		z = 3.1094,
		x = 355.4969,
		y = -271.8228
	},
	{
		z = 3.393,
		x = 355.5171,
		y = -269.5384
	}
}

zone_montgomery2 = {
	{
		z = 24.9089,
		x = 1180.7961,
		y = 396.9927
	},
	{
		z = 22.0369,
		x = 1181.0624,
		y = 387.058
	},
	{
		z = 20.9095,
		x = 1181.708,
		y = 362.3139
	},
	{
		z = 22.8589,
		x = 1181.7159,
		y = 354.5936
	},
	{
		z = 22.1399,
		x = 1181.6454,
		y = 344.0515
	},
	{
		z = 21.045,
		x = 1181.5469,
		y = 325.2363
	},
	{
		z = 19.7075,
		x = 1181.4933,
		y = 314.8123
	},
	{
		z = 18.6736,
		x = 1181.4763,
		y = 311.3222
	},
	{
		z = 19.1548,
		x = 1181.439,
		y = 300.2183
	},
	{
		z = 19.1512,
		x = 1181.4646,
		y = 266.3591
	},
	{
		z = 19.5318,
		x = 1181.6248,
		y = 235.078
	},
	{
		z = 22.0012,
		x = 1181.8593,
		y = 188.043
	},
	{
		z = 22.1716,
		x = 1181.9745,
		y = 168.091
	},
	{
		z = 22.8309,
		x = 1182.0286,
		y = 157.3602
	},
	{
		z = 22.0988,
		x = 1182.0758,
		y = 149.3373
	},
	{
		z = 21.8927,
		x = 1182.3467,
		y = 143.2629
	},
	{
		z = 24.0756,
		x = 1185.1976,
		y = 136.6704
	},
	{
		z = 22.3476,
		x = 1198.4771,
		y = 136.2657
	},
	{
		z = 20.8382,
		x = 1206.2158,
		y = 136.0301
	},
	{
		z = 22.5563,
		x = 1207.6172,
		y = 136.0931
	},
	{
		z = 20.5464,
		x = 1209.683,
		y = 136.0245
	},
	{
		z = 20.3759,
		x = 1228.9067,
		y = 135.7008
	},
	{
		z = 20.2706,
		x = 1263.7327,
		y = 135.4208
	},
	{
		z = 20.4745,
		x = 1277.7186,
		y = 135.3797
	},
	{
		z = 23.4609,
		x = 1279.8776,
		y = 135.2392
	},
	{
		z = 20.4609,
		x = 1281.1898,
		y = 135.47
	},
	{
		z = 20.4079,
		x = 1312.0829,
		y = 136.2871
	},
	{
		z = 23.3894,
		x = 1313.0913,
		y = 136.3902
	},
	{
		z = 20.4872,
		x = 1314.7255,
		y = 136.3843
	},
	{
		z = 21.111,
		x = 1325.5682,
		y = 136.3445
	},
	{
		z = 22.7457,
		x = 1345.2805,
		y = 136.2961
	},
	{
		z = 21.5923,
		x = 1382.6731,
		y = 136.3575
	},
	{
		z = 21.6417,
		x = 1412.7017,
		y = 136.6327
	},
	{
		z = 22.4864,
		x = 1428.2908,
		y = 136.8613
	},
	{
		z = 22.7665,
		x = 1436.6871,
		y = 136.8546
	},
	{
		z = 21.5714,
		x = 1436.6217,
		y = 147.8728
	},
	{
		z = 22.2733,
		x = 1436.78,
		y = 158.7744
	},
	{
		z = 23.4787,
		x = 1436.8635,
		y = 171.8802
	},
	{
		z = 22.0429,
		x = 1437.007,
		y = 194.6464
	},
	{
		z = 18.225,
		x = 1437.0562,
		y = 202.0671
	},
	{
		z = 18.9619,
		x = 1437.0986,
		y = 210.2628
	},
	{
		z = 19.509,
		x = 1437.1432,
		y = 223.3961
	},
	{
		z = 19.5547,
		x = 1437.2345,
		y = 227.0794
	},
	{
		z = 19.5618,
		x = 1436.4827,
		y = 241.1653
	},
	{
		z = 19.5547,
		x = 1436.5811,
		y = 242.4989
	},
	{
		z = 19.4979,
		x = 1436.0067,
		y = 278.7977
	},
	{
		z = 18.8438,
		x = 1435.4932,
		y = 320.6259
	},
	{
		z = 18.8417,
		x = 1435.4742,
		y = 335.44
	},
	{
		z = 22.1309,
		x = 1435.8188,
		y = 335.6874
	},
	{
		z = 22.0974,
		x = 1435.8239,
		y = 342.1114
	},
	{
		z = 18.8417,
		x = 1435.8239,
		y = 343.6503
	},
	{
		z = 18.871,
		x = 1436.4839,
		y = 393.5475
	},
	{
		z = 19.2208,
		x = 1434.4437,
		y = 398.7532
	},
	{
		z = 19.7542,
		x = 1408.5486,
		y = 398.9632
	},
	{
		z = 19.7578,
		x = 1407.1637,
		y = 398.9119
	},
	{
		z = 19.8165,
		x = 1392.9521,
		y = 398.8794
	},
	{
		z = 29.7555,
		x = 1392.6501,
		y = 400.3592
	},
	{
		z = 28.7972,
		x = 1372.5093,
		y = 400.1643
	},
	{
		z = 19.7346,
		x = 1369.5377,
		y = 399.6218
	},
	{
		z = 19.5625,
		x = 1345.6184,
		y = 399.3468
	},
	{
		z = 19.5547,
		x = 1344.213,
		y = 399.2678
	},
	{
		z = 19.5547,
		x = 1333.7742,
		y = 399.3775
	},
	{
		z = 19.5547,
		x = 1328.2217,
		y = 399.4734
	},
	{
		z = 19.5547,
		x = 1304.9738,
		y = 398.8158
	},
	{
		z = 25.0555,
		x = 1303.3936,
		y = 398.4772
	},
	{
		z = 25.0555,
		x = 1301.0991,
		y = 398.4599
	},
	{
		z = 19.5547,
		x = 1299.1426,
		y = 398.5059
	},
	{
		z = 19.5547,
		x = 1295.8854,
		y = 398.496
	},
	{
		z = 22.5555,
		x = 1295.0284,
		y = 398.5144
	},
	{
		z = 19.5249,
		x = 1293.6958,
		y = 398.5569
	},
	{
		z = 19.4492,
		x = 1274.1288,
		y = 399.172
	},
	{
		z = 19.0921,
		x = 1239.618,
		y = 399.8578
	},
	{
		z = 23.8739,
		x = 1210.6898,
		y = 399.8748
	},
	{
		z = 25.3498,
		x = 1196.7906,
		y = 399.8862
	},
	{
		z = 25.3984,
		x = 1196.1296,
		y = 399.855
	},
	{
		z = 26.1845,
		x = 1187.2837,
		y = 400.2393
	},
	{
		z = 26.0114,
		x = 1182.4774,
		y = 400.4477
	},
	{
		z = 25.8477,
		x = 1180.7073,
		y = 400.1858
	},
	{
		z = 24.842,
		x = 1180.7987,
		y = 396.7657
	}
}

zone_palomino_creek2 =  {
	{
		z = 25.3737,
		x = 2174.7173,
		y = 114.1993
	},
	{
		z = 26.279,
		x = 2174.7212,
		y = 101.3581
	},
	{
		z = 25.6779,
		x = 2174.7976,
		y = 83.4835
	},
	{
		z = 26.4653,
		x = 2174.8726,
		y = 67.5628
	},
	{
		z = 26.4714,
		x = 2174.8328,
		y = 32.3258
	},
	{
		z = 24.4675,
		x = 2174.8323,
		y = 24.4783
	},
	{
		z = 18.4976,
		x = 2174.8181,
		y = 7.7459
	},
	{
		z = 18.472,
		x = 2173.3879,
		y = 2.9163
	},
	{
		z = 17.6097,
		x = 2173.6123,
		y = -6.6398
	},
	{
		z = 22.6359,
		x = 2173.7158,
		y = -14.6599
	},
	{
		z = 24.0197,
		x = 2173.8494,
		y = -21.8188
	},
	{
		z = 24.6336,
		x = 2174.2446,
		y = -43.0638
	},
	{
		z = 24.3775,
		x = 2174.3628,
		y = -49.5166
	},
	{
		z = 23.5265,
		x = 2175.1946,
		y = -61.4667
	},
	{
		z = 25.6776,
		x = 2175.6475,
		y = -93.2865
	},
	{
		z = 25.8038,
		x = 2175.6589,
		y = -100.5144
	},
	{
		z = 6.1672,
		x = 2175.502,
		y = -105.3096
	},
	{
		z = 1.7443,
		x = 2174.9211,
		y = -133.8267
	},
	{
		z = -0.5191,
		x = 2177.8113,
		y = -148.5184
	},
	{
		z = -0.5111,
		x = 2228.739,
		y = -147.5474
	},
	{
		z = 6.4632,
		x = 2229.2642,
		y = -147.4852
	},
	{
		z = 25.211,
		x = 2237.1516,
		y = -147.1415
	},
	{
		z = 25.692,
		x = 2296.8157,
		y = -147.6002
	},
	{
		z = 26.2599,
		x = 2334.293,
		y = -147.13
	},
	{
		z = 27.47,
		x = 2380.7798,
		y = -146.5905
	},
	{
		z = 27.5889,
		x = 2385.0452,
		y = -145.8921
	},
	{
		z = 28.9153,
		x = 2386.0359,
		y = -121.1514
	},
	{
		z = 26.2369,
		x = 2386.1904,
		y = -95.0933
	},
	{
		z = 26.4786,
		x = 2386.769,
		y = -82.5966
	},
	{
		z = 26.4844,
		x = 2453.5154,
		y = -82.0189
	},
	{
		z = 31.8472,
		x = 2484.4609,
		y = -81.4609
	},
	{
		z = 40.1065,
		x = 2521.1702,
		y = -80.6973
	},
	{
		z = 43.3141,
		x = 2536.8896,
		y = -80.3701
	},
	{
		z = 46.9894,
		x = 2553.8926,
		y = -80.0163
	},
	{
		z = 49.0064,
		x = 2563.4182,
		y = -79.9345
	},
	{
		z = 49.9831,
		x = 2568.9651,
		y = -79.9086
	},
	{
		z = 51.1751,
		x = 2574.6528,
		y = -80.2822
	},
	{
		z = 45.0333,
		x = 2574.8145,
		y = -67.2883
	},
	{
		z = 38.6331,
		x = 2575.2317,
		y = -51.9666
	},
	{
		z = 36.4212,
		x = 2575.384,
		y = -47.202
	},
	{
		z = 27.1264,
		x = 2576.4294,
		y = -15.3417
	},
	{
		z = 26.9894,
		x = 2576.4788,
		y = 9.5049
	},
	{
		z = 26.3359,
		x = 2575.9351,
		y = 37.5661
	},
	{
		z = 26.4844,
		x = 2575.3755,
		y = 68.6742
	},
	{
		z = 26.5848,
		x = 2574.7202,
		y = 102.0803
	},
	{
		z = 25.7634,
		x = 2574.6064,
		y = 113.2312
	},
	{
		z = 32.2926,
		x = 2574.2581,
		y = 142.351
	},
	{
		z = 36.9304,
		x = 2574.0168,
		y = 154.62
	},
	{
		z = 32.0645,
		x = 2555.436,
		y = 154.6201
	},
	{
		z = 28.2919,
		x = 2517.9541,
		y = 154.5609
	},
	{
		z = 28.1442,
		x = 2490.1392,
		y = 154.4515
	},
	{
		z = 25.3498,
		x = 2454.6931,
		y = 154.1466
	},
	{
		z = 26.1664,
		x = 2419.7966,
		y = 153.9843
	},
	{
		z = 26.1653,
		x = 2398.2915,
		y = 153.9777
	},
	{
		z = 26.4424,
		x = 2385.3521,
		y = 154.0966
	},
	{
		z = 26.5817,
		x = 2385.5654,
		y = 201.3177
	},
	{
		z = 25.5454,
		x = 2385.1177,
		y = 206.5849
	},
	{
		z = 26.4844,
		x = 2365.7942,
		y = 206.5155
	},
	{
		z = 26.4,
		x = 2333.2183,
		y = 206.4196
	},
	{
		z = 25.8958,
		x = 2317.0439,
		y = 206.4023
	},
	{
		z = 25.8511,
		x = 2315.8279,
		y = 206.1733
	},
	{
		z = 22.1554,
		x = 2285.4211,
		y = 206.1637
	},
	{
		z = 17.5774,
		x = 2256.5464,
		y = 206.2351
	},
	{
		z = 15.6798,
		x = 2238.5134,
		y = 206.3365
	},
	{
		z = 17.1991,
		x = 2231.0049,
		y = 206.3783
	},
	{
		z = 16.2146,
		x = 2223.3855,
		y = 206.4208
	},
	{
		z = 16.7818,
		x = 2213.374,
		y = 205.1622
	},
	{
		z = 22.2242,
		x = 2213.9531,
		y = 183.0614
	},
	{
		z = 25.1675,
		x = 2214.7041,
		y = 161.4294
	},
	{
		z = 26.4844,
		x = 2215.3564,
		y = 135.8106
	},
	{
		z = 26.4844,
		x = 2215.3552,
		y = 117.7612
	},
	{
		z = 26.3158,
		x = 2184.0249,
		y = 118.2386
	},
	{
		z = 25.116,
		x = 2176.2817,
		y = 118.3884
	},
	{
		z = 24.9347,
		x = 2174.7922,
		y = 117.9951
	},
	{
		z = 25.3785,
		x = 2174.7168,
		y = 114.1581
	}
}

zone_dillimore2 = {
	{
		z = 16.0254,
		x = 731.3495,
		y = -438.243
	},
	{
		z = 16.3359,
		x = 727.3804,
		y = -438.3506
	},
	{
		z = 16.3359,
		x = 725.9744,
		y = -438.3768
	},
	{
		z = 16.3359,
		x = 712.0631,
		y = -438.6103
	},
	{
		z = 16.3359,
		x = 660.3569,
		y = -439.3266
	},
	{
		z = 16.3359,
		x = 652.0676,
		y = -439.5683
	},
	{
		z = 17.2066,
		x = 628.2946,
		y = -439.4199
	},
	{
		z = 19.0385,
		x = 619.9375,
		y = -439.5002
	},
	{
		z = 25.6548,
		x = 603.2218,
		y = -439.6752
	},
	{
		z = 26.5712,
		x = 599.0934,
		y = -439.7035
	},
	{
		z = 29.5793,
		x = 589.7804,
		y = -439.8224
	},
	{
		z = 31.5321,
		x = 589.6334,
		y = -451.0467
	},
	{
		z = 30.4393,
		x = 589.5906,
		y = -460.6876
	},
	{
		z = 26.3106,
		x = 589.5992,
		y = -476.0851
	},
	{
		z = 24.1259,
		x = 589.5435,
		y = -479.4424
	},
	{
		z = 21.2271,
		x = 589.4402,
		y = -482.0966
	},
	{
		z = 17.3292,
		x = 589.2523,
		y = -491.9937
	},
	{
		z = 16.7698,
		x = 589.1486,
		y = -508.5141
	},
	{
		z = 17.1955,
		x = 589.278,
		y = -527.8976
	},
	{
		z = 17.8859,
		x = 589.5351,
		y = -559.4911
	},
	{
		z = 19.1561,
		x = 590.1614,
		y = -620.6767
	},
	{
		z = 21.8791,
		x = 590.1572,
		y = -631.1166
	},
	{
		z = 22.4152,
		x = 590.031,
		y = -649.5458
	},
	{
		z = 19.7072,
		x = 589.8772,
		y = -658.3351
	},
	{
		z = 17.4162,
		x = 589.928,
		y = -661.8019
	},
	{
		z = 19.56,
		x = 610.6904,
		y = -661.467
	},
	{
		z = 17.8349,
		x = 632.0553,
		y = -661.2007
	},
	{
		z = 16.1818,
		x = 671.7749,
		y = -660.4275
	},
	{
		z = 15.8621,
		x = 719.9654,
		y = -659.24
	},
	{
		z = 15.7671,
		x = 729.8235,
		y = -659.0614
	},
	{
		z = 15.5327,
		x = 729.5142,
		y = -616.0388
	},
	{
		z = 16.238,
		x = 729.547,
		y = -604.4753
	},
	{
		z = 15.8015,
		x = 770.0385,
		y = -604.7823
	},
	{
		z = 16.2488,
		x = 778.6854,
		y = -604.6418
	},
	{
		z = 16.3359,
		x = 779.6108,
		y = -604.6403
	},
	{
		z = 16.3359,
		x = 824.8543,
		y = -603.6371
	},
	{
		z = 16.3359,
		x = 836.3697,
		y = -603.4718
	},
	{
		z = 18.4219,
		x = 838.21,
		y = -601.6475
	},
	{
		z = 18.4219,
		x = 859.0208,
		y = -602.4149
	},
	{
		z = 18.3018,
		x = 858.7248,
		y = -577.7931
	},
	{
		z = 19.8256,
		x = 858.7146,
		y = -577.1379
	},
	{
		z = 17.9402,
		x = 858.7077,
		y = -576.3567
	},
	{
		z = 17.5907,
		x = 858.1677,
		y = -557.1426
	},
	{
		z = 19.6195,
		x = 857.927,
		y = -542.9055
	},
	{
		z = 21.2825,
		x = 857.7089,
		y = -525.6517
	},
	{
		z = 25.414,
		x = 857.4544,
		y = -497.7112
	},
	{
		z = 29.2947,
		x = 857.3306,
		y = -478.6505
	},
	{
		z = 29.9147,
		x = 857.399,
		y = -475.1015
	},
	{
		z = 20.0689,
		x = 837.1673,
		y = -474.9135
	},
	{
		z = 17.6218,
		x = 826.7546,
		y = -474.647
	},
	{
		z = 16.2724,
		x = 798.2079,
		y = -474.5621
	},
	{
		z = 16.3359,
		x = 766.257,
		y = -474.5509
	},
	{
		z = 16.3359,
		x = 739.9005,
		y = -474.998
	},
	{
		z = 16.3359,
		x = 732.0077,
		y = -475.0186
	},
	{
		z = 16.0528,
		x = 731.4903,
		y = -438.2546
	},
	{
		z = 16.0188,
		x = 731.3127,
		y = -438.2433
	}
}

zone_fort_carson2 =  {
	{
		z = 20.9922,
		x = 105.7903,
		y = 1243.7589
	},
	{
		z = 18.7771,
		x = 77.6957,
		y = 1242.9921
	},
	{
		z = 15.2989,
		x = 43.6454,
		y = 1242.2488
	},
	{
		z = 17.1816,
		x = 28.2649,
		y = 1241.9838
	},
	{
		z = 19.3438,
		x = 14.61,
		y = 1241.5364
	},
	{
		z = 19.3538,
		x = -6.0258,
		y = 1241.2163
	},
	{
		z = 19.509,
		x = -10.9547,
		y = 1241.1819
	},
	{
		z = 19.5156,
		x = -33.8188,
		y = 1241.0266
	},
	{
		z = 17.8871,
		x = -34.758,
		y = 1241.0265
	},
	{
		z = 18.4413,
		x = -69.0247,
		y = 1241.0232
	},
	{
		z = 18.537,
		x = -77.3124,
		y = 1240.8187
	},
	{
		z = 19.7422,
		x = -77.4157,
		y = 1227.9011
	},
	{
		z = 19.7422,
		x = -77.4261,
		y = 1220.0208
	},
	{
		z = 19.7422,
		x = -77.84,
		y = 1212.119
	},
	{
		z = 19.7352,
		x = -104.6425,
		y = 1212.446
	},
	{
		z = 19.4733,
		x = -106.0965,
		y = 1212.3074
	},
	{
		z = 19.7422,
		x = -139.7592,
		y = 1212.1973
	},
	{
		z = 19.7422,
		x = -178.4066,
		y = 1211.9617
	},
	{
		z = 22.4766,
		x = -179.0562,
		y = 1211.9535
	},
	{
		z = 24.7182,
		x = -189.4069,
		y = 1211.5193
	},
	{
		z = 22.3033,
		x = -190.6663,
		y = 1211.541
	},
	{
		z = 19.7422,
		x = -192.7686,
		y = 1211.6578
	},
	{
		z = 19.8906,
		x = -206.5604,
		y = 1211.6945
	},
	{
		z = 22.3185,
		x = -207.0094,
		y = 1211.6865
	},
	{
		z = 22.2853,
		x = -212.2083,
		y = 1211.6865
	},
	{
		z = 19.7422,
		x = -213.4147,
		y = 1211.6865
	},
	{
		z = 19.7422,
		x = -266.1136,
		y = 1211.5621
	},
	{
		z = 19.7422,
		x = -334.9648,
		y = 1210.9111
	},
	{
		z = 19.0535,
		x = -377.5226,
		y = 1211.0927
	},
	{
		z = 18.1095,
		x = -382.8222,
		y = 1210.9943
	},
	{
		z = 15.58,
		x = -386.6275,
		y = 1211.0684
	},
	{
		z = 13.7224,
		x = -390.1407,
		y = 1209.9889
	},
	{
		z = 14.7788,
		x = -390.1296,
		y = 1185.7223
	},
	{
		z = 16.8547,
		x = -389.9931,
		y = 1177.1672
	},
	{
		z = 16.1421,
		x = -389.8795,
		y = 1163.1412
	},
	{
		z = 15.8622,
		x = -389.5968,
		y = 1161.2317
	},
	{
		z = 14.6714,
		x = -389.5683,
		y = 1151.9076
	},
	{
		z = 17.6393,
		x = -389.5569,
		y = 1148.0057
	},
	{
		z = 17.3081,
		x = -389.4893,
		y = 1114.1071
	},
	{
		z = 15.374,
		x = -389.4351,
		y = 1066.2648
	},
	{
		z = 13.1142,
		x = -389.6175,
		y = 1026.6732
	},
	{
		z = 11.4688,
		x = -389.6684,
		y = 1016.5612
	},
	{
		z = 11.2319,
		x = -389.2402,
		y = 1014.9446
	},
	{
		z = 14.9779,
		x = -362.4053,
		y = 1015.5246
	},
	{
		z = 19.7816,
		x = -337.5971,
		y = 1015.7822
	},
	{
		z = 19.6024,
		x = -309.7359,
		y = 1015.9717
	},
	{
		z = 19.5938,
		x = -299.5965,
		y = 1016.1606
	},
	{
		z = 19.586,
		x = -273.0908,
		y = 1015.9733
	},
	{
		z = 19.5938,
		x = -266.3304,
		y = 1015.6108
	},
	{
		z = 19.7629,
		x = -265.9647,
		y = 984.2824
	},
	{
		z = 19.7357,
		x = -265.9406,
		y = 983.024
	},
	{
		z = 18.8336,
		x = -265.7836,
		y = 967.0164
	},
	{
		z = 17.1116,
		x = -265.9962,
		y = 952.0776
	},
	{
		z = 16.4218,
		x = -202.4868,
		y = 952.335
	},
	{
		z = 17.0589,
		x = -182.9512,
		y = 952.5685
	},
	{
		z = 18.9106,
		x = -153.0289,
		y = 952.7026
	},
	{
		z = 20.6664,
		x = -110.4651,
		y = 952.5766
	},
	{
		z = 19.4968,
		x = -21.0132,
		y = 952.6725
	},
	{
		z = 19.6561,
		x = 42.8877,
		y = 952.2053
	},
	{
		z = 18.4965,
		x = 93.8942,
		y = 951.9482
	},
	{
		z = 19.0994,
		x = 106.3415,
		y = 951.782
	},
	{
		z = 13.6094,
		x = 107.1936,
		y = 1020.8243
	},
	{
		z = 13.6094,
		x = 107.3791,
		y = 1024.6703
	},
	{
		z = 13.6094,
		x = 108.56,
		y = 1106.504
	},
	{
		z = 16.2544,
		x = 108.5268,
		y = 1107.025
	},
	{
		z = 16.1235,
		x = 108.5826,
		y = 1111.9868
	},
	{
		z = 13.6094,
		x = 108.591,
		y = 1112.8521
	},
	{
		z = 13.6094,
		x = 108.5429,
		y = 1116.0433
	},
	{
		z = 15.58,
		x = 108.2495,
		y = 1141.3574
	},
	{
		z = 17.0106,
		x = 108.0168,
		y = 1158.4436
	},
	{
		z = 18.6641,
		x = 107.8367,
		y = 1160.0034
	},
	{
		z = 20.0004,
		x = 107.3753,
		y = 1216.7803
	},
	{
		z = 20.9889,
		x = 107.355,
		y = 1236.215
	},
	{
		z = 21.0513,
		x = 107.3666,
		y = 1243.7839
	},
	{
		z = 20.987,
		x = 105.651,
		y = 1243.754
	}
}
zone_las_barrancas2 = {
	{
		z = 13.9278,
		x = -742.8038,
		y = 1411.5129
	},
	{
		z = 16.1136,
		x = -742.5969,
		y = 1432.4329
	},
	{
		z = 19.2787,
		x = -742.6761,
		y = 1432.8812
	},
	{
		z = 19.0608,
		x = -742.6649,
		y = 1436.292
	},
	{
		z = 16.3761,
		x = -742.6643,
		y = 1436.9056
	},
	{
		z = 17.4052,
		x = -742.6074,
		y = 1463.1227
	},
	{
		z = 22.3307,
		x = -742.5723,
		y = 1473.7854
	},
	{
		z = 24.679,
		x = -742.4963,
		y = 1488.5996
	},
	{
		z = 27.4763,
		x = -742.2061,
		y = 1502.2262
	},
	{
		z = 33.3187,
		x = -742.107,
		y = 1510.5614
	},
	{
		z = 35.1911,
		x = -741.9877,
		y = 1520.4152
	},
	{
		z = 30.807,
		x = -741.5434,
		y = 1536.6665
	},
	{
		z = 27.146,
		x = -740.9372,
		y = 1558.7792
	},
	{
		z = 27.1244,
		x = -740.9551,
		y = 1589.3959
	},
	{
		z = 30.248,
		x = -741.4951,
		y = 1589.9376
	},
	{
		z = 33.5816,
		x = -741.4949,
		y = 1592.0793
	},
	{
		z = 34.3968,
		x = -741.4949,
		y = 1594.3191
	},
	{
		z = 29.5703,
		x = -741.4478,
		y = 1597.8744
	},
	{
		z = 29.5703,
		x = -741.4356,
		y = 1603.0978
	},
	{
		z = 27.1172,
		x = -741.2787,
		y = 1604.6891
	},
	{
		z = 27.1172,
		x = -741.2127,
		y = 1620.3207
	},
	{
		z = 26.9609,
		x = -812.6011,
		y = 1620.5309
	},
	{
		z = 27.3123,
		x = -873.0068,
		y = 1619.5544
	},
	{
		z = 25.4875,
		x = -890.3611,
		y = 1619.3198
	},
	{
		z = 15.6503,
		x = -909.2338,
		y = 1618.9321
	},
	{
		z = 9.3661,
		x = -925.9393,
		y = 1618.9321
	},
	{
		z = 8.4966,
		x = -935.3748,
		y = 1619.0447
	},
	{
		z = 13.7319,
		x = -935.5283,
		y = 1591.3673
	},
	{
		z = 16.6224,
		x = -935.6058,
		y = 1589.8645
	},
	{
		z = 24.5465,
		x = -935.6924,
		y = 1585.3284
	},
	{
		z = 34.7679,
		x = -935.8027,
		y = 1579.4767
	},
	{
		z = 33.0175,
		x = -936.2636,
		y = 1574.915
	},
	{
		z = 37.7869,
		x = -936.2992,
		y = 1542.4022
	},
	{
		z = 32.3934,
		x = -936.2099,
		y = 1513.3164
	},
	{
		z = 31.7492,
		x = -935.9743,
		y = 1480.4875
	},
	{
		z = 34.2432,
		x = -935.8391,
		y = 1454.4567
	},
	{
		z = 30.0635,
		x = -935.7877,
		y = 1431.4382
	},
	{
		z = 30.1245,
		x = -935.781,
		y = 1423.1835
	},
	{
		z = 29.8203,
		x = -935.6131,
		y = 1411.8743
	},
	{
		z = 29.7789,
		x = -911.134,
		y = 1411.96
	},
	{
		z = 27.8935,
		x = -904.8223,
		y = 1411.9309
	},
	{
		z = 17.3986,
		x = -893.2028,
		y = 1411.9619
	},
	{
		z = 12.5113,
		x = -876.414,
		y = 1411.9507
	},
	{
		z = 11.3062,
		x = -861.0438,
		y = 1412.1038
	},
	{
		z = 13.9556,
		x = -854.5966,
		y = 1412.2419
	},
	{
		z = 13.6094,
		x = -832.901,
		y = 1412.0519
	},
	{
		z = 13.2899,
		x = -780.6898,
		y = 1411.3416
	},
	{
		z = 13.8954,
		x = -742.8013,
		y = 1411.1249
	},
	{
		z = 13.9307,
		x = -742.8062,
		y = 1411.5471
	}
}

zone_el_quebrados2 = {
	{
		z = 65.3059,
		x = -1389.151,
		y = 2507.0264
	},
	{
		z = 66.1882,
		x = -1388.5553,
		y = 2531.342
	},
	{
		z = 62.2522,
		x = -1388.2754,
		y = 2555.0886
	},
	{
		z = 58.3919,
		x = -1388.2205,
		y = 2569.3711
	},
	{
		z = 55.0724,
		x = -1388.0919,
		y = 2606.3311
	},
	{
		z = 55.9136,
		x = -1387.985,
		y = 2626.854
	},
	{
		z = 60.2116,
		x = -1387.024,
		y = 2627.1055
	},
	{
		z = 60.1815,
		x = -1387.174,
		y = 2654.7302
	},
	{
		z = 55.98,
		x = -1387.1749,
		y = 2655.2498
	},
	{
		z = 54.9512,
		x = -1387.2123,
		y = 2659.6987
	},
	{
		z = 54.8969,
		x = -1388.2537,
		y = 2682.802
	},
	{
		z = 55.9841,
		x = -1389.1732,
		y = 2698.1863
	},
	{
		z = 60.8236,
		x = -1416.8129,
		y = 2697.8811
	},
	{
		z = 56.4565,
		x = -1437.1277,
		y = 2697.8481
	},
	{
		z = 55.8359,
		x = -1453.8037,
		y = 2697.946
	},
	{
		z = 55.8359,
		x = -1461.663,
		y = 2697.8398
	},
	{
		z = 59.0205,
		x = -1462.2365,
		y = 2698.1782
	},
	{
		z = 58.7355,
		x = -1465.3522,
		y = 2698.2031
	},
	{
		z = 55.8359,
		x = -1465.8657,
		y = 2698.2034
	},
	{
		z = 55.8359,
		x = -1510.5518,
		y = 2698.571
	},
	{
		z = 58.6583,
		x = -1510.6318,
		y = 2698.4893
	},
	{
		z = 59.4445,
		x = -1512.8209,
		y = 2698.5547
	},
	{
		z = 59.4727,
		x = -1522.8049,
		y = 2698.603
	},
	{
		z = 55.8359,
		x = -1523.7739,
		y = 2698.6245
	},
	{
		z = 55.8403,
		x = -1546.0717,
		y = 2699.0889
	},
	{
		z = 59.0274,
		x = -1546.736,
		y = 2699.0286
	},
	{
		z = 58.2737,
		x = -1552.3486,
		y = 2699.0981
	},
	{
		z = 55.8359,
		x = -1553.5103,
		y = 2699.0981
	},
	{
		z = 55.8359,
		x = -1572.1746,
		y = 2699.189
	},
	{
		z = 55.7119,
		x = -1581.6924,
		y = 2698.428
	},
	{
		z = 55.878,
		x = -1582.7177,
		y = 2658.4463
	},
	{
		z = 59.2396,
		x = -1582.5892,
		y = 2658.2781
	},
	{
		z = 59.3048,
		x = -1582.8273,
		y = 2646.7424
	},
	{
		z = 55.8359,
		x = -1582.8274,
		y = 2645.8904
	},
	{
		z = 55.5697,
		x = -1582.9023,
		y = 2631.1846
	},
	{
		z = 61.5368,
		x = -1582.9291,
		y = 2626.1736
	},
	{
		z = 65.3288,
		x = -1582.8816,
		y = 2603.8098
	},
	{
		z = 67.9763,
		x = -1583.0299,
		y = 2575.0796
	},
	{
		z = 68.496,
		x = -1583.9945,
		y = 2526.0549
	},
	{
		z = 68.111,
		x = -1582.3055,
		y = 2504.9543
	},
	{
		z = 68.5214,
		x = -1571.3235,
		y = 2505.0205
	},
	{
		z = 63.6521,
		x = -1568.9933,
		y = 2504.7776
	},
	{
		z = 56.0478,
		x = -1545.9767,
		y = 2504.8435
	},
	{
		z = 55.9563,
		x = -1534.3876,
		y = 2504.8892
	},
	{
		z = 55.3984,
		x = -1494.4845,
		y = 2505.2505
	},
	{
		z = 56.6459,
		x = -1462.8827,
		y = 2505.8474
	},
	{
		z = 61.9382,
		x = -1427.5518,
		y = 2506.3953
	},
	{
		z = 62.4519,
		x = -1410.1781,
		y = 2506.342
	},
	{
		z = 65.297,
		x = -1389.1597,
		y = 2505.9971
	},
	{
		z = 65.308,
		x = -1389.1449,
		y = 2507.1472
	}
}

zone_angel_pine2 = {
	{
		z = 33.5285,
		x = -2251.1846,
		y = -2591.1289
	},
	{
		z = 33.811,
		x = -2220.6426,
		y = -2590.5291
	},
	{
		z = 34.3637,
		x = -2187.446,
		y = -2590.2168
	},
	{
		z = 35.1946,
		x = -2154.4136,
		y = -2589.8965
	},
	{
		z = 34.9952,
		x = -2127.5205,
		y = -2589.636
	},
	{
		z = 38.5968,
		x = -2104.6553,
		y = -2589.6045
	},
	{
		z = 36.9147,
		x = -2083.9575,
		y = -2589.6045
	},
	{
		z = 34.7778,
		x = -2062.9756,
		y = -2589.1243
	},
	{
		z = 30.625,
		x = -2061.2139,
		y = -2537.0872
	},
	{
		z = 33.3929,
		x = -2061.7256,
		y = -2535.6995
	},
	{
		z = 33.3929,
		x = -2061.8057,
		y = -2531.5532
	},
	{
		z = 30.625,
		x = -2061.8899,
		y = -2530.7546
	},
	{
		z = 30.703,
		x = -2061.9185,
		y = -2509.623
	},
	{
		z = 30.625,
		x = -2062.1392,
		y = -2490.6287
	},
	{
		z = 30.625,
		x = -2062.5186,
		y = -2450.7595
	},
	{
		z = 30.625,
		x = -2061.7942,
		y = -2397.0981
	},
	{
		z = 30.625,
		x = -2061.9622,
		y = -2350.4282
	},
	{
		z = 30.625,
		x = -2062.0413,
		y = -2303.6223
	},
	{
		z = 31.3086,
		x = -2062.0723,
		y = -2273.4072
	},
	{
		z = 31.8706,
		x = -2062.3638,
		y = -2262.001
	},
	{
		z = 36.7936,
		x = -2062.668,
		y = -2261.656
	},
	{
		z = 35.9696,
		x = -2062.4568,
		y = -2256.2253
	},
	{
		z = 31.9117,
		x = -2062.3271,
		y = -2255.9302
	},
	{
		z = 30.9469,
		x = -2061.1909,
		y = -2242.7661
	},
	{
		z = 43.5137,
		x = -2060.6189,
		y = -2210.5942
	},
	{
		z = 34.8582,
		x = -2104.1216,
		y = -2210.0203
	},
	{
		z = 35.1783,
		x = -2158.2397,
		y = -2209.4983
	},
	{
		z = 37.02,
		x = -2209.5217,
		y = -2209.3225
	},
	{
		z = 35.4347,
		x = -2241.1445,
		y = -2209.301
	},
	{
		z = 32.9123,
		x = -2256.04,
		y = -2209.2998
	},
	{
		z = 31.5181,
		x = -2255.9348,
		y = -2223.7166
	},
	{
		z = 30.8943,
		x = -2255.73,
		y = -2243.1763
	},
	{
		z = 29.1853,
		x = -2254.252,
		y = -2310.1016
	},
	{
		z = 30.6357,
		x = -2253.6833,
		y = -2375.6731
	},
	{
		z = 32.692,
		x = -2253.5771,
		y = -2409.1348
	},
	{
		z = 31.6192,
		x = -2253.4429,
		y = -2430.9336
	},
	{
		z = 34.146,
		x = -2253.3523,
		y = -2431.8818
	},
	{
		z = 31.8293,
		x = -2253.4575,
		y = -2432.6187
	},
	{
		z = 30.8762,
		x = -2253.5461,
		y = -2444.2324
	},
	{
		z = 30.0412,
		x = -2254.4275,
		y = -2485.3164
	},
	{
		z = 29.1255,
		x = -2254.5994,
		y = -2512.8269
	},
	{
		z = 32.7203,
		x = -2254.5024,
		y = -2529.1951
	},
	{
		z = 33.7549,
		x = -2255.5737,
		y = -2588.3237
	},
	{
		z = 33.8311,
		x = -2255.4707,
		y = -2591.2192
	},
	{
		z = 33.5246,
		x = -2251.1267,
		y = -2591.1311
	}
}
        zone_one = {
        {
			z = 5.893,
			x = 433.5031,
			y = 743.5056
		},
		{
			z = 5.9544,
			x = 416.5483,
			y = 751.2752
		},
		{
			z = 6.2238,
			x = 385.3122,
			y = 761.4517
		},
		{
			z = 6.2248,
			x = 352.632,
			y = 764.3365
		},
		{
			z = 6.2165,
			x = 327.3391,
			y = 762.4012
		},
		{
			z = 11.58,
			x = 327.3391,
			y = 762.4012
		},
		{
			z = 11.792,
			x = 314.299,
			y = 759.73
		},
		{
			z = 15.818,
			x = 291.597,
			y = 808.923
		},
		{
			z = 20.699,
			x = 265.555,
			y = 867.004
		},
		{
			z = 25.516,
			x = 241.645,
			y = 921.632
		},
		{
			z = 27.54,
			x = 232.515,
			y = 942.289
		},
		{
			z = 28.386,
			x = 216.622,
			y = 972.796
		},
		{
			z = 28.248,
			x = 212.742,
			y = 986.785
		},
		{
			z = 28.479,
			x = 231.576,
			y = 994.004
		},
		{
			z = 29.226,
			x = 267.994,
			y = 1007.34
		},
		{
			z = 29.15,
			x = 325.38,
			y = 1020.53
		},
		{
			z = 27.208,
			x = 376.666,
			y = 1031.315
		},
		{
			z = 29.544,
			x = 384.923,
			y = 1033.306
		},
		{
			z = 28.992,
			x = 442.56,
			y = 1047.676
		},
		{
			z = 28.297,
			x = 444.722,
			y = 1038.563
		},
		{
			z = 28.297,
			x = 448.045,
			y = 1026.094
		},
		{
			z = 30.484,
			x = 449.345,
			y = 1020.358
		},
		{
			z = 31.418,
			x = 458.882,
			y = 976.888
		},
		{
			z = 31.676,
			x = 438.25,
			y = 966.981
		},
		{
			z = 31.14,
			x = 425.172,
			y = 958.159
		},
		{
			z = 28.838,
			x = 416.239,
			y = 945.913
		},
		{
			z = 25.304,
			x = 407.793,
			y = 929.212
		},
		{
			z = 21.927,
			x = 403.398,
			y = 905.136
		},
		{
			z = 20.644,
			x = 403.862,
			y = 873.648
		},
		{
			z = 19.705,
			x = 410.905,
			y = 848.031
		},
		{
			z = 14.174,
			x = 424.182,
			y = 825.561
		},
		{
			z = 9.252,
			x = 459.004,
			y = 795.036
		},
		{
			z = 6.41,
			x = 447.343,
			y = 771.852
		},
		{
			z = 5.893,
			x = 433.5031,
			y = 743.5056
		}
	
        }
		zone_three = {
          {
			z = 16.4844,
			x = 377.8415,
			y = 2433.3201
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2437.2761
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2445.0186
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2452.4487
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2462.6277
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2473.325
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2488.325
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2503.325
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 337.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 317.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 297.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 277.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 257.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 237.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 217.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 197.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 177.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 157.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 137.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 117.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 97.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 77.8415,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2528.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2508.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2488.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2468.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2448.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2428.425
		},
		{
			z = 16.4844,
			x = 25.185,
			y = 2408.425
		},
		{
			z = 17.4844,
			x = 25.185,
			y = 2388.425
		},
		{
			z = 18.4844,
			x = 25.185,
			y = 2368.425
		},
		{
			z = 20,
			x = 25.185,
			y = 2358.425
		},
		{
			z = 20.5429,
			x = 25.185,
			y = 2348.425
		},
		{
			z = 17.4552,
			x = 87.4935,
			y = 2349.6045
		},
		{
			z = 16.7068,
			x = 131.1678,
			y = 2351.342
		},
		{
			z = 16.3239,
			x = 156.7558,
			y = 2352.4211
		},
		{
			z = 17.1302,
			x = 210.6032,
			y = 2354.437
		},
		{
			z = 16.7498,
			x = 238.6013,
			y = 2355.6199
		},
		{
			z = 16.5238,
			x = 291.672,
			y = 2357.7083
		},
		{
			z = 15.187,
			x = 338.326,
			y = 2358.7124
		},
		{
			z = 25.5711,
			x = 377.8415,
			y = 2361.3408
		},
		{
			z = 21.9927,
			x = 377.8415,
			y = 2377.9263
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2394.6624
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2413.3201
		},
		{
			z = 16.4844,
			x = 377.8415,
			y = 2433.3201
		}  
        }
		zone_fo = {
            {
			z = 36.2669,
			x = -1740.5605,
			y = -1661.7677
		},
		{
			z = 36.2714,
			x = -1748.8273,
			y = -1665.4274
		},
		{
			z = 34.7597,
			x = -1766.4485,
			y = -1675.8883
		},
		{
			z = 31.9707,
			x = -1782.1888,
			y = -1687.5377
		},
		{
			z = 29.903,
			x = -1797.2588,
			y = -1699.8524
		},
		{
			z = 29.1117,
			x = -1812.1237,
			y = -1710.4294
		},
		{
			z = 29.1779,
			x = -1856.4849,
			y = -1739.1055
		},
		{
			z = 29.2356,
			x = -1881.7136,
			y = -1754.7506
		},
		{
			z = 29.4741,
			x = -1906.2281,
			y = -1769.2833
		},
		{
			z = 30.1273,
			x = -1918.3944,
			y = -1777.9166
		},
		{
			z = 31.1691,
			x = -1931.089,
			y = -1788.0837
		},
		{
			z = 32.5334,
			x = -1943.6625,
			y = -1799.3176
		},
		{
			z = 32.8897,
			x = -1946.9335,
			y = -1795.9506
		},
		{
			z = 33.2219,
			x = -1956.3748,
			y = -1790.0321
		},
		{
			z = 24.9352,
			x = -1950.4111,
			y = -1761.2076
		},
		{
			z = 26.1741,
			x = -1948.2877,
			y = -1675.2468
		},
		{
			z = 25.8392,
			x = -1944.943,
			y = -1667.6029
		},
		{
			z = 25.9967,
			x = -1943.7323,
			y = -1632.3048
		},
		{
			z = 25.2272,
			x = -1914.0909,
			y = -1631.0404
		},
		{
			z = 25.5995,
			x = -1912.3181,
			y = -1603.8901
		},
		{
			z = 25.9002,
			x = -1913.0071,
			y = -1540.6603
		},
		{
			z = 21.5983,
			x = -1911.3258,
			y = -1494.3988
		},
		{
			z = 21.6668,
			x = -1906.7396,
			y = -1499.3909
		},
		{
			z = 21.75,
			x = -1899.5017,
			y = -1505.0645
		},
		{
			z = 21.75,
			x = -1884.1749,
			y = -1516.2777
		},
		{
			z = 21.75,
			x = -1844.3685,
			y = -1546.2926
		},
		{
			z = 21.75,
			x = -1820.9479,
			y = -1564.6523
		},
		{
			z = 21.75,
			x = -1806.3767,
			y = -1575.4534
		},
		{
			z = 21.75,
			x = -1789.2322,
			y = -1583.2456
		},
		{
			z = 21.75,
			x = -1760.6337,
			y = -1597.6904
		},
		{
			z = 21.7688,
			x = -1742.8527,
			y = -1656.7146
		},
		{
			z = 37.5811,
			x = -1742.4752,
			y = -1656.7692
		},
		{
			z = 36.6102,
			x = -1741.652,
			y = -1658.8728
		},
		{
			z = 36.2669,
			x = -1740.5605,
			y = -1661.7677
		}
        }
		zone_five =  {
		{
			z = 10.8203,
			x = 2517.0317,
			y = 2005.8452
		},
		{
			z = 10.8203,
			x = 2517.0317,
			y = 1940.8452
		},
		{
			z = 10.8203,
			x = 2517.0317,
			y = 1890.8452
		},
		{
			z = 10.8203,
			x = 2517.0317,
			y = 1862.8452
		},
		{
			z = 10.8203,
			x = 2517.0623,
			y = 1783.1
		},
		{
			z = 10.8203,
			x = 2517.0623,
			y = 1773.7229
		},
		{
			z = 10.8203,
			x = 2491.2722,
			y = 1773.7229
		},
		{
			z = 10.8203,
			x = 2473.801,
			y = 1773.7229
		},
		{
			z = 10.8203,
			x = 2456.152,
			y = 1773.7229
		},
		{
			z = 10.8203,
			x = 2438.668,
			y = 1773.7229
		},
		{
			z = 10.8203,
			x = 2419.9,
			y = 1773.7229
		},
		{
			z = 10.8125,
			x = 2419.9,
			y = 1783.1
		},
		{
			z = 11.8125,
			x = 2419.9,
			y = 1783.1
		},
		{
			z = 11.8132,
			x = 2419.9,
			y = 1783.5
		},
		{
			z = 10.8132,
			x = 2419.9,
			y = 1783.5
		},
		{
			z = 10.8132,
			x = 2419.9,
			y = 1789.8
		},
		{
			z = 10.8132,
			x = 2433.3,
			y = 1789.8
		},
		{
			z = 10.8132,
			x = 2433.3,
			y = 1796.5
		},
		{
			z = 10.8132,
			x = 2439.9,
			y = 1796.5
		},
		{
			z = 10.8203,
			x = 2439.9,
			y = 1803.2
		},
		{
			z = 10.8203,
			x = 2446.6,
			y = 1803.2
		},
		{
			z = 10.8203,
			x = 2446.6,
			y = 1809.8
		},
		{
			z = 10.8203,
			x = 2486.6,
			y = 1809.8
		},
		{
			z = 10.8203,
			x = 2486.6,
			y = 1823.18
		},
		{
			z = 10.8203,
			x = 2494.2119,
			y = 1823.18
		},
		{
			z = 10.8203,
			x = 2494.2119,
			y = 1829.95
		},
		{
			z = 10.8203,
			x = 2486.55,
			y = 1829.95
		},
		{
			z = 10.8203,
			x = 2486.55,
			y = 1843.26
		},
		{
			z = 10.8203,
			x = 2479.9,
			y = 1843.26
		},
		{
			z = 10.8203,
			x = 2479.9,
			y = 1856.6
		},
		{
			z = 10.8203,
			x = 2473.22,
			y = 1856.6
		},
		{
			z = 10.8203,
			x = 2473.22,
			y = 1863.25
		},
		{
			z = 10.8222,
			x = 2459.8848,
			y = 1863.25
		},
		{
			z = 10.8222,
			x = 2459.8848,
			y = 1869.95
		},
		{
			z = 8.6697,
			x = 2459.8848,
			y = 1869.95
		},
		{
			z = 8.1563,
			x = 2446.6,
			y = 1869.95
		},
		{
			z = 8.1563,
			x = 2446.6,
			y = 1876.6
		},
		{
			z = 8.1641,
			x = 2439.8804,
			y = 1876.6
		},
		{
			z = 8.1641,
			x = 2439.8804,
			y = 1869.95
		},
		{
			z = 8.1307,
			x = 2419.792,
			y = 1869.95
		},
		{
			z = 11.6563,
			x = 2419.792,
			y = 1869.95
		},
		{
			z = 11.6563,
			x = 2419.792,
			y = 1836.6
		},
		{
			z = 11.6563,
			x = 2413.2,
			y = 1836.6
		},
		{
			z = 11.6563,
			x = 2413.2,
			y = 1829.9
		},
		{
			z = 11.6563,
			x = 2406.5,
			y = 1829.9
		},
		{
			z = 11.6563,
			x = 2406.5,
			y = 1823.25
		},
		{
			z = 11.6563,
			x = 2399.9,
			y = 1823.25
		},
		{
			z = 11.6563,
			x = 2399.9,
			y = 1832.2
		},
		{
			z = 11.6563,
			x = 2371.95,
			y = 1832.2
		},
		{
			z = 11.6563,
			x = 2371.95,
			y = 1883.3
		},
		{
			z = 14.8,
			x = 2371.95,
			y = 1883.3
		},
		{
			z = 14.8,
			x = 2371.7,
			y = 1883.3
		},
		{
			z = 10.8203,
			x = 2371.7,
			y = 1883.3
		},
		{
			z = 10.8203,
			x = 2362.65,
			y = 1883.3
		},
		{
			z = 10.8203,
			x = 2362.65,
			y = 1880.3
		},
		{
			z = 10.8203,
			x = 2337.75,
			y = 1880.3
		},
		{
			z = 10.8203,
			x = 2337.75,
			y = 1883.3
		},
		{
			z = 10.6795,
			x = 2337.4709,
			y = 1883.3
		},
		{
			z = 10.6719,
			x = 2337.4709,
			y = 1922.543
		},
		{
			z = 10.6719,
			x = 2337.4709,
			y = 1952.6678
		},
		{
			z = 10.8203,
			x = 2337.4709,
			y = 2001.3892
		},
		{
			z = 10.8203,
			x = 2337.4709,
			y = 2023.5226
		},
		{
			z = 10.8203,
			x = 2368.0857,
			y = 2023.5226
		},
		{
			z = 10.8203,
			x = 2392.8972,
			y = 2023.5226
		},
		{
			z = 10.8203,
			x = 2392.8972,
			y = 2001.3892
		},
		{
			z = 10.8203,
			x = 2367.7988,
			y = 2001.3892
		},
		{
			z = 10.8203,
			x = 2367.7988,
			y = 2001.3892
		},
		{
			z = 10.8281,
			x = 2367.7649,
			y = 1985.7206
		},
		{
			z = 10.8203,
			x = 2370.6326,
			y = 1982.8994
		},
		{
			z = 10.8203,
			x = 2408.2842,
			y = 1982.9637
		},
		{
			z = 10.8203,
			x = 2408.4124,
			y = 2004.3645
		},
		{
			z = 11.2648,
			x = 2428.3608,
			y = 2004.3645
		},
		{
			z = 11.9381,
			x = 2433.0125,
			y = 2004.7113
		},
		{
			z = 10.8203,
			x = 2454.104,
			y = 2005.7122
		},
		{
			z = 10.8203,
			x = 2485.3347,
			y = 2005.7123
		},
		{
			z = 11.9381,
			x = 2496.6868,
			y = 2005.7123
		},
		{
			z = 10.8203,
			x = 2500.3589,
			y = 2005.7567
		},
		{
			z = 10.8203,
			x = 2512.8394,
			y = 2006.2916
		},
		{
			z = 10.8203,
			x = 2517.0317,
			y = 2005.8452
		}
	}
	zone_two = {
		{
			z = 48.0969,
			x = -487.5297,
			y = 2163.1255
		},
		{
			z = 47.917,
			x = -484.3675,
			y = 2165.7024
		},
		{
			z = 47.4877,
			x = -476.8463,
			y = 2171.8357
		},
		{
			z = 46.8229,
			x = -471.303,
			y = 2177.4629
		},
		{
			z = 46.4865,
			x = -470.6429,
			y = 2184.9189
		},
		{
			z = 46.2181,
			x = -470.5349,
			y = 2194.9207
		},
		{
			z = 47.1068,
			x = -475.7249,
			y = 2201.5356
		},
		{
			z = 48.4619,
			x = -482.8195,
			y = 2208.8984
		},
		{
			z = 49.5511,
			x = -488.0079,
			y = 2217.5398
		},
		{
			z = 49.7572,
			x = -488.112,
			y = 2223.6665
		},
		{
			z = 49.9258,
			x = -488.1552,
			y = 2228.863
		},
		{
			z = 50.0021,
			x = -489.8535,
			y = 2236.1228
		},
		{
			z = 50.0074,
			x = -492.4996,
			y = 2245.3145
		},
		{
			z = 51.5313,
			x = -494.7664,
			y = 2256.3821
		},
		{
			z = 53.3101,
			x = -495.6942,
			y = 2265.6953
		},
		{
			z = 56.31,
			x = -498.0162,
			y = 2271.7842
		},
		{
			z = 59.3243,
			x = -500.8201,
			y = 2276.4836
		},
		{
			z = 62.8115,
			x = -504.1785,
			y = 2281.8787
		},
		{
			z = 64.179,
			x = -505.5282,
			y = 2283.9822
		},
		{
			z = 64.3418,
			x = -505.4239,
			y = 2285.4063
		},
		{
			z = 64.2797,
			x = -504.4581,
			y = 2286.2952
		},
		{
			z = 64.0252,
			x = -500.5304,
			y = 2290.4277
		},
		{
			z = 64.3405,
			x = -494.5858,
			y = 2298.5112
		},
		{
			z = 64.7392,
			x = -489.4023,
			y = 2305.7971
		},
		{
			z = 63.6399,
			x = -482.8528,
			y = 2312.8918
		},
		{
			z = 65.5649,
			x = -476.4283,
			y = 2318.8164
		},
		{
			z = 68.0005,
			x = -470.8137,
			y = 2323.4734
		},
		{
			z = 70.708,
			x = -466.7094,
			y = 2327.2668
		},
		{
			z = 70.9602,
			x = -465.8162,
			y = 2327.4768
		},
		{
			z = 70.0083,
			x = -460.825,
			y = 2324.3374
		},
		{
			z = 67.8298,
			x = -455.1648,
			y = 2318.7695
		},
		{
			z = 66.7524,
			x = -450.1181,
			y = 2317.1887
		},
		{
			z = 66.0162,
			x = -440.609,
			y = 2318.0371
		},
		{
			z = 65.7374,
			x = -436.5607,
			y = 2318.447
		},
		{
			z = 59.553,
			x = -426.8115,
			y = 2317.7573
		},
		{
			z = 54.4471,
			x = -423.2818,
			y = 2312.8767
		},
		{
			z = 50.0836,
			x = -417.8271,
			y = 2311.8882
		},
		{
			z = 49.7017,
			x = -414.6191,
			y = 2314.8955
		},
		{
			z = 47.4286,
			x = -404.2956,
			y = 2320.7078
		},
		{
			z = 42.9294,
			x = -397.7255,
			y = 2320.1821
		},
		{
			z = 39.0983,
			x = -391.1599,
			y = 2320.1865
		},
		{
			z = 35.3621,
			x = -384.245,
			y = 2319.6675
		},
		{
			z = 33.6878,
			x = -379.2184,
			y = 2319.1067
		},
		{
			z = 33.6915,
			x = -367.553,
			y = 2318.5793
		},
		{
			z = 36.5222,
			x = -356.0885,
			y = 2316.6218
		},
		{
			z = 40.4985,
			x = -349.5545,
			y = 2309.449
		},
		{
			z = 44.418,
			x = -343.1182,
			y = 2302.3689
		},
		{
			z = 47.8572,
			x = -341.067,
			y = 2294.8552
		},
		{
			z = 51.9972,
			x = -339.7117,
			y = 2284.7825
		},
		{
			z = 54.4416,
			x = -335.2355,
			y = 2277.1536
		},
		{
			z = 57.0218,
			x = -329.9371,
			y = 2269.043
		},
		{
			z = 58.0583,
			x = -323.7013,
			y = 2262.9683
		},
		{
			z = 58.777,
			x = -314.3908,
			y = 2255.4756
		},
		{
			z = 60.927,
			x = -302.6476,
			y = 2248.3704
		},
		{
			z = 61.8861,
			x = -295.6709,
			y = 2243.4937
		},
		{
			z = 59.7512,
			x = -294.7297,
			y = 2237.7168
		},
		{
			z = 57.3093,
			x = -293.5323,
			y = 2230.3699
		},
		{
			z = 54.8039,
			x = -291.5664,
			y = 2219.124
		},
		{
			z = 54.7589,
			x = -290.3576,
			y = 2210.8164
		},
		{
			z = 58.3442,
			x = -289.1982,
			y = 2202.8357
		},
		{
			z = 61.0377,
			x = -288.3018,
			y = 2196.6785
		},
		{
			z = 59.1221,
			x = -297.4099,
			y = 2192.0303
		},
		{
			z = 58.3105,
			x = -305.9751,
			y = 2184.7625
		},
		{
			z = 57.8909,
			x = -310.1546,
			y = 2181.3223
		},
		{
			z = 57.027,
			x = -313.8151,
			y = 2171.3884
		},
		{
			z = 56.1915,
			x = -315.9184,
			y = 2161.116
		},
		{
			z = 51.8329,
			x = -312.1996,
			y = 2141.8894
		},
		{
			z = 49.974,
			x = -346.3464,
			y = 2137.3879
		},
		{
			z = 57.727,
			x = -363.3376,
			y = 2136.1326
		},
		{
			z = 59.8518,
			x = -368.9391,
			y = 2140.6284
		},
		{
			z = 59.9288,
			x = -378.6228,
			y = 2140.6682
		},
		{
			z = 60.2335,
			x = -388.4158,
			y = 2133.6604
		},
		{
			z = 57.4081,
			x = -395.5507,
			y = 2128.7273
		},
		{
			z = 51.3497,
			x = -403.9309,
			y = 2128.9497
		},
		{
			z = 47,
			x = -414.5854,
			y = 2129.5776
		},
		{
			z = 45.9178,
			x = -426.6154,
			y = 2130.4492
		},
		{
			z = 46.2906,
			x = -437.5507,
			y = 2131.1936
		},
		{
			z = 47.3507,
			x = -444.0714,
			y = 2131.6406
		},
		{
			z = 47.575,
			x = -446.5881,
			y = 2136.7134
		},
		{
			z = 48.315,
			x = -451.392,
			y = 2143.3989
		},
		{
			z = 49.6828,
			x = -458.2214,
			y = 2149.7058
		},
		{
			z = 51.1855,
			x = -465.7596,
			y = 2156.1973
		},
		{
			z = 51.9547,
			x = -469.6096,
			y = 2159.6272
		},
		{
			z = 51.1807,
			x = -475.251,
			y = 2161.114
		},
		{
			z = 49.3001,
			x = -483.0723,
			y = 2162.1294
		},
		{
			z = 48.0969,
			x = -487.5297,
			y = 2163.1255
		}
	}
    zone_six = {
		{
			z = 10.8203,
			x = 2557.0486,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2577.0486,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2597.0486,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2617.0486,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2635.0486,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2647.377,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2647.377,
			y = 1602.9124
		},
		{
			z = 10.8203,
			x = 2647.377,
			y = 1582.9124
		},
		{
			z = 9.8276,
			x = 2647.377,
			y = 1562.9124
		},
		{
			z = 9.6983,
			x = 2647.377,
			y = 1542.9124
		},
		{
			z = 10.0305,
			x = 2647.377,
			y = 1522.9124
		},
		{
			z = 10.6545,
			x = 2647.377,
			y = 1502.9124
		},
		{
			z = 10.8203,
			x = 2647.377,
			y = 1482.9124
		},
		{
			z = 10.8557,
			x = 2647.377,
			y = 1463.5847
		},
		{
			z = 10.8557,
			x = 2629.377,
			y = 1463.5847
		},
		{
			z = 10.8557,
			x = 2613.377,
			y = 1463.5847
		},
		{
			z = 10.8203,
			x = 2601.9058,
			y = 1463.5847
		},
		{
			z = 10.8203,
			x = 2601.9058,
			y = 1459.912
		},
		{
			z = 10.8203,
			x = 2588.9058,
			y = 1459.912
		},
		{
			z = 10.8203,
			x = 2568.8967,
			y = 1459.912
		},
		{
			z = 10.8203,
			x = 2557.3787,
			y = 1459.912
		},
		{
			z = 10.8203,
			x = 2557.3787,
			y = 1443.7177
		},
		{
			z = 10.8203,
			x = 2537.3787,
			y = 1443.7177
		},
		{
			z = 10.8203,
			x = 2537.3787,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2517.3787,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2497.2917,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2477.2917,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2457.2917,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2437.2917,
			y = 1463.2042
		},
		{
			z = 10.8203,
			x = 2437.2917,
			y = 1443.7338
		},
		{
			z = 10.8203,
			x = 2417.6509,
			y = 1443.7338
		},
		{
			z = 10.8203,
			x = 2417.6509,
			y = 1463.5394
		},
		{
			z = 10.8203,
			x = 2397.6509,
			y = 1463.5394
		},
		{
			z = 10.8203,
			x = 2377.2336,
			y = 1463.5394
		},
		{
			z = 10.8203,
			x = 2377.2336,
			y = 1483.5394
		},
		{
			z = 10.8203,
			x = 2377.2336,
			y = 1503.5394
		},
		{
			z = 10.8203,
			x = 2377.2336,
			y = 1523.5394
		},
		{
			z = 10.8203,
			x = 2377.2336,
			y = 1544.2731
		},
		{
			z = 10.8203,
			x = 2397.2336,
			y = 1544.2731
		},
		{
			z = 10.8203,
			x = 2416.4927,
			y = 1544.2731
		},
		{
			z = 10.8203,
			x = 2416.4927,
			y = 1564.2731
		},
		{
			z = 10.8203,
			x = 2416.4927,
			y = 1584.2731
		},
		{
			z = 10.8203,
			x = 2416.4927,
			y = 1602.2731
		},
		{
			z = 10.8203,
			x = 2396.2979,
			y = 1602.2731
		},
		{
			z = 10.8203,
			x = 2376.2979,
			y = 1602.2731
		},
		{
			z = 10.8203,
			x = 2357.2979,
			y = 1602.2731
		},
		{
			z = 10.8125,
			x = 2357.7,
			y = 1623.0925
		},
		{
			z = 10.8203,
			x = 2377.585,
			y = 1622.8973
		},
		{
			z = 10.8203,
			x = 2377.6553,
			y = 1634.9568
		},
		{
			z = 10.8203,
			x = 2381.2437,
			y = 1634.9568
		},
		{
			z = 10.8203,
			x = 2381.2437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2401.5437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2421.5437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2441.5437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2461.5437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2481.5437,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2493.3245,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2493.3245,
			y = 1634.9568
		},
		{
			z = 10.8203,
			x = 2497.0425,
			y = 1634.9167
		},
		{
			z = 10.8203,
			x = 2497.2368,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2517.2368,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2537.6428,
			y = 1622.9124
		},
		{
			z = 10.8203,
			x = 2537.7466,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2557.0486,
			y = 1642.3307
		},
		{
			z = 10.8203,
			x = 2557.0486,
			y = 1622.9124
		}
	}
    zone_seven = {
		{
			z = 6.824,
			x = 2537.2876,
			y = 842.8511
		},
		{
			z = 6.8188,
			x = 2551.9155,
			y = 848.4091
		},
		{
			z = 6.816,
			x = 2557.2634,
			y = 850.8836
		},
		{
			z = 6.8152,
			x = 2565.448,
			y = 854.8255
		},
		{
			z = 6.8216,
			x = 2579.3372,
			y = 861.3795
		},
		{
			z = 6.8195,
			x = 2604.3818,
			y = 876.5811
		},
		{
			z = 6.8233,
			x = 2626.9768,
			y = 893.5685
		},
		{
			z = 6.8229,
			x = 2648.2249,
			y = 912.6078
		},
		{
			z = 6.824,
			x = 2667.1926,
			y = 933.7818
		},
		{
			z = 6.8059,
			x = 2673.9058,
			y = 943.118
		},
		{
			z = 6.8884,
			x = 2677.0498,
			y = 943.118
		},
		{
			z = 7.5141,
			x = 2681.2546,
			y = 943.118
		},
		{
			z = 8.9637,
			x = 2690.4443,
			y = 943.118
		},
		{
			z = 10.8203,
			x = 2702.1514,
			y = 943.118
		},
		{
			z = 10.8203,
			x = 2721.1514,
			y = 943.118
		},
		{
			z = 10.8203,
			x = 2741.1514,
			y = 943.118
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 943.118
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 923.118
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 903.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 883.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 863.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 843.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 823.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 803.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 783.8044
		},
		{
			z = 10.8203,
			x = 2761.1514,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2740.8921,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2720.8921,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2700.8921,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2677.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2657.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2637.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2617.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2597.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2577.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2557.8401,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2537.4131,
			y = 763.2728
		},
		{
			z = 10.8203,
			x = 2537.4131,
			y = 783.3666
		},
		{
			z = 10.8203,
			x = 2537.22,
			y = 803.2214
		},
		{
			z = 10.8069,
			x = 2537.0405,
			y = 819.7953
		},
		{
			z = 9.587,
			x = 2537.0398,
			y = 830.0216
		},
		{
			z = 6.824,
			x = 2537.2876,
			y = 842.8511
		},
		{
			z = 14.2968,
			x = 2537.2876,
			y = 842.5081
		},
		{
			z = 14.2968,
			x = 2538.5063,
			y = 842.9786
		},
		{
			z = 13.6418,
			x = 2538.5063,
			y = 842.9786
		},
		{
			z = 13.6406,
			x = 2556.2749,
			y = 850.4658
		},
		{
			z = 14.2968,
			x = 2556.2749,
			y = 850.4658
		},
		{
			z = 14.2968,
			x = 2557.2634,
			y = 850.8836
		},
		{
			z = 6.816,
			x = 2557.2634,
			y = 850.8836
		}
	}
	end
end

local var_0_46 = {
	id1 = { squareStart = { x = 307, y = 852.500 }, squareEnd = { x = 402, y = 972.5 }},
	id2 = { squareStart = { x = -473.0, y = 2181 }, squareEnd = { x = -336, y = 2285 }},
	id3 = { squareStart = { x = 59, y = 2385.90 }, squareEnd = { x = 283, y = 2470.9 }},
	id4 = { squareStart = { x = -1909.8, y = -1700.1 }, squareEnd = { x = -1815.8, y = -1574.1 }},
	id5 = { squareStart = { x = 2378, y = 1893.8 }, squareEnd = { x = 2490, y = 1957.8 }},
    id6 = { squareStart = { x = 2473, y = 1515.5 }, squareEnd = { x = 2562, y = 1601.5 }},
    id7 = { squareStart = { x = 2663, y = 836.5 }, squareEnd = { x = 2716, y = 897.5 }},
}

var_0_47 = 4286611584
var_0_48 = 4290522156
var_0_49 = 4284782061

local list2 = {}

function load_ini() -- load mafialines
	if config == nil then
		saveINI()
	else
		only_evolv[0] = config.data[mynick()].mafialines.onlyServer
		time_capt[0] = config.data[mynick()].mafialines.onlyCapture
		radar_lines[0] = config.data[mynick()].mafialines.radarRender
		type_radar[0] = config.data[mynick()].mafialines.radarMode
		var_0_27[0] = config.data[mynick()].mafialines.width
		var_0_28[0] = config.data[mynick()].mafialines.distancedraw
		var_0_30[0] = config.data[mynick()].mafialines.render_height 
		local var_32_1 = decodeJson(config.data[mynick()].mafialines.color)
	
		ev2 = imgui.new.float[4](var_32_1[1], var_32_1[2], var_32_1[3], var_32_1[4])
		var_0_26[0] = config.data[mynick()].mafialines.rainbowc
		var_0_29[0] = config.data[mynick()].mafialines.mode
		ev0[0] = config.data[mynick()].mafialines.trailalpha
		ev1[0] = config.data[mynick()].mafialines.trailspeed
		lines_status[0] = config.data[mynick()].mafialines.activated
		id1_status[0] = config.data[mynick()].mafialines.quarryed
		id2_status[0] = config.data[mynick()].mafialines.villaged
		id3_status[0] = config.data[mynick()].mafialines.airported
		id4_status[0] = config.data[mynick()].mafialines.mined
		id5_status[0] = config.data[mynick()].mafialines.buildinged
        id6_status[0] = config.data[mynick()].mafialines.piligrim
        id7_status[0] = config.data[mynick()].mafialines.rokwor
		var_0_14 = join_argb(var_32_1[4] * 255, var_32_1[1] * 255, var_32_1[2] * 255, var_32_1[3] * 255)
	end
end

function bload_ini() -- load mafialines
	if config == nil then
		bsaveINI()
	else

		b_radar_lines[0] = config.data[mynick()].bikerlines.radarRender
		b_var_0_27[0] = config.data[mynick()].bikerlines.width
		b_var_0_28[0] = config.data[mynick()].bikerlines.distancedraw
		b_var_0_30[0] = config.data[mynick()].bikerlines.render_height 
		b_var_32_1 = decodeJson(config.data[mynick()].bikerlines.color)
	zone_blueberry[0] = config.data[mynick()].bikerlines.zone_blueberry
zone_montgomery[0] = config.data[mynick()].bikerlines.zone_montgomery
zone_palomino_creek[0] = config.data[mynick()].bikerlines.zone_palomino_creek
zone_dillimore[0] = config.data[mynick()].bikerlines.zone_dillimore
zone_fort_carson[0] = config.data[mynick()].bikerlines.zone_fort_carson
zone_las_barrancas[0] = config.data[mynick()].bikerlines.zone_las_barrancas
zone_el_quebrados[0] = config.data[mynick()].bikerlines.zone_el_quebrados
zone_angel_pine[0] = config.data[mynick()].bikerlines.zone_angel_pine


		b_ev2 = imgui.new.float[4](b_var_32_1[1], b_var_32_1[2], b_var_32_1[3], b_var_32_1[4])
		b_var_0_26[0] = config.data[mynick()].bikerlines.rainbowc
		b_var_0_29[0] = config.data[mynick()].bikerlines.mode
		b_ev0[0] = config.data[mynick()].bikerlines.trailalpha
		b_ev1[0] = config.data[mynick()].bikerlines.trailspeed
		b_lines_status[0] = config.data[mynick()].bikerlines.activated

		var_0_142 = join_argb(b_var_32_1[4] * 255, b_var_32_1[1] * 255, b_var_32_1[2] * 255, b_var_32_1[3] * 255)
	end
end
function check_server()
	local var_4_0, var_4_1 = sampGetCurrentServerAddress()
	local var_4_2 = sampGetCurrentServerName()

	if var_4_0 == "185.169.134.67" or var_4_2:find("Evolve") and var_4_2:find("Saint%-Louis") then
		return "Saint-Louis"
	elseif var_4_0 == "185.169.134.68" or var_4_2:find("Evolve") and var_4_2:find("New Orleans") then
		return "New Orleans"
	end
end



keyToggle = VK_MBUTTON
keyApply = VK_LBUTTON


WSstatus = false
WS_URL = "ws://zara.hidencloud.com:24680/evolve"
SEND_POSITION_INTERVAL = 200
MAP_STALE_TIME = 30
WORLD_HALF = 3000
MAP_DIRECTORY = getGameDirectory() .."/moonloader/Palenation Tool Extended/resource/"
players = {}
mapActive = false
cursorActive = false
webfont = nil
fontSmall = nil
fontPlayer = nil
fontHp = nil
mapTextures = {}
mapLoaded = false
markerTexture = nil
playerTexture = nil
matavozTexture = nil
matavozTexturePath = MAP_DIRECTORY .. "matavoz.png"
matavozWorldX = 0
matavozWorldY = 0
matavozWorldZ = 0
matavozTime = 0
markerTexturePath = MAP_DIRECTORY .. "marker.png"
--[[if config.data.glonass.marker == 1 then
    markerTexturePath = MAP_DIRECTORY .. "marker2.png"
end]]
playerTexturePath = MAP_DIRECTORY .. "pla.png"
lastPositionSendTime = 0
lastStatusText = "не запущено"

local socketIsAlive

SquareList = {
    "А", "Б", "В", "Г", "Д", "Ж", "З", "И",
    "К", "Л", "М", "Н", "О", "П", "Р", "С",
    "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Я"
}

markerBlip = nil
markerPickup = nil
markerCheck = nil
markerWorldX = nil
markerWorldY = nil

function wsLog(msg)
    print(msg)
end

function round(number)
    return number - (number % 1)
end

function getUli(x, y)
    local y1 = y * -1 + 3000
    local x1 = x + 3000
    local x2 = math.ceil((x + 3000) / 250)
    local y2 = math.ceil((y * -1 + 3000) / 250)
    local xu = x1 - (x2 * 250 - 250)
    local yu = y1 - (y2 * 250 - 250)
    local xu1 = xu / 250
    local yu1 = yu / 250
    local xup, yup

    if xu1 < 0.33 then
        xup = 1
    elseif xu1 < 0.66 then
        xup = 2
    else
        xup = 3
    end

    if yu1 < 0.33 then
        yup = 1
    elseif yu1 < 0.66 then
        yup = 2
    else
        yup = 3
    end

    if yup == 1 then
        return xup
    elseif yup == 2 then
        if xup == 1 then return 8 end
        if xup == 2 then return 9 end
        return 4
    elseif yup == 3 then
        if xup == 1 then return 7 end
        if xup == 2 then return 6 end
        return 5
    end

    return 0
end

function getKv(x, y)
    local row = math.ceil((y * -1 + 3000) / 250)
    local column = math.ceil((x + 3000) / 250)
    local letter = SquareList[row]

    if not letter then
        return "Unknown"
    end

    return letter .. "-" .. column .. "-" .. getUli(x, y)
end

function clearMarker()
    if markerBlip then
        removeBlip(markerBlip)
    end

    if markerPickup then
        removePickup(markerPickup)
    end

    if markerCheck then
        deleteCheckpoint(markerCheck)
    end

    markerBlip = nil
    markerPickup = nil
    markerCheck = nil
    markerWorldX = nil
    markerWorldY = nil
end

function announceMarkerInChat(nick, x, y)
    local square = "Unknown"

    local ok, result = pcall(function()
        return getKv(round(x), round(y))
    end)

    if ok and result then
        square = result
    end

    sampAddChatMessage(
        string.format(
            "%s установил метку в квадрат %s.",
            tostring(nick or "Unknown"),
            square
        ),
        0xe01b1b
    )
end

function drawMarker(x, y, z)
    clearMarker()

    markerWorldX = tonumber(x)
    markerWorldY = tonumber(y)

    local _, pickup = createPickup(19605, 19, x, y, z)
    markerPickup = pickup

    markerCheck = createCheckpoint(
        2,
        x,
        y,
        z,
        1,
        1,
        1,
        2.5
    )

    markerBlip = addSpriteBlipForCoord(x, y, z, 56)

    addOneOffSound(0, 0, 0, 1190)

    lua_thread.create(function()
        repeat
            wait(0)

            local x1, y1, z1 =
                getCharCoordinates(PLAYER_PED)

        until getDistanceBetweenCoords3d(
            x,
            y,
            z,
            x1,
            y1,
            z1
        ) < 2.5

        clearMarker()
    end)
end

function getMyNickname()
    local ok, playerId = pcall(function()
        local _, id =
            sampGetPlayerIdByCharHandle(PLAYER_PED)

        return id
    end)

    if ok and playerId then
        local okName, name =
            pcall(
                sampGetPlayerNickname,
                playerId
            )

        if okName and name and name ~= "" then
            return name
        end
    end

    return "Unknown"
end

function get_crosshair_position()
    local vec_out = ffi.new("float[3]")
    local tmp_vec = ffi.new("float[3]")

    ffi.cast(
        "void (__thiscall*)(void*, float, float, float, float, float*, float*)",
        0x514970
    )(
        ffi.cast("void*", 0xB6F028),
        15.0,
        tmp_vec[0],
        tmp_vec[1],
        tmp_vec[2],
        tmp_vec,
        vec_out
    )

    return vec_out[0], vec_out[1], vec_out[2]
end

function getAimWorldPoint()
    local resX, resY =
        convert3DCoordsToScreen(
            get_crosshair_position()
        )

    local targetX, targetY, targetZ =
        convertScreenCoordsToWorld3D(
            resX,
            resY,
            3600
        )

    local originX, originY, originZ =
        getActiveCameraCoordinates()

    local result, colPoint =
        processLineOfSight(
            originX,
            originY,
            originZ,
            targetX,
            targetY,
            targetZ,
            true,
            true,
            false,
            true,
            true,
            true,
            true,
            true
        )

    if not result then
        return nil
    end

    return
        colPoint.pos[1],
        colPoint.pos[2],
        colPoint.pos[3]
end

wsClient = nil
wsConnected = false
reconnectRequested = false
pendingMarker = nil
pendingClientList = false
pendingSync = false
pendingIdentify = false
lastSendTime = 0

function loadMapTextures()
    mapTextures = {}
    mapLoaded = false

   -- wsLog("CTORY: " .. MAP_DIRECTORY)

    local loaded = 0

    for i = 1, 16 do
        local path = MAP_DIRECTORY .. tostring(i) .. ".png"
        if config.data[mynick()].glonass.tip == 2 then
            path = MAP_DIRECTORY .. tostring(i) .. "k.png"
        end

        if config.data[mynick()].glonass.tip == 1 then
            path = MAP_DIRECTORY .. tostring(i) .. "c.png"
        end

        if config.data[mynick()].glonass.tip == 3 then
            path = MAP_DIRECTORY .. tostring(i) .. "d.png"
        end
        if not doesFileExist(path) then
            wsLog(
                "MAP TILE " ..
                tostring(i) ..
                " NOT FOUND: " ..
                path
            )
        else
            local texture = renderLoadTextureFromFile(path)

            if texture then
                mapTextures[i] = texture
                loaded = loaded + 1
               -- wsLog("MAP TILE " .. tostring(i) .. " LOADED")
            else
                wsLog("MAP TILE " .. tostring(i) .. " LOAD FAILED")
            end
        end
    end

    if loaded == 16 then
        mapLoaded = true
        wsLog("MAP LOADED: 16/16")
    else
        wsLog("MAP INCOMPLETE: " .. tostring(loaded) .. "/16")
    end

    -- Загружаем иконку Matavoz (SetMapIcon type 51).
    if doesFileExist(matavozTexturePath) then
        matavozTexture = renderLoadTextureFromFile(matavozTexturePath)
        if not matavozTexture then
            wsLog("MATAVOZ ICON LOAD FAILED: " .. matavozTexturePath)
        end
    else
        wsLog("MATAVOZ ICON NOT FOUND: " .. matavozTexturePath)
    end

    -- Загружаем иконку установленной метки.
    if doesFileExist(markerTexturePath) then
        markerTexture = renderLoadTextureFromFile(markerTexturePath)
        if markerTexture then
         --   wsLog("MARKER ICON LOADED: " .. markerTexturePath)
        else
            wsLog("MARKER ICON LOAD FAILED: " .. markerTexturePath)
        end
    else
        wsLog("MARKER ICON NOT FOUND: " .. markerTexturePath)
    end

    -- Загружаем иконку игрока.
    if doesFileExist(playerTexturePath) then
        playerTexture = renderLoadTextureFromFile(playerTexturePath)
        if playerTexture then
          --  wsLog("PLAYER ICON LOADED: " .. playerTexturePath)
        else
            wsLog("PLAYER ICON LOAD FAILED: " .. playerTexturePath)
        end
    else
        wsLog("PLAYER ICON NOT FOUND: " .. playerTexturePath)
    end
end

function worldToScreen(x, y, bx, by)
    local sx =
        bx +
        (x + WORLD_HALF) *
        (config.data[mynick()].glonass.size / (WORLD_HALF * 2))

    local sy =
        by +
        config.data[mynick()].glonass.size -
        (y + WORLD_HALF) *
        (config.data[mynick()].glonass.size / (WORLD_HALF * 2))

    return sx, sy
end

function getMapBounds()
    local resX, resY = getScreenResolution()

    local bx = (resX - config.data[mynick()].glonass.size) / 2
    local by = (resY - config.data[mynick()].glonass.size) / 2

    return bx, by
end

function screenToWorld(sx, sy, bx, by)
    local worldX =
        ((sx - bx) / config.data[mynick()].glonass.size) *
        (WORLD_HALF * 2) -
        WORLD_HALF

    local worldY =
        WORLD_HALF -
        ((sy - by) / config.data[mynick()].glonass.size) *
        (WORLD_HALF * 2)

    return worldX, worldY
end

function placeMarkerFromMapClick(action)
    if not mapActive then
        return
    end

    if sampIsChatInputActive()
        or isSampfuncsConsoleActive()
        or sampIsDialogActive()
    then
        return
    end

    local bx, by = getMapBounds()

    -- В MoonLoader cursor coordinates are screen coordinates.
    local mouseX, mouseY = getCursorPos()

    if not mouseX or not mouseY then
        return
    end

    if mouseX < bx
        or mouseX > bx + config.data[mynick()].glonass.size
        or mouseY < by
        or mouseY > by + config.data[mynick()].glonass.size
    then
        return
    end

    local worldX, worldY =
        screenToWorld(
            mouseX,
            mouseY,
            bx,
            by
        )

    -- The minimap is 2D, so use the player's current Z.
    local _, _, playerZ =
        getCharCoordinates(PLAYER_PED)



    if action == "remove" then
        removeMarkerNetwork()
    else
        placeMarkerNetwork(
            worldX,
            worldY,
            playerZ
        )
    end
end

function enableMapCursor()
    if cursorActive then
        return
    end

    sampSetCursorMode(3)
    cursorActive = true
end

function disableMapCursor()
    if not cursorActive then
        return
    end

    sampSetCursorMode(0)
    cursorActive = false
end

function drawMapTextures(bx, by)
    if not mapLoaded then
        return
    end

    local tile = config.data[mynick()].glonass.size / 4

    renderDrawTexture(mapTextures[1],  bx,             by,             tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[2],  bx + tile,      by,             tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[3],  bx + tile * 2,  by,             tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[4],  bx + tile * 3,  by,             tile, tile, 0, 0xFFFFFFFF)

    renderDrawTexture(mapTextures[5],  bx,             by + tile,      tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[6],  bx + tile,      by + tile,      tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[7],  bx + tile * 2,  by + tile,      tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[8],  bx + tile * 3,  by + tile,      tile, tile, 0, 0xFFFFFFFF)

    renderDrawTexture(mapTextures[9],  bx,             by + tile * 2,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[10], bx + tile,      by + tile * 2,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[11], bx + tile * 2,  by + tile * 2,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[12], bx + tile * 3,  by + tile * 2,  tile, tile, 0, 0xFFFFFFFF)

    renderDrawTexture(mapTextures[13], bx,             by + tile * 3,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[14], bx + tile,      by + tile * 3,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[15], bx + tile * 2,  by + tile * 3,  tile, tile, 0, 0xFFFFFFFF)
    renderDrawTexture(mapTextures[16], bx + tile * 3,  by + tile * 3,  tile, tile, 0, 0xFFFFFFFF)
end

function drawConnectionStatus(bx, by)
    if socketIsAlive() then
        return
    end

    if not webfont or not fontSmall then
        return
    end

    renderFontDrawText(
        webfont,
        "нет соединения с сервером",
        bx + 10,
        by + 10,
        0xFFFF0000
    )

    renderFontDrawText(
        fontSmall,
        "status: " .. tostring(lastStatusText),
        bx + 10,
        by + 26,
        0xFFFFFF00
    )
end

function getMyCameraHeading()
    -- Направление взгляда камеры, а не поворот самого педа.
    -- Это именно то, что нужно для иконки как на радаре.
    local cx, cy, cz = getActiveCameraCoordinates()
    local tx, ty, tz = getActiveCameraPointAt()

    return getHeadingFromVector2d(
        tx - cx,
        ty - cy
    )
end

function drawOwnPlayer(bx, by)
    local x, y = getCharCoordinates(PLAYER_PED)
    local sx, sy = worldToScreen(x, y, bx, by)

    if sx < bx or sx > bx + config.data[mynick()].glonass.size
        or sy < by or sy > by + config.data[mynick()].glonass.size then
        return
    end

    if playerTexture then
        local iconSize = config.data[mynick()].glonass.people_size

        -- ВАЖНО:
        -- getCharHeading() показывает направление педа.
        -- Нам нужно направление взгляда/камеры, как на радаре.
        local heading = getMyCameraHeading()

        -- Как в Edith: угол передаётся напрямую со знаком "-".
        renderDrawTexture(
            playerTexture,
            sx - iconSize / 2,
            sy - iconSize / 2,
            iconSize,
            iconSize,
            -heading,
            -1
        )
    else
        renderDrawBox(
            sx - 4,
            sy - 4,
            8,
            8,
            0xFF00FF00
        )
    end

    if fontSmall and tonumber(config.data[mynick()].glonass.nick) ~= 0 then
        renderFontDrawText(
            fontSmall,
            "You",
            sx + 10,
            sy - 7,
            0xFF00FF00
        )
    end
end

function drawOtherPlayers(bx, by)
    local now = os.time()
    local myNick = tostring(getMyNickname() or "")

    for nick, p in pairs(players) do
        if tostring(nick) ~= myNick and p and p.x and p.y then
            local timestamp = tonumber(p.timestamp)

            if not timestamp or (now - timestamp) < MAP_STALE_TIME then
                local psx, psy = worldToScreen(
                    tonumber(p.x),
                    tonumber(p.y),
                    bx,
                    by
                )

                if psx >= bx and psx <= bx + config.data[mynick()].glonass.size
                    and psy >= by and psy <= by + config.data[mynick()].glonass.size then

                    -- Поворот полностью как в Edith: -heading.
                    local heading = tonumber(p.heading) or 0

                    -- Edith uses the server-provided heading directly,
                    -- negated, without converting to radians.
                    local rotation = -heading

                    if playerTexture then
                        local iconSize = config.data[mynick()].glonass.people_size

                        renderDrawTexture(
                            playerTexture,
                            psx - iconSize / 2,
                            psy - iconSize / 2,
                            iconSize,
                            iconSize,
                            rotation,
                            0xFFFFFFFF
                        )
                    else
                        renderDrawBox(
                            psx - 3,
                            psy - 3,
                            6,
                            6,
                            0xFFFF0000
                        )
                    end

                    -- Ник маленький, HP отдельной строкой и чуть крупнее.
                    local health = tonumber(p.health) or 0
                    local nickText = tostring(nick)
                    local hpText = tostring(math.floor(health)) .. " HP"

                    -- Более 60 HP — ярко-салатовый, 60 и ниже — ярко-красный.
                    local hpColor
                    if health > 60 then
                        hpColor = 0xFF7CFC00
                    else
                        hpColor = 0xFFFF3030
                    end

                    local nickFont = fontPlayer or fontSmall
                    local hpFont = fontHp or nickFont

                    if nickFont and tonumber(config.data[mynick()].glonass.nick) ~= 0  then
                        -- Чёрная тень/обводка ника.
                        renderFontDrawText(
                            nickFont,
                            nickText,
                            psx + 12,
                            psy - 10,
                            0xFF000000
                        )

                        renderFontDrawText(
                            nickFont,
                            nickText,
                            psx + 11,
                            psy - 11,
                            0xFFFFFFFF
                        )
                    end

                    if hpFont and tonumber(config.data[mynick()].glonass.hp) ~= 0 then
                        -- Чёрная тень/обводка HP.
                        renderFontDrawText(
                            hpFont,
                            hpText,
                            psx + 12,
                            psy + 1,
                            0xFF000000
                        )

                        renderFontDrawText(
                            hpFont,
                            hpText,
                            psx + 11,
                            psy,
                            hpColor
                        )
                    end
                end
            end
        end
    end
end

function drawMatavozOnMap(bx, by)
    -- Edith показывает matavoz для последнего SetMapIcon с type == 51
    -- в течение 50 секунд. Делаем ту же логику в MultiTool.
    if not matavozTexture then
        return
    end

    if matavozWorldX == 0 and matavozWorldY == 0 then
        return
    end

    if matavozTime <= 0 or matavozTime + 50 <= os.clock() then
        return
    end

    local sx, sy = worldToScreen(
        matavozWorldX,
        matavozWorldY,
        bx,
        by
    )

    if sx < bx - 20 or sx > bx + config.data[mynick()].glonass.size + 20
        or sy < by - 20 or sy > by + config.data[mynick()].glonass.size + 20 then
        return
    end

    local iconSize = config.data[mynick()].glonass.matavoz_size

    renderDrawTexture(
        matavozTexture,
        sx - iconSize / 2,
        sy - iconSize / 2,
        iconSize,
        iconSize,
        0,
        0xFFFFFFFF
    )
end

function drawMarkerOnMap(bx, by)
    if not markerBlip then
        return
    end

    if not markerWorldX or not markerWorldY then
        return
    end

    local sx, sy = worldToScreen(
        markerWorldX,
        markerWorldY,
        bx,
        by
    )

    if sx < bx - 20 or sx > bx + config.data[mynick()].glonass.size + 20
        or sy < by - 20 or sy > by + config.data[mynick()].glonass.size + 20 then
        return
    end

    if markerTexture then
        local iconSize = config.data[mynick()].glonass.marker_size

        renderDrawTexture(
            markerTexture,
            sx - iconSize / 2,
            sy - iconSize / 2,
            iconSize,
            iconSize,
            0,
            0xFFFFFFFF
        )
    else
        -- Запасной вариант, если marker.png не загрузился.
        renderDrawBox(
            sx - 5,
            sy - 5,
            10,
            10,
            0xFFFFFF00
        )
    end
end

function drawMapFrame()
    if not mapActive then
        return
    end

    local bx, by = getMapBounds()

    drawMapTextures(bx, by)
    drawConnectionStatus(bx, by)
    drawOwnPlayer(bx, by)
    drawOtherPlayers(bx, by)
    drawMatavozOnMap(bx, by)
    drawMarkerOnMap(bx, by)
end

function onD3DPresent()
    if not mapActive then
        return
    end

    drawMapFrame()
end
function socketIsAlive()
    if not wsConnected or wsClient == nil then
        return false
    end

    state =
        tostring(wsClient.state or ""):upper()

    if state == "CLOSED" or state == "CLOSING" then
        return false
    end

    return true
end

function closeWs()
    wsConnected = false

    local old = wsClient
    wsClient = nil

    if old then
        pcall(function()
            old:close()
        end)
    end
end

function connectWs()
    if not wsModuleOk then
        wsLog("WEBSOCKET MODULE LOAD ERROR")
        return false
    end

    closeWs()

    local client = websocket.client.copas({timeout = 5})

    if not client then
        wsLog("WS CREATE ERROR")
        return false
    end

    wsLog("WS CONNECT")

    local connected, err =
        client:connect(WS_URL)

    if not connected then
        wsLog(
            "WS CONNECT FAILED: " ..
            tostring(err)
        )

        pcall(function()
            client:close()
        end)

        return false
    end

    wsClient = client
    wsConnected = true
    reconnectRequested = false
    pendingIdentify = true
    wsLog("WS CONNECTED")

    return true
end

function processServerResponse(response)
    if type(response) ~= "table" then
        return
    end

    if response.type == "heartbeat" then
        return
    end

    -- GLONASS: сервер присылает актуальные координаты всех игроков.
    -- Сохраняем их в players, откуда drawOtherPlayers() рисует их на мини-карте.
    if response.type == "glonass" then
        players = response.players or {}
        return
    end

    -- VK BOT: запрос списка администраторов.
    -- Сервер отправляет этот запрос только одному случайно выбранному
    -- пользователю из комнаты /evolve.
    if response.type == "admins_request" then
        local requestId = tostring(response.request_id or "")

        if requestId == "" then
            return
        end

        local function sendAdminsResponse()
            local admins = {}

            local ok, result = pcall(function()
                return var_0_177_2()
            end)

            if ok and type(result) == "table" then
                admins = result
            end

            local payload = encodeJson({
                type = "admins_response",
                request_id = requestId,
                nick = getMyNickname(),
                admins = admins
            })

            local sent, err = wsSendSafe(payload)

            if not sent then
                wsLog("ADMINS RESPONSE SEND FAILED: " .. tostring(err))
            else
                wsLog("ADMINS RESPONSE SENT: " .. tostring(requestId))
            end
        end

        -- Если CSV ещё не загружен, сначала загружаем его, затем отвечаем.
        if not var_0_174 then
            if not var_0_175 then
                LoadAdminList(function()
                    sendAdminsResponse()
                end, true)
            else
                -- Другой поток уже загружает CSV. Ждём его завершения.
                lua_thread.create(function()
                    local deadline = os.clock() + 10

                    while var_0_175 and not var_0_174 and os.clock() < deadline do
                        wait(100)
                    end

                    if not var_0_174 then
                        -- Повторная попытка загрузки.
                        LoadAdminList(function()
                            sendAdminsResponse()
                        end, true)
                    else
                        sendAdminsResponse()
                    end
                end)
            end
        else
            sendAdminsResponse()
        end

        return
    end

    -- VK BOT: запрос онлайн всех фракций Онлайн крайма.
    -- Отправляем именно текущие значения cho_gang / cho_biker / cho_maf,
    -- которые скрипт уже рассчитывает для локальной команды /cho.
    if response.type == "cho_request" then
        local requestId = tostring(response.request_id or "")
        if requestId == "" then
            return
        end

        local payload = encodeJson({
            type = "cho_response",
            request_id = requestId,
            nick = getMyNickname(),
            cho_gang = tostring(cho_gang or ""),
            cho_biker = tostring(cho_biker or ""),
            cho_maf = tostring(cho_maf or "")
        })

        local sent, err = wsSendSafe(payload)
        if not sent then
            wsLog("CHO RESPONSE SEND FAILED: " .. tostring(err))
        else
            wsLog("CHO RESPONSE SENT: " .. tostring(requestId))
        end

        return
    end

    -- VK BOT: запрос списка байкеров.
    -- Повторяем ту же логику, что используется в локальной Bikerlist-панели:
    -- проверяем цвет игрока в bikerlist_organization и наличие "_" в никнейме.
    if response.type == "bikerlist_request" then
        local requestId = tostring(response.request_id or "")
        if requestId == "" then
            return
        end

        local bikers = {}
        local ok, err = pcall(function()
            local myId = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
            local maxPlayers = sampGetMaxPlayerId()

            for i = 0, maxPlayers do
                if sampIsPlayerConnected(i) or i == myId then
                    local nick = sampGetPlayerNickname(i)
                    if nick and nick:find("_") then
                        local color = sampGetPlayerColor(i)
                        local organization = bikerlist_organization[color]

                        if organization then
                            table.insert(bikers, {
                                organization = tostring(organization),
                                nickname = tostring(nick),
                                id = i,
                                color = color
                            })
                        end
                    end
                end
            end
        end)

        if not ok then
            wsLog("BIKERLIST BUILD ERROR: " .. tostring(err))
        end

        local payload = encodeJson({
            type = "bikerlist_response",
            request_id = requestId,
            nick = getMyNickname(),
            bikers = bikers
        })

        local sent, sendErr = wsSendSafe(payload)
        if not sent then
            wsLog("BIKERLIST RESPONSE SEND FAILED: " .. tostring(sendErr))
        else
            wsLog("BIKERLIST RESPONSE SENT: " .. tostring(requestId) .. " COUNT=" .. tostring(#bikers))
        end

        return
    end

    -- VK BOT: запрос списка игроков, которые реально подключены к SA-MP.
    if response.type == "online_request" then
        local requestId = tostring(response.request_id or "")
        if requestId == "" then
            return
        end

        local playersOnline = {}
        local maxPlayers = sampGetMaxPlayerId()
        for id = 0, maxPlayers do
            if sampIsPlayerConnected(id) then
                local nick = sampGetPlayerNickname(id)
                if nick and nick ~= "" then
                    table.insert(playersOnline, {
                        nick = nick,
                        id = id
                    })
                end
            end
        end

        local payload = encodeJson({
            type = "online_response",
            request_id = requestId,
            nick = getMyNickname(),
            players = playersOnline
        })

        local sent, err = wsSendSafe(payload)
        if not sent then
            wsLog("ONLINE RESPONSE SEND FAILED: " .. tostring(err))
        else
            wsLog("ONLINE RESPONSE SENT: " .. tostring(requestId))
        end

        return
    end

    if response.type == "clients" then
        local list = response.clients or {}
        local found = {}
        local maxPlayers = sampGetMaxPlayerId()
        for _, nick in ipairs(list) do
            for id = 0, maxPlayers do
                if sampIsPlayerConnected(id) then
                    local gameNick = sampGetPlayerNickname(id)

                    if gameNick == nick then
                        table.insert(found, {
                            nick = nick,
                            id = id
                        })
                      --  break
                    end
                end
            end
        end



        for i, player in ipairs(found) do
            sampAddChatMessage(
                string.format(
                    "{FFFFFF}%d. %s {AAAAAA}[ID: %d]",
                    i,
                    tostring(player.nick),
                    player.id
                ),
                -1
            )
        end
        msg(
            string.format("Онлайн: %d", #found),
            -1
        )
        return
    end

    if response.type ~= "marker" then
        return
    end

    local x = tonumber(response.x)
    local y = tonumber(response.y)
    local z = tonumber(response.z)
    local nick = tostring(
        response.nick or "Unknown"
    )

    if not x or not y or not z then
     ------   wsLog("WS RESPONSE: invalid coordinates")
        return
    end

    local myNick = tostring(
        getMyNickname() or ""
    )

    if myNick ~= ""
        and myNick ~= "Unknown"
        and nick == myNick
    then
       --- wsLog("OWN MARKER IGNORED")
        return
    end

    local okChat, chatErr =
        pcall(
            announceMarkerInChat,
            nick,
            x,
            y
        )

    if not okChat then
        wsLog(
            "CHAT ERROR: " ..
            tostring(chatErr)
        )
    end

    local okDraw, drawErr =
        pcall(
            drawMarker,
            x,
            y,
            z
        )

    if not okDraw then
        wsLog(
            "DRAW ERROR: " ..
            tostring(drawErr)
        )
    end
end

function receiveOne()
    if not socketIsAlive() then
        return false
    end

    local raw, err =
        wsClient:receive()

    if raw == nil then
        local reason =
            tostring(err or ""):lower()

        local state =
            tostring(wsClient.state or ""):upper()

        if state ~= "CLOSED"
            and state ~= "CLOSING"
            and (
                reason == ""
                or reason:find("timeout")
                or reason:find("would block")
                or reason:find("tempor")
            )
        then
            return true
        end

        wsLog(
            "WS RECEIVE DISCONNECTED: " ..
            tostring(err)
        )

        wsConnected = false
        reconnectRequested = true

        return false
    end

    if raw == "" then
        return true
    end

    wsLog("WS RECEIVE: " .. tostring(raw))

    local ok, response =
        pcall(
            decodeJson,
            raw
        )

    if not ok then
        wsLog(
            "WS JSON ERROR: " ..
            tostring(response)
        )

        return true
    end

    local okProcess, processErr =
        pcall(
            processServerResponse,
            response
        )

    if not okProcess then
        wsLog(
            "WS PROCESS ERROR: " ..
            tostring(processErr)
        )
    end

    return true
end

function queueMarker(x, y, z)
    pendingMarker = {
        x = tonumber(x),
        y = tonumber(y),
        z = tonumber(z),
        nick = getMyNickname()
    }
end


function sendOwnPosition()
    if not socketIsAlive() then
        return false
    end

    local now = os.clock() * 1000

    if now - lastPositionSendTime < SEND_POSITION_INTERVAL then
        return true
    end

    lastPositionSendTime = now

    local x, y, z = getCharCoordinates(PLAYER_PED)
    local heading = getCharHeading(PLAYER_PED)
    local health = getCharHealth(PLAYER_PED)
    local nick = getMyNickname()

    local payload = encodeJson({
        type = "glonass",
        nick = nick,
        x = x,
        y = y,
        z = z,
        heading = heading,
        health = health
    })

    local sent, err = wsSendSafe(payload)

    if not sent then
        wsLog(
            "WS GLONASS SEND FAILED: " ..
            tostring(err)
        )

        lastStatusText =
            "position send failed: " ..
            tostring(err)

        wsConnected = false
        reconnectRequested = true

        return false
    end

    return true
end

function sendPendingMarker()
    if not socketIsAlive() then
        return false
    end

    if pendingMarker == nil then
        return true
    end

    local now = os.clock() * 1000

    if now - lastSendTime < 150 then
        return true
    end

    local marker = pendingMarker
    pendingMarker = nil

    local raw = encodeJson({
        type = "marker",
        x = marker.x,
        y = marker.y,
        z = marker.z,
        nick = marker.nick
    })



    local sent, err =
        wsClient:send(raw)

    lastSendTime = now

    if not sent then
        wsLog(
            "WS SEND FAILED: " ..
            tostring(err)
        )

        pendingMarker = marker
        wsConnected = false
        reconnectRequested = true

        return false
    end


    return true
end

function placeMarkerNetwork(x, y, z)
    local nick = getMyNickname()

    drawMarker(x, y, z)
    announceMarkerInChat(nick, x, y)

    queueMarker(x, y, z)


end

function markerWsCommand()
    WSstatus = not WSstatus

    if WSstatus then
        msg("WebSocket включен.", -1)
        reconnectRequested = true
    else
        msg("WebSocket выключен.", -1)
        pendingMarker = nil
        pendingClientList = false
        pendingIdentify = false
        reconnectRequested = false
        closeWs()
    end
end

function markerListCommand()
    if not WSstatus then
        msg(
            "WebSocket выключен.",
            -1
        )
        return
    end

    if not socketIsAlive() then
        msg(
            "WebSocket не подключен.",
            -1
        )
        return
    end

    pendingClientList = true

    msg(
        "Запрашиваю список игроков...",
        -1
    )
end

function sendPendingIdentify()
    if not socketIsAlive() or not pendingIdentify then
        return false
    end

    local nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

    if not nick or nick == "" then
        return false
    end

    local payload = encodeJson({
        type = "identify",
        nick = nick
    })

    local sent, err = wsClient:send(payload)

    if not sent then
        wsLog(
            "WS IDENTIFY SEND FAILED: " ..
            tostring(err)
        )

        wsConnected = false
        reconnectRequested = true
        return false
    end

    pendingIdentify = false
    wsLog("WS IDENTIFY SENT: " .. tostring(nick))
    return true
end
function sendPendingSync()
    if not socketIsAlive() or not pendingSync then
        return false
    end

    pendingSync = false

    -- Один запрос на сервер. Сервер должен вернуть:
    -- {
    --   "type": "sync",
    --   "clients": ["Nick1", "Nick2"],
    --   "messages": [{"nick": "Nick1", "text": "Hello"}]
    -- }
    local sent, err = wsSendSafe('{"type":"sync"}')

    if not sent then
        wsLog("WS SYNC REQUEST FAILED: " .. tostring(err))
        pendingSync = true
        wsConnected = false
        reconnectRequested = true
        return false
    end

    wsLog("WS SYNC REQUEST SENT")
    return true
end
function removeMarkerNetwork()
    local nick = getMyNickname()

    clearMarker()
    queueMarker(nil, nil, nil, "remove")

 --   wsLog("LOCAL MARKER REMOVED: nick=" .. tostring(nick))
end
function wsSendSafe(data)
    -- websocket/frame.lua падает с "attempt to get length of local 'data'"
    -- если в send() передать nil. Не допускаем этого.
    if type(data) ~= "string" or data == "" then
        wsLog(
            "WS SEND BLOCKED: invalid payload type=" ..
            tostring(type(data))
        )
        return false, "invalid websocket payload"
    end

    if not socketIsAlive() then
        return false, "websocket is not connected"
    end

    local ok, sent, err = pcall(function()
        return wsClient:send(data)
    end)

    if not ok then
        wsLog("WS SEND EXCEPTION: " .. tostring(sent))
        wsConnected = false
        reconnectRequested = true
        return false, tostring(sent)
    end

    if not sent then
        wsLog("WS SEND FAILED: " .. tostring(err))
        wsConnected = false
        reconnectRequested = true
        return false, err
    end

    return true
end

function sendPendingClientList()
    if not socketIsAlive() or not pendingClientList then
        return false
    end

    pendingClientList = false

    local sent, err = wsClient:send(
        '{"type":"clients"}'
    )

    if not sent then
        wsLog(
            "WS CLIENT LIST SEND FAILED: " ..
            tostring(err)
        )

        pendingClientList = true
        wsConnected = false
        reconnectRequested = true

        return false
    end

    wsLog("WS CLIENT LIST REQUEST SENT")
    return true
end

function click()
    while true do
        wait(0)

        if WSstatus and isKeysPressed(config.data[mynick()].marker.key) and config.data[mynick()].marker.status and isKeyCanBePressed() then
           ---- wsLog("J PRESSED")

            local x, y, z = getAimWorldPoint()

            if x ~= nil then
                placeMarkerNetwork(x, y, z)
            else
             --   wsLog("getAimWorldPoint returned nil")
            end

            wait(150)
        end
    end
end

function receiveServer()
  ----  wsLog("RECEIVE THREAD STARTED")

    while true do
        wait(0)

        if WSstatus and socketIsAlive() and not wsOperationBusy then
            wsOperationBusy = true
            local raw, err = wsClient:receive()
            wsOperationBusy = false

            if raw then
               -- wsLog("WS RECEIVE: " .. tostring(raw))

                local ok, response = pcall(
                    decodeJson,
                    raw
                )

                if ok then
                    local okProcess, processErr = pcall(
                        processServerResponse,
                        response
                    )

                    if not okProcess then
                        wsLog(
                            "WS PROCESS ERROR: " ..
                            tostring(processErr)
                        )
                    end
                else
                    wsLog(
                        "WS JSON ERROR: " ..
                        tostring(response)
                    )
                end
            else
                local reason = tostring(err or ""):lower()

                if reason ~= ""
                    and not reason:find("timeout")
                    and not reason:find("would block")
                    and not reason:find("tempor")
                then
                    wsLog(
                        "WS RECEIVE ERROR: " ..
                        tostring(err)
                    )

                    wsConnected = false
                    reconnectRequested = true
                end
            end
        end
    end
end

function connection()

    while true do
        wait(500)
		if not fam_check then
        if not WSstatus then
            if wsConnected and not wsOperationBusy then
                closeWs()
            end
        elseif not wsConnected then
            if reconnectRequested then
                wsLog("WS RECONNECT")
                if not wsOperationBusy then
                    closeWs()
                end
                reconnectRequested = false
            end

            if not wsOperationBusy then
                if not connectWs() then
                    wait(1500)
                end
            end
        end
	end
    end
end
--------------------------------------------------------------------------------
----------------------------EVENT THREAD POOL----------------------------------
--------------------------------------------------------------------------------
-- SA-MP events are dispatched from C++ code. Creating a new MoonLoader
-- coroutine directly from an event callback can throw a C++ exception when
-- many callbacks arrive in a short period. Keep a small fixed pool instead.
local EVENT_THREAD_WORKERS = 4
local EVENT_QUEUE_LIMIT = 32
local eventThreadQueue = {}
local eventThreadQueueHead = 1
local eventThreadQueueTail = 0
local eventThreadQueueDropped = 0

local function eventThreadCreate(fn)
    if type(fn) ~= 'function' then return false end

    local queued = eventThreadQueueTail - eventThreadQueueHead + 1
    if queued >= EVENT_QUEUE_LIMIT then
        eventThreadQueueDropped = eventThreadQueueDropped + 1
        return false
    end

    eventThreadQueueTail = eventThreadQueueTail + 1
    eventThreadQueue[eventThreadQueueTail] = fn
    return true
end

local function eventThreadWorker(workerId)
    while true do
        local fn = eventThreadQueue[eventThreadQueueHead]
        if fn then
            eventThreadQueue[eventThreadQueueHead] = nil
            eventThreadQueueHead = eventThreadQueueHead + 1

            local ok, err = xpcall(fn, debug.traceback)
            if not ok then
                print(string.format('[PTE] Event worker #%d error: %s', workerId, tostring(err)))
            end

            -- Periodically compact the queue indices so they do not grow forever.
            if eventThreadQueueHead > 256 and eventThreadQueueHead > eventThreadQueueTail then
                eventThreadQueue = {}
                eventThreadQueueHead = 1
                eventThreadQueueTail = 0
            end
        else
            wait(0)
        end
    end
end

--------------------------------------------------------------------------------
--------------------------------------MAIN--------------------------------------
--------------------------------------------------------------------------------
--#mAIN
local keepAliveCallbacks = {}
local OrigGetWheelStatus = nil

-- SAFETY: native hooks can hard-crash GTA:SA when the executable/layout is not exact.
-- Disabled by default. Set to true only on a known-compatible GTA:SA build.
local ENABLE_UNSAFE_NATIVE_HOOKS = false
local nativeHooksInstalled = false
local nativeHookOriginalBytes = {}
if not LPH_OBFUSCATED then
    LPH_NO_VIRTUALIZE = function(...) return ... end
end
 time_wl = 0
 time_open = 0
 local one_nickname = nil
parking_time = 0
gl_w_combo_list = { "Impact", "Arial", "Segoe UI", "Montserrat"}

var_0_172 = "https://docs.google.com/spreadsheets/d/e/2PACX-1vTwdQODoGy2OM6CMEzZZpbzJRSdRjjkMHoBCvMdqq1ZmLqiuZtF0TVo1DzFT-5sQks6zXmu9VTX25ob/pub?output=csv"
var_0_173 = {}
var_0_174 = false
var_0_175 = false


function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(0) end
    -- Fixed worker pool: event callbacks only enqueue work, they never call
    -- lua_thread.create() directly.
    for i = 1, EVENT_THREAD_WORKERS do
        lua_thread.create(eventThreadWorker, i)
    end
    repeat wait(0) until sampGetCurrentServerName() ~= "SA-MP"
	if not sampGetCurrentServerName():find("Evolve%-Rp.Ru") then
		 thisScript():unload()
	end
    repeat wait(0) until sampGetCurrentServerName():find("Evolve%-Rp.Ru")

    one_nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    local nick = mynick()

    -- Первый ник создается из базового Default.
    -- Все последующие новые ники создаются из выбранного главного ника.
    if ensureProfile(nick) then
        -- Профиль уже сохранен; никакого сброса config и повторной инициализации нет.
    end

    if config.data["Default_nickname"] == nil then
        config.data["Default_nickname"] = deepCopy(config.default["Default_nickname"])
    end
    if config.data["Default_nickname"].settings == nil then
        config.data["Default_nickname"].settings = {}
    end
    if config.data["Default_nickname"].settings.nickname == nil
        or config.data["Default_nickname"].settings.nickname == "" then
        config.data["Default_nickname"].settings.nickname = nick
        config_save(config.data)
    end

color_filter = {
    [4280979824] = config.data[mynick()].pr.rifa,  
    [2852167424] = config.data[mynick()].pr.grove, 
    [3355573503] = config.data[mynick()].pr.aztec, 
    [4294958628] = config.data[mynick()].pr.vagos,
    [4289926119] = config.data[mynick()].pr.ballac,  
    [4290033079] = config.data[mynick()].pr.rm,   
    [4292716289] = config.data[mynick()].pr.lcn,   
    [2868838400] = config.data[mynick()].pr.yakudza,   
    [4281545523] = config.data[mynick()].pr.mongols,   
    [4281110935] = config.data[mynick()].pr.pagans,   
    [4294201344] = config.data[mynick()].pr.warlocks,  
	[16777215] = config.data[mynick()].pr.bich 
}
aztec2 = imgui.new.bool(config.data[mynick()].pr.aztec)
ballac2 = imgui.new.bool(config.data[mynick()].pr.ballac)
grove2 = imgui.new.bool(config.data[mynick()].pr.grove)
rifa2 = imgui.new.bool(config.data[mynick()].pr.rifa)
vagos2 = imgui.new.bool(config.data[mynick()].pr.vagos)
lcn2 = imgui.new.bool(config.data[mynick()].pr.lcn)
yakudza2 = imgui.new.bool(config.data[mynick()].pr.yakudza)
rm2 = imgui.new.bool(config.data[mynick()].pr.rm)
mongols2 = imgui.new.bool(config.data[mynick()].pr.mongols)
pagans2 = imgui.new.bool(config.data[mynick()].pr.pagans) 
warlocks2 = imgui.new.bool(config.data[mynick()].pr.warlocks)
bich2 = imgui.new.bool(config.data[mynick()].pr.bich)
pr_status = imgui.new.bool(config.data[mynick()].pr.status)
marker_status = imgui.new.bool(config.data[mynick()].marker.status)
pr_marker = imgui.new.bool(config.data[mynick()].pr.marker)
pr_family = imgui.new.bool(config.data[mynick()].pr.family)
bikerlist_status = imgui.new.bool(config.data[mynick()].bikerlist.status)
bikerlist_cmd = imgui.new.char[256](config.data[mynick()].bikerlist.command)
perevorot_status = imgui.new.bool(config.data[mynick()].perevorot.status)
perevorot_speed = new.int(config.data[mynick()].perevorot.speed)
SbivStatus = imgui.new.bool(config.data[mynick()].small_tweaks.sbiv_status)
notif_status = imgui.new.bool(config.data[mynick()].small_tweaks.notifications)
pmask = imgui.new.bool(config.data[mynick()].small_tweaks.pmask)
Eblo_Status = imgui.new.bool(config.data[mynick()].eblochecker.status)
 EbloGangStatus = imgui.new.bool(config.data[mynick()].eblochecker.gang_status)
 EbloMafiaStatus = imgui.new.bool(config.data[mynick()].eblochecker.maf_status)
 EbloBikersStatus = imgui.new.bool(config.data[mynick()].eblochecker.biker_status)
 EbloGangStream = imgui.new.bool(config.data[mynick()].eblochecker.gang_stream)
 EbloMafiaStream = imgui.new.bool(config.data[mynick()].eblochecker.maf_stream)
 EbloBikersStream = imgui.new.bool(config.data[mynick()].eblochecker.biker_stream)
famccheckbool = imgui.new.bool(config.data[mynick()].eblochecker.fam_status)
famccheckbool2 = imgui.new.bool(config.data[mynick()].eblochecker.statuses)
famccheckbool3 = imgui.new.bool(config.data[mynick()].eblochecker.families)
gd_status = imgui.new.bool(config.data[mynick()].good_drive.status)
dlcar_status = imgui.new.bool(config.data[mynick()].dlcar.status)
getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
dlcar_dist = imgui.new.int(config.data[mynick()].dlcar.dist)
drift_status = imgui.new.bool(config.data[mynick()].small_tweaks.driftmod_status)
drift_speed = imgui.new.float(config.data[mynick()].small_tweaks.driftmod_speed)
autoreport_status = imgui.new.bool(config.data[mynick()].autoreport.status)
autoreport_capt_status = imgui.new.bool(config.data[mynick()].autoreport.capture)
id_killlist = imgui.new.bool(config.data[mynick()].id_killlist.status)
gd_activated = ffi.new("int[1]", 0)
gd_activated[0] = config.data[mynick()].good_drive.status and 1 or 0
v_kv_mafia = imgui.new.bool(config.data[mynick()].mafialines.kv_render)
v_kv_biker = imgui.new.bool(config.data[mynick()].bikerlines.kv_render)
	b_lines_status = imgui.new.bool(config.data[mynick()].bikerlines.activated)
	--[[botovod.ckyl = imgui.new.bool(config.data[mynick()].autoschool.status)
	botovod.remove = imgui.new.bool(config.data[mynick()].autoschool.playeer_remove)
    botovod.ASC = imgui.new.char[256](u8(config.data[mynick()].AutoSkill.Command))
   botovod.LC = imgui.new.char[256](u8(config.data[mynick()].AutoLomka.Command))
   botovod.FCALL = imgui.new.char[256](u8(config.data[mynick()].FullCycle.Command))]]
   webglonass = imgui.new.bool(config.data[mynick()].glonass.status)
   NoInteriorFreeze = imgui.new.bool(config.data[mynick()].NoInteriorFreeze.status)
   hidechar = imgui.new.bool(config.data[mynick()].hidechar.status)
   achecker = imgui.new.bool(config.data[mynick()].adminchecker.status)
map_size = imgui.new.int(config.data[mynick()].glonass.size)
people_size = imgui.new.int(config.data[mynick()].glonass.people_size)
matavoz_size = imgui.new.int(config.data[mynick()].glonass.matavoz_size)
nick_size = imgui.new.int(config.data[mynick()].glonass.nick)
hp_size = imgui.new.int(config.data[mynick()].glonass.hp)
marker_size = imgui.new.int(config.data[mynick()].glonass.marker_size)
gl_combo_int = imgui.new.int(config.data[mynick()].glonass.tip)
gl_combo_list = { "Тёмная тема", "Стандартная улучшенная", "Красная с квадратами", "Серая с квадратами"}
gl_combo_items = imgui.new['const char*'][#gl_combo_list](gl_combo_list)

markker_combo_int = imgui.new.int(config.data[mynick()].glonass.marker)
markker_combo_list ={ "Первая", "Вторая"}
markker_combo_items = imgui.new['const char*'][#markker_combo_list](markker_combo_list)

gl_w_combo_int = imgui.new.int(config.data[mynick()].glonass.font)
gl_w_combo_items = imgui.new['const char*'][#gl_w_combo_list](gl_w_combo_list)
AutoCapterWait = imgui.new.int(config.data[mynick()].AutoCapt.wait)
 AutoCapterBiz = imgui.new.char[4](u8(config.data[mynick()].AutoCapt.biz))
 AutoCaptStatus = imgui.new.bool(config.data[mynick()].AutoCapt.status)
 FlooderStatus = imgui.new.bool(config.data[mynick()].AutoCapt.flooder_status)
autodrugStatus = imgui.new.bool(config.data[mynick()].AutoCapt.autodrug)
 AutoCapterCom = imgui.new.char[256](u8(config.data[mynick()].AutoCapt.com)) 
 TruckCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].small_tweaks.truck_command)))
withdrawCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].bank.withdraw)))
transferCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].bank.transfer)))
depositCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].bank.deposit)))
bcaptCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].AutoCapt.bautocapt)))
mcaptCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].AutoCapt.mautocapt)))
antiafkCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].small_tweaks.antiafk_cmd)))
gdCom = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].good_drive.cmd)))
 FlooderCommand = imgui.new.char[256](u8(("/%s"):format(config.data[mynick()].AutoCapt.flooder_com))) 
 nark_lines_one = imgui.new.char[256](u8(config.data[mynick()].lines.one))
 nark_lines_two = imgui.new.char[256](u8(config.data[mynick()].lines.two))
 nark_font_font = imgui.new.char[256](u8(config.data[mynick()].render.font))
 nark_font_size = imgui.new.char[256](u8(config.data[mynick()].render.size))
 nark_font_flag = imgui.new.char[256](u8(config.data[mynick()].render.flag))
 nark_height = imgui.new.int(config.data[mynick()].render.height)

 request_wlpale = imgui.new.bool(config.data[mynick()].LeaderManagement.warehouse_request)
 autogetguns_status = imgui.new.bool(config.data[mynick()].autogetguns.status)
 status_drug_timer = imgui.new.bool(config.data[mynick()].drugtimer.status)
 death_drug_timer = imgui.new.bool(config.data[mynick()].drugtimer.death)
 nark_max_gramm = imgui.new.int(config.data[mynick()].drugtimer.max_use_gram)
 nark_max_hp = imgui.new.int(config.data[mynick()].drugtimer.hp)

 fence_len = imgui.new.int(config.data[mynick()].remove_fence.dist_onfoot)
 fence_car_len = imgui.new.int(config.data[mynick()].remove_fence.dist_car)
flashlight_status = imgui.new.bool(config.data[mynick()].flashlight.status)
flashlight_len = imgui.new.int(config.data[mynick()].flashlight.dist)
 status_collision = imgui.new.bool(config.data[mynick()].small_tweaks.collision)
 status_clickwarp = imgui.new.bool(config.data[mynick()].clickwarp.status)
status_collision_all = imgui.new.bool(config.data[mynick()].small_tweaks.collision_all)
 status_truck = imgui.new.bool(config.data[mynick()].small_tweaks.truck)
 status_bank = imgui.new.bool(config.data[mynick()].small_tweaks.bank)
  status_autoheal = imgui.new.bool(config.data[mynick()].small_tweaks.autoheal)
 status_open_car = imgui.new.bool(config.data[mynick()].small_tweaks.car)
 status_takegun = imgui.new.bool(config.data[mynick()].small_tweaks.takegun)
 status_smuggler = imgui.new.bool(config.data[mynick()].small_tweaks.smuggler)
 status_spawncar = imgui.new.bool(config.data[mynick()].small_tweaks.spawncar)
status_autoinv = imgui.new.bool(config.data[mynick()].small_tweaks.autoinv)
status_otkat = imgui.new.bool(config.data[mynick()].small_tweaks.otkat)
status_exit = imgui.new.bool(config.data[mynick()].small_tweaks.exit)
status_autogiverank = imgui.new.bool(config.data[mynick()].small_tweaks.autogiverank)
status_pautogiverank = imgui.new.bool(config.data[mynick()].small_tweaks.pautogiverank or false)
status_antiafk = imgui.new.bool(config.data[mynick()].small_tweaks.antiafk)
 status_sm = imgui.new.bool(config.data[mynick()].squad.status)
 status_smu = imgui.new.bool(config.data[mynick()].users.status)
 status_melee2 = imgui.new.bool(config.data[mynick()].delete_melee_weapon.status)
 status_melee = {
	["kiy"] = imgui.new.bool(config.data[mynick()].delete_melee_weapon.kiy),
	["stick"] = imgui.new.bool(config.data[mynick()].delete_melee_weapon.stick),
	["knuckles"] = imgui.new.bool(config.data[mynick()].delete_melee_weapon.knuckles),
	["bat"] = imgui.new.bool(config.data[mynick()].delete_melee_weapon.bat),
	["katana"] = imgui.new.bool(config.data[mynick()].delete_melee_weapon.katana),
 }
 status_players = imgui.new.bool(config.data[mynick()].squad.players)
 status_squad_online = imgui.new.bool(config.data[mynick()].squad.online_status)
ReplacingWindowWithNickName_status = imgui.new.bool(config.data[mynick()].ReplacingWindowWithNickName.status)
 status_users_online = imgui.new.bool(config.data[mynick()].users.online_status)
 sfont_sfont = imgui.new.char[256](u8(config.data[mynick()].squad.font))
 sfont_ssize = imgui.new.char[256](u8(config.data[mynick()].squad.size))
 sfont_flag  = imgui.new.char[256](u8(config.data[mynick()].squad.flag))
 usfont_sfont = imgui.new.char[256](u8(config.data[mynick()].users.font))
 usfont_ssize = imgui.new.char[256](u8(config.data[mynick()].users.size))
 usfont_flag  = imgui.new.char[256](u8(config.data[mynick()].users.flag))
 usfont_line  = imgui.new.char[256](u8(config.data[mynick()].users.line))
 ucwapka_font = imgui.new.char[256](config.data[mynick()].users.wapka2) 
 autoheal_for_mafia = imgui.new.bool(config.data[mynick()].getguns.autoheal)

fence_status = imgui.new.bool(config.data[mynick()].remove_fence.status)
object_all_status = imgui.new.bool((config.data[mynick()].remove_fence.status and config.data[mynick()].flashlight.status))
 status_fcar_fx = imgui.new.bool(config.data[mynick()].fastcarfx.status)
 status_fcarexit_fx = imgui.new.bool(config.data[mynick()].fastcarfx.status_exit)


getguns_status = imgui.new.bool(config.data[mynick()].getguns.status) 
render_gun_bool = imgui.new.bool(config.data[mynick()].render_gun.render) 
getguns.ak = imgui.new.char[256](tostring(config.data[mynick()].getguns.ak))
getguns.m4 = imgui.new.char[256](tostring(config.data[mynick()].getguns.m4))
getguns.deagle = imgui.new.char[256](tostring(config.data[mynick()].getguns.deagle))
getguns.rifle = imgui.new.char[256](tostring(config.data[mynick()].getguns.rifle))
getguns.shotgun = imgui.new.char[256](tostring(config.data[mynick()].getguns.shotgun))
getguns.drink = imgui.new.bool(config.data[mynick()].getguns.auto_get_drink)
getguns.drugs = imgui.new.bool(config.data[mynick()].getguns.auto_get_drugs)

 ld_font = imgui.new.char[256](u8(config.data[mynick()].render_gun.font))
 ldfont_size = imgui.new.char[256](u8(config.data[mynick()].render_gun.size))
 ldfont_flag = imgui.new.char[256](u8(config.data[mynick()].render_gun.flag))

camhack_status = imgui.new.bool(config.data[mynick()].camhack.status)
 statusfsafe = imgui.new.bool(config.data[mynick()].fsafe.status)
 statusfsafeforDNK = imgui.new.bool(config.data[mynick()].fsafe.dnk_status)
hideweapon_status = imgui.new.bool(config.data[mynick()].hideweapon.status)
fsafe.pin = imgui.new.char[256](tostring(config.data[mynick()].fsafe.pin)) 
fsafe.ak = imgui.new.char[256](tostring(config.data[mynick()].fsafe.ak))
fsafe.m4 = imgui.new.char[256](tostring(config.data[mynick()].fsafe.m4))
fsafe.deagle = imgui.new.char[256](tostring(config.data[mynick()].fsafe.deagle))
fsafe.rifle = imgui.new.char[256](tostring(config.data[mynick()].fsafe.rifle))
fsafe.shotgun = imgui.new.char[256](tostring(config.data[mynick()].fsafe.shotgun))
fsafe.wait = imgui.new.char[256](tostring(config.data[mynick()].fsafe.wait))
fsafe.dnk_pin = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_pin)) 
fsafe.dnk_ak = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_ak))
fsafe.dnk_m4 = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_m4))
fsafe.dnk_deagle = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_deagle))
fsafe.dnk_rifle = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_rifle))
fsafe.dnk_shotgun = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_shotgun))
fsafe.dnk_wait = imgui.new.char[256](tostring(config.data[mynick()].fsafe.dnk_wait))
	b_radar_lines = imgui.new.bool(config.data[mynick()].bikerlines.radarRender)
font = renderCreateFont(config.data[mynick()].render.font, config.data[mynick()].render.size, config.data[mynick()].render.flag)
squad_font = renderCreateFont(config.data[mynick()].squad.font, config.data[mynick()].squad.size, config.data[mynick()].squad.flag)
fffont =  renderCreateFont("Arial", 12, 13)
fonts = renderCreateFont("Arial", 9, 4)
font_for_notification = renderCreateFont(config.data[mynick()].render_gun.font, config.data[mynick()].render_gun.size, config.data[mynick()].render_gun.flag)
users_font = renderCreateFont(config.data[mynick()].users.font, config.data[mynick()].users.size, config.data[mynick()].users.flag)
 armor_status = imgui.new.bool(config.data[mynick()].getguns.armor)
 drug_status = imgui.new.bool(config.data[mynick()].fsafe.drugs_status)
 dnkdrug_status = imgui.new.bool(config.data[mynick()].fsafe.dnkdrugs_status)
 int_squad = new.int(config.data[mynick()].squad.int)
 combosquad = {"Белый", "Синий", "Цвет клиста", "Свой цвет"}
 combo_squad = imgui.new['const char*'][#combosquad](combosquad)

 int_uc = new.int(config.data[mynick()].users.int)
 combouc = {"Белый", "Синий", "Цвет клиста", "Свой цвет"}
 combo_uc = imgui.new['const char*'][#combosquad](combosquad)

 int_squad2 = new.int(config.data[mynick()].squad.rank)
 combosquad2 = {"Показывать всех игроков", "Показывать игроков с 2 ранга", "Показывать игроков с 3 ранга", "Показывать игроков с 4 ранга"}
 combo_squad2 = imgui.new['const char*'][#combosquad2](combosquad2)

 int_sbiv = new.int(config.data[mynick()].small_tweaks.sbiv_int)
 combosbiv = {"Писс", "Танец"}
 combo_sbiv = imgui.new['const char*'][#combosbiv](combosbiv)

 int_namesq = new.int(config.data[mynick()].squad.name_squad)
 squadcombo = {"", "SQUAD", "PALERIDERS", "PALENATION", "СКВАД", "БЛЕДНАЯ НАЦИЯ", "БЛЕДНАЯ БРАТВА", "ПАЛЕПИДОРЫ", "ЖОПОНЮХИ", "PALESPREAD", "ГЛИНОМЕСЫ"}
 squad_combo = imgui.new['const char*'][#squadcombo](squadcombo)

 int_cq = new.int(config.data[mynick()].squad.intfont)
 combocq = {"Arial", "Times New Roman", "Tahoma", "Свой шрифт"}
 combo_cq = imgui.new['const char*'][#combocq](combocq)

 int_gun = new.int(config.data[mynick()].render_gun.int)
 combogun = {"Arial", "Times New Roman", "Tahoma", "Свой шрифт"}
 combo_gun = imgui.new['const char*'][#combogun](combogun)
 if config.data["Default_nickname"].settings.nickname == "" then
config.data["Default_nickname"].settings.nickname = mynick()
config_save(config.data)
 end
 int_settings = new.int(config_nickname_int())
 combosettings = config_nickname()
 combo_settings = imgui.new['const char*'][#combosettings](combosettings)

 int_settings2 = new.int(config_nickname_int())
 combosettings2 = config_nickname()
 combo_settings2 = imgui.new['const char*'][#combosettings2](combosettings2)
 refreshSettingsProfileCombos(true)

 int_narkow = new.int(config.data[mynick()].drugtimer.int)
 combonarkow = {"Arial", "Times New Roman", "Tahoma", "Свой шрифт"}
 combo_narkow = imgui.new['const char*'][#combonarkow](combonarkow)

 if config.data[mynick()].glonass.marker == 1 then
    markerTexturePath = MAP_DIRECTORY .. "marker2.png"
end
 statuses = {
    render = imgui.new.bool(),
    pos = {is_changing =imgui.new.bool(), x = config.data[mynick()].statuses.x, y = config.data[mynick()].statuses.y},
    text = "",
    new = function(self)
        self.text = ""
        self.list = {
            ["{ae433d}E{FFFFFF}"] = {name = "Launcher", count = 0},
            ["{ae433d}M{FFFFFF}"] = {name = "Mobile", count = 0},
            ["{ae433d}Y{FFFFFF}"] = {name = "Youtuber", count = 0},
            ["»"] = {name = "SA-MP", count = 0},
        }
    end,
    process = function(self)
        for _, v in pairs(self.list) do
            if v.count ~= 0 then
                if self.text:len() ~= 0 then
                    self.text = self.text .. " | "
                end
                self.text = self.text .. "{e6fcfc}" .. v.name .. "[{fa5555}" .. v.count .. "{e6fcfc}]"
            end
        end
    end
}
 families = {
    render = imgui.new.bool(),
    pos = {is_changing = imgui.new.bool(), x = config.data[mynick()].families.x, y = config.data[mynick()].families.y},
    text = "",
    new = function(self)
        self.text = ""
        self.list = {}
    end,
    process = function(self)
        self.list = sort_by_count(self.list)
        local entities = 0
        for _, v in ipairs(self.list) do
            entities = entities + 1
            if entities == 2 then
                self.text = self.text .. " | "
            end

            self.text = self.text .. "{fcf158}" .. v.name .. "[{ffbb5c}" .. v.count .. "{f2ebbb}]"
			--msg(v.name)
            if entities == 2 then
                self.text = self.text .. "\n"
                entities = 0
            end
        end
    end
}
statuses.render[0] = true
families.render[0] = true
	-- Исправление: сохраняем колбэки в таблицу перед установкой

    if ENABLE_UNSAFE_NATIVE_HOOKS and not nativeHooksInstalled then
        local hookType = 'unsigned int(__thiscall *)(void *, int)'
        local ok, err = pcall(function()
            OrigGetWheelStatus = ffi.cast(hookType, 0x6C21B0)
            keepAliveCallbacks[1] = ffi.cast(hookType, GetWheelStatus)

            hook1 = installCallHook(hookType, 0x6A55FE, keepAliveCallbacks[1])
            hook2 = installCallHook(hookType, 0x6A5ACC, keepAliveCallbacks[1])
            nativeHooksInstalled = true
        end)

        if not ok then
            nativeHooksInstalled = false
            hook1, hook2 = nil, nil
            OrigGetWheelStatus = nil
            if keepAliveCallbacks[1] then
                pcall(function() keepAliveCallbacks[1]:free() end)
                keepAliveCallbacks[1] = nil
            end
            print('[PTE] Native hooks disabled: ' .. tostring(err))
        end
    end
    
	-- Default больше не перезаписываем настройками выбранного ника.
	-- Выбранный ник используется как шаблон только при создании нового профиля.

	

	memory.fill(sampGetBase() + 0x7418, 0x90, 6, true) -- Включает hud при sampSetSpecialAction.
    set_areas_by_server("Saint-Louis")
    local result, PlayerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	my_name = sampGetPlayerNickname(PlayerId)
    local ip, port = sampGetCurrentServerAddress()
    drugtimer = string.format('%s %s-%s', my_name, ip:gsub('%.', '-'), port)
	myNick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    serverIP = sampGetCurrentServerAddress()
    isInitialized = true
	sampUnregisterChatCommand('q')
	sampRegisterChatCommand(config.data[mynick()].clickwarp.cmd, function() 
		
		config.data[mynick()].clickwarp.status = not config.data[mynick()].clickwarp.status
		msg(config.data[mynick()].clickwarp.status and "Модуль активирован" or "Модуль деактивирован")
		status_clickwarp[0] = not status_clickwarp[0]
		config_save(config.data)
	end)
	--sampRegisterChatCommand('echeck', function() window_enabled[0] = not window_enabled[0] end)
    sampRegisterChatCommand('q', function() 
		lua_thread.create(function()
			sampSendChat("/fc Р±Р± Р°Р»Р»")
	        wait(25)
	        callFunction(sampGetBase() + 0x64D70, 0, 0)
		end)
    end)
	 border_tab = imgui.new.int(1)
     b_border_tab = imgui.new.int(0)
    flooder_and_capture_tab = imgui.new.int(0)
	-- sampRegisterChatCommand('mmq', function() msg(getCharModel(PLAYER_PED)) end)
	--sampRegisterChatCommand("zzz", function(arg)  sampAddChatMessage("{"..arg.."} Маленькие люди:", -1) end)

    local fullOldPath = getWorkingDirectory() .. "/config/Palenation Tool Extended.ini" 

    sampRegisterChatCommand("ptereload", function()  thisScript():reload() end)  
	sampRegisterChatCommand("mlines", function()  Menu[0] = not Menu[0] page = 67 border_tab[0] = 0 end)
	sampRegisterChatCommand("blines", function()  Menu[0] = not Menu[0] page = 67 border_tab[0] = 1 end)
    sampRegisterChatCommand("pte", function() if check_resource2() then  Menu[0] = not Menu[0]  end end)
	if config.data[mynick()].marker.status or config.data[mynick()].glonass.status then
	    WSstatus = true
	end
	if WSstatus then reconnectRequested = true end
   -- sampRegisterChatCommand("markerws", markerWsCommand)
    sampRegisterChatCommand("markerlist", markerListCommand)
	--sampRegisterChatCommand("pe", function(arg) sampAddChatMessage(sampGetPlayerColor(arg) .. " " .. ('%06X'):format(bit.band(sampGetPlayerColor(arg), 0xFFFFFF)), -1) end)
	sampRegisterChatCommand("cho", function() sampAddChatMessage(cho_gang, -1) sampAddChatMessage(cho_biker, -1)  sampAddChatMessage(cho_maf, -1) end)

	load_all = true
	repeat wait(0) until sampIsLocalPlayerSpawned()
	
		if doesFileExist(fullOldPath) then
		msg("В недавнем обновлении был изменен формат настроек.")
		msg("Для переноса настроек введите команду /pconfig")
		sampRegisterChatCommand("pconfig", function()

local os = require 'os'
local oldIniFileName = "Palenation Tool Extended.ini"
local fullOldPath = getWorkingDirectory() .. "/config/" .. oldIniFileName

-- Функция конвертации строки вида "[88]" или "[]" в таблицу {88} или {}
local function parseKey(value)
    if type(value) == "string" then
        local id = value:match("%[(%d+)%]")
        if id then
            return { tonumber(id) } -- Возвращает таблицу {88}
        elseif value == "[]" then
            return {} -- Возвращает пустую таблицу {}
        end
    end
    return value
end

-- Функция копирования с авто-конвертацией клавиш
local function copyTable(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            copyTable(target[k], v)
        else
            -- Если имя переменной содержит "key" (например, sbiv_key, key, dnk_key)
            if type(k) == "string" and k:lower():find("key") then
                target[k] = parseKey(v)
            else
                target[k] = v
            end
        end
    end
end

-- Если старый .ini найден в папке config
if doesFileExist(fullOldPath) then
    -- Загружаем старый ini (используя структуру 'ini' с дефолтами из первого вопроса)
    local oldData = inicfg.load(ini, oldIniFileName)
    
    if oldData then
        -- Напрямую получаем ссылку на массив настроек текущего никнейма
        local targetConfig = config.data[config.data["Default_nickname"].settings.nickname]
        
        -- Копируем все данные из ini файла прямо туда с конвертацией клавиш
        copyTable(targetConfig, oldData)
        
        -- Сохраняем настройки вашей функцией
        config_save(config.data)
        
        -- Удаляем старый .ini файл, чтобы перенос не повторялся
        os.remove(fullOldPath)
        msg("Настройки успешно перенесены в новый формат")
        msg("Выполняю перезагрузку скрипта...")
		thisScript():reload()
    end
end

		end)
	end
	all_load = true
	initializeRender()
	local check_servers = check_server()

	check_folder("config")
	check_key()
	--xxxxxxxxxxxx
	if status_hotkey then
		glonass_hotkey = hotkey.RegisterHotKey('gloo Hotkey', false, config.data[mynick()].glonass.key, function() end)
		marker_hotkey = hotkey.RegisterHotKey('marker Hotkey', false, config.data[mynick()].marker.key, function() end)
		camhack_hotkey = hotkey.RegisterHotKey('camhack Hotkey', false, config.data[mynick()].camhack.key, function() end)
		bikerlist_hotkey = hotkey.RegisterHotKey('bikerlist Hotkey', false, config.data[mynick()].bikerlist.key, function() end)
		DrugHotKey = hotkey.RegisterHotKey('Drug Hotkey', false, config.data[mynick()].drugtimer.key, function() end)
		DriftHotKey = hotkey.RegisterHotKey('Drift Hotkey', false, config.data[mynick()].small_tweaks.driftmod_key, function() end)
		FastCarFXHotKey = hotkey.RegisterHotKey('FastCars Hotkey', false, config.data[mynick()].fastcarfx.key, function() end)
		--AutoCapterHotKey = hotkey.RegisterHotKey('AutoCapt Hotkey', false, config.data[mynick()].AutoCapt.key, function() end)
		fsafeoneHotKey = hotkey.RegisterHotKey('Fsafe Hotkey', false, config.data[mynick()].fsafe.key, function() end)
		--DNKHotKey = hotkey.RegisterHotKey('DNK Hotkey', false, config.data[mynick()].fsafe.dnk_key, function() end)
		GetgunsHotKey = hotkey.RegisterHotKey('Getguns Hotkey', false, config.data[mynick()].getguns.key, function() end)
		SbivHotKey = hotkey.RegisterHotKey('Sbiv Hotkey', false, config.data[mynick()].small_tweaks.sbiv_key, function() end)
		perevorot_one_hotkey = hotkey.RegisterHotKey('perevorot_one Hotkey', false, config.data[mynick()].perevorot.key_one, function() end)
       perevorot_two_hotkey = hotkey.RegisterHotKey('perevorot_two Hotkey', false, config.data[mynick()].perevorot.key_two, function() end)
	end
    webfont = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], 12, 4)
    fontSmall = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick + 2, 4)
    fontPlayer = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick, 4)
    fontHp = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.hp, 4)
    gg_evolve.getgun_list = {}
    gg_evolve.open = false
    gg_evolve.getgun = false
    gg_evolve.drugs_ignore = 0
    gg_evolve.getgun_st = 0
    gg_evolve.tdstart = 0
    
    update("https://raw.githubusercontent.com/Mafizik/Palenation-Tool-Extended/refs/heads/main/settings.json")
	check_resource()

	kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())

	capture_cmd_register()
	truck_cmd_register()
	antiafk_cmd_register()
	gd_cmd_register()
    withdraw_cmd_register()
	deposit_cmd_register()
	pmask_register()
	transfer_cmd_register()
	flooder_cmd_register()
	bcapture_cmd_register()
	mcapture_cmd_register()
	ReplacingWindowWithNickName()
	loadMapTextures()
	--Full_Cycle_Register_Command()
    --AutoSkill_Register_Command()
    --AutoLomka_Register_Command()
	bikerlist_register()
    load_ini() 
	bload_ini()
	--cheking_users("https://raw.githubusercontent.com/Mafizik/scripts/refs/heads/main/Useful%20Scripts%20by%20Mafizik.json")
	sendJoinNotification()
	 updateOnlinePlayers()
	checkCapture()
    AdminsErp()
	--check_users = true



	lua_thread.create(check_profile)
	lua_thread.create(obxod2f)
	lua_thread.create(FamCheckFunc)
	lua_thread.create(EbloCheckFunc) 
	lua_thread.create(AutoGetGunsFunc)
	lua_thread.create(CollisionFunc)
	lua_thread.create(CollisionAllFunc)
	lua_thread.create(OpenCarFunc)
	lua_thread.create(antiafkFunc)
	lua_thread.create(ucFunc)	 
	--lua_thread.create(AutoCaptFuncTwo)	
	lua_thread.create(FastCarFunc)
	lua_thread.create(FsafeFunc) 
	lua_thread.create(TruckFunc) 
	lua_thread.create(TruckrFunc) 
	lua_thread.create(GetGunFunc)
	lua_thread.create(SbivFunc)
	lua_thread.create(SquadFuncOne)
	lua_thread.create(SquadFuncTwo)
	lua_thread.create(send_zaxod_one)
--	lua_thread.create(warelock_palenation)
	lua_thread.create(checkrankoff)
	lua_thread.create(GetMats)
	lua_thread.create(text_to_table) 
	lua_thread.create(drugstimer)
	lua_thread.create(One)
	lua_thread.create(Two)
    lua_thread.create(Four)
	lua_thread.create(Five)
	lua_thread.create(deletecueFunc)
    lua_thread.create(MafiaLinesFunc)
    lua_thread.create(dlcarFunc)
	lua_thread.create(famcheckerFunc)
	lua_thread.create(autodrugFunc)
	lua_thread.create(autohealFunc)
	lua_thread.create(perevorotFunc)
	lua_thread.create(famcheckrender)
	lua_thread.create(useraddFunc)
	lua_thread.create(driftFunc)
--	lua_thread.create(oneFunc)
 --   lua_thread.create(twoFunc)
	lua_thread.create(renderpatronFunc)
	--lua_thread.create(playeer_removeFunc)
	lua_thread.create(render_vkv3)
	lua_thread.create(render_vkv2)
	lua_thread.create(gzrenderFunc)
	lua_thread.create(bikerlistFunc)
	lua_thread.create(pr_marker_Func)
	lua_thread.create(proct_pr_func)
	lua_thread.create(autorep)
	lua_thread.create(unmackFunc)
    lua_thread.create(flashlightFunc)
	lua_thread.create(fenceFunc)
    lua_thread.create(hideweaponFunc)
    lua_thread.create(changeweaponFunc)
	lua_thread.create(camhackFunc)
	    lua_thread.create(click)
    lua_thread.create(receiveServer)
    lua_thread.create(connection)
	lua_thread.create(kostil_fsafe)
	lua_thread.create(hideFunc)
    while true do
        wait(0)
		if not fam_check then
        if WSstatus and wsConnected then
            sendPendingIdentify()
            sendPendingSync()
            sendPendingClientList()
            sendPendingMarker()
            sendOwnPosition()
        end

		            isActive =
                isKeysDown(config.data[mynick()].glonass.key)
                and not sampIsChatInputActive()
                and not isSampfuncsConsoleActive()
                and not sampIsDialogActive()
                and config.data[mynick()].glonass.status

        if isActive then
            mapActive = true
            enableMapCursor()

            -- ЛКМ = поставить метку, ПКМ = удалить метку у всех.
            if isKeyJustPressed(0x01) then
                placeMarkerFromMapClick("set")
            elseif isKeyJustPressed(0x02) then
                placeMarkerFromMapClick("remove")
            end
        else
            mapActive = false
            disableMapCursor()
        end
	end
    end
	
end
--endmainend


function var_0_176(arg_1_0)
	local var_1_0 = {}

	for iter_1_0 in arg_1_0:gmatch("[^\r\n]+") do
		local var_1_1, var_1_2 = iter_1_0:match("([a-zA-Z0-9]+_[a-zA-Z0-9]+)[^,;\t]*[,;\t][^%d]*(%d+)")

		if var_1_1 and var_1_2 then
			local var_1_3 = tonumber(var_1_2)

			if var_1_3 then
				table.insert(var_1_0, {
					name = var_1_1,
					level = var_1_3,
				})
			end
		end
	end

	return var_1_0
end

function LoadAdminList(arg_1_0, arg_1_1)
	if var_0_172 == "" then
		if not arg_1_1 then
			sampAddChatMessage("{FFFF00}Админ-чекер: {FFFFFF}не указана CSV-ссылка ADMIN_LIST_URL.", -1)
		end

		return
	end

	if var_0_175 then
		return
	end

	var_0_175 = true

	local var_1_0 = getWorkingDirectory() .. "\\config\\admins_temp.csv"

	downloadUrlToFile(var_0_172, var_1_0, function(arg_2_0, arg_2_1, arg_2_2, arg_2_3)
		if arg_2_1 == dlStatus.STATUS_ENDDOWNLOADDATA then
			local var_2_0 = io.open(var_1_0, "r")

			if var_2_0 then
				local var_2_1 = var_2_0:read("*a")

				var_2_0:close()
				os.remove(var_1_0)

				local var_2_2, var_2_3 = pcall(function()
					return var_0_176(var_2_1)
				end)

				if var_2_2 and type(var_2_3) == "table" then
					var_0_173 = {}

					for iter_2_0, iter_2_1 in ipairs(var_2_3) do
						local var_2_4 = tonumber(iter_2_1.level) or 0

						if var_2_4 <= 7 then
							table.insert(var_0_173, {
								name = tostring(iter_2_1.name),
								level = var_2_4,
							})
						end
					end

					var_0_174 = true
				end
			end

			var_0_175 = false

			if arg_1_0 then
				arg_1_0()
			end
		elseif arg_2_1 == dlStatus.STATUSEX_ENDDOWNLOADFAIL or arg_2_1 == dlStatus.STATUS_ENDDOWNLOADFAIL then
			var_0_175 = false

			if not arg_1_1 then
				sampAddChatMessage("{FFFF00}Админ-чекер: {FFFFFF}не удалось загрузить CSV-список.", -1)
			end
		end
	end)
end

function AdminsErp()
	LoadAdminList(nil, true)
end

function var_0_177()
	if #var_0_173 == 0 then
		sampAddChatMessage("{FFFF00}Админ-чекер: {FFFFFF}список администраторов пуст. Проверь CSV-ссылку.", -1)

		return
	end

	local var_1_0 = {}

	for iter_1_0 = 0, 999 do
		if sampIsPlayerConnected(iter_1_0) then
			local var_1_1 = sampGetPlayerNickname(iter_1_0)

			if var_1_1 then
				for iter_1_1, iter_1_2 in ipairs(var_0_173) do
					if iter_1_2.level <= 7 and string.lower(var_1_1) == string.lower(iter_1_2.name) then
						table.insert(var_1_0, {
							name = var_1_1,
							id = iter_1_0,
							level = iter_1_2.level,
						})

						break
					end
				end
			end
		end
	end

	table.sort(var_1_0, function(arg_2_0, arg_2_1)
		return arg_2_0.level > arg_2_1.level
	end)

	if #var_1_0 > 0 then
		sampAddChatMessage(" Админы Online:", 16776960)

		for iter_1_3, iter_1_4 in ipairs(var_1_0) do
			local var_1_2 = ""

			if iter_1_4.level == 6 then
				var_1_2 = " {3fff35}[ Зам.ГА ] "
			elseif iter_1_4.level == 7 then
				var_1_2 = " {3fff35}[ Гл.Адм ] "
			end

			sampAddChatMessage(" " .. iter_1_4.name .. " | ID: " .. iter_1_4.id .. " | Level: " .. iter_1_4.level .. var_1_2, 16113331)
		end
	else
		sampAddChatMessage(" Админы Online:", 16776960)
	end
end
function var_0_177_2()
	if #var_0_173 == 0 then
		sampAddChatMessage("{FFFF00}Админ-чекер: {FFFFFF}список администраторов пуст. Проверь CSV-ссылку.", -1)

		return
	end

	local var_1_0 = {}

	for iter_1_0 = 0, 999 do
		if sampIsPlayerConnected(iter_1_0) then
			local var_1_1 = sampGetPlayerNickname(iter_1_0)

			if var_1_1 then
				for iter_1_1, iter_1_2 in ipairs(var_0_173) do
					if iter_1_2.level <= 7 and string.lower(var_1_1) == string.lower(iter_1_2.name) then
						table.insert(var_1_0, {
							name = var_1_1,
							id = iter_1_0,
							level = iter_1_2.level,
						})

						break
					end
				end
			end
		end
	end

	table.sort(var_1_0, function(arg_2_0, arg_2_1)
		return arg_2_0.level > arg_2_1.level
	end)

	if #var_1_0 > 0 then
        return var_1_0
	else
		return "Админов нет в сети"
	end
end
function EvolveAdminsCommand()

	if not var_0_174 then
		LoadAdminList(function()
			if var_0_174 then
				var_0_177()
			end
		end)

		return
	end

	var_0_177()
end

function hideFunc()
    while true do
        wait(150) -- Проверка 10 раз в секунду
		if config.data[mynick()].hidechar.status then
        local chars = getAllChars()
        for _, pedHandle in pairs(chars) do
            if doesCharExist(pedHandle) and pedHandle ~= PLAYER_PED then
                
                local isDeadBody = false

                -- 1. ПРОВЕРКА НА АНИМАЦИЮ ТРУПА/ПАДЕНИЯ (как на твоем скриншоте)
                -- В GTA SA вся эта физика падений (лежание на асфальте) находится в библиотеке "PED"
                -- Проверяем основные анимации, в которых застывают трупы/стадии смерти:
                if isCharPlayingAnim(pedHandle, "FLOOR_hit_f") or 
                   isCharPlayingAnim(pedHandle, "FLOOR_hit_b") or 
                   isCharPlayingAnim(pedHandle, "KO_shot_face") or 
                   isCharPlayingAnim(pedHandle, "KO_shot_front") or 
                   isCharPlayingAnim(pedHandle, "BIKE_fallR") or 
                   isCharPlayingAnim(pedHandle, "BIKE_fall_off") or 
                   isCharPlayingAnim(pedHandle, "KD_left") or 
                   isCharPlayingAnim(pedHandle, "KD_right") then
                    
                    isDeadBody = true
                end

                -- 2. ПРОВЕРКА: ЕСЛИ ЭТО КАСТОМНЫЙ СОЗДАННЫЙ АКТЕР (NPC НЕ ИГРОК)
                -- У обычных SAMP-игроков всегда есть ID, у серверных актеров-ботов (продавцы, трупы как объекты) ID в SAMP нет
                local result, playerId = sampGetPlayerIdByCharHandle(pedHandle)
                if not result then
                    -- Если это актер, у которого нет ID игрока, и он не двигается (скорость 0)
                    local velocityX, velocityY, velocityZ = getCharVelocity(pedHandle)
                    local speed = math.sqrt(velocityX^2 + velocityY^2 + velocityZ^2)
                    if speed < 0.05 then
                        isDeadBody = true
                    end
                end

                -- 3. ОТКЛЮЧАЕМ КОЛЛИЗИЮ
                if isDeadBody then
                    -- Отключаем коллизию встроенным методом
                    setCharCollision(pedHandle, false)
                end

            end
        end
	end
    end
end
function checkCapture()
    -- Задаем ваши примерные координаты
    local targetX, targetY = 96.699, 257.299
    local epsilon = 5.0 -- Погрешность в пикселях (если не найдет, увеличьте до 15.0)

    -- Перебираем все текстдравы (в SAMPFUNCS этот диапазон покрывает и глобальные, и серверные ТД)
    for i = 0, 2304 do
        if sampTextdrawIsExists(i) then
            local x, y = sampTextdrawGetPos(i)
            
            -- Проверяем, подходят ли координаты по X и Y с учетом погрешности
            if math.abs(x - targetX) <= epsilon and math.abs(y - targetY) <= epsilon then
                local text = sampTextdrawGetString(i)
                
                -- Проверяем, есть ли в тексте двоеточие ":"
                if string.find(text, "DAMAGE", 1, true) then
					capture_status = true
                    return true
                end
            end
        end
    end

	capture_status = false
    return false
end


function kostil_fsafe()
	while true do wait(0)
	if sampIsDialogActive() and closed_dialog then
       sampCloseCurrentDialogWithButton(0)
	   closed_dialog = false
	end
	end
end

function camhack()
    imgui.ToggleButtonText("Camhack", camhack_status, function()
       config.data[mynick()].camhack.status = camhack_status[0]
       config_save(config.data)
    end)
    imgui.Text("Активация Camhack")
    if camhack_hotkey:ShowHotKey(imgui.ImVec2(390, 20)) then 
        config.data[mynick()].camhack.key = camhack_hotkey:GetHotKey()
        config_save(config.data)
    end
    imgui.Spacing()
    imgui.Spacing()
    if imgui.Button("Показывать текст над головой на любом расстоянии "..(config.data[mynick()].camhack.bubble and "[ON]" or "[OFF]").."##multi.menu_camhack", imgui.ImVec2(390,20)) then
        config.data[mynick()].camhack.bubble = not config.data[mynick()].camhack.bubble
        config_save(config.data)
    end
    if imgui.Button("Обходить варнинги "..(config.data[mynick()].camhack.antiwarning and "[ON]" or "[OFF]").."##multi.menu_camhack", imgui.ImVec2(390,20)) then
        config.data[mynick()].camhack.antiwarning = not config.data[mynick()].camhack.antiwarning
        config_save(config.data)
    end
    imgui.Spacing()
    imgui.Text("Описание:")
    imgui.TextColoredRGB("{FFFFFF}Представляет собой обыкновенный камхак, но с обходом \n{FFFFFF}варнингов. После активации вы сможете свободно управлять\n{FFFFFF}камерой через {00ccff}WASD{ffffff}.\n{FFFFFF}Камеру можно замедлять на {00ccff}-{ffffff} и ускорять на {00ccff}+{ffffff}\n{00ccff}F10{ffffff} включает/выключает худ.\n\n{FFFFFF}Если камера залагает, включите и выключите ещё раз.")
end

ch = {}
ch_flymode = 0
ch_speed = 1.0
ch_radarHud = 0
ch_keyPressed = 0
ch_posX, ch_posY, ch_posZ = 0, 0, 0
ch_angY, ch_angZ = 0, 0
ch_radZ, ch_radY = 0, 0
ch_sinZ, ch_cosZ = 0, 0
ch_sinY, ch_cosY = 0, 0
ch_poiX, ch_poiY, ch_poiZ = 0, 0, 0
ch_curZ, ch_curY, ch_angPlZ = 0, 0, 0
ch_posPlX, ch_posPlY, ch_posPlZ = 0, 0, 0

function camhackFunc()
    while true do wait(0)
        if isKeysPressed(config.data[mynick()].camhack.key) and config.data[mynick()].camhack.status and isKeyCanBePressed() then
            if ch_flymode == 0 then
                ch_hide_interface(false)
                ch_posX, ch_posY, ch_posZ = getCharCoordinates(playerPed)
                ch_angZ = getCharHeading(playerPed)
                ch_angZ = ch_angZ * -1.0
                setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                ch_angY = 0.0
                lockPlayerControl(true)
                ch_flymode = 1

                repeat
                    wait(0)
                until not isKeysDown(config.data[mynick()].camhack.key)
            end
        end
        
        if config.data[mynick()].camhack.status then
            if ch_flymode == 1 and not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
                offMouX, offMouY = getPcMouseMovement()
    
                offMouX = offMouX / 4.0
                offMouY = offMouY / 4.0
                ch_angZ = ch_angZ + offMouX
                ch_angY = ch_angY + offMouY
    
                if ch_angZ > 360.0 then
                    ch_angZ = ch_angZ - 360.0
                end
                if ch_angZ < 0.0 then
                    ch_angZ = ch_angZ + 360.0
                end
    
                if ch_angY > 89.0 then
                    ch_angY = 89.0
                end
                if ch_angY < -89.0 then
                    ch_angY = -89.0
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                ch_curZ = ch_angZ + 180.0
                ch_curY = ch_angY * -1.0
                ch_radZ = math.rad(ch_curZ)
                ch_radY = math.rad(ch_curY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 10.0
                ch_cosZ = ch_cosZ * 10.0
                ch_sinY = ch_sinY * 10.0
                ch_posPlX = ch_posX + ch_sinZ
                ch_posPlY = ch_posY + ch_cosZ
                ch_posPlZ = ch_posZ + ch_sinY
                ch_angPlZ = ch_angZ * -1.0
                --setCharHeading(playerPed, ch_angPlZ)
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_W) then
                    ch_radZ = math.rad(ch_angZ)
                    ch_radY = math.rad(ch_angY)
                    ch_sinZ = math.sin(ch_radZ)
                    ch_cosZ = math.cos(ch_radZ)
                    ch_sinY = math.sin(ch_radY)
                    ch_cosY = math.cos(ch_radY)
                    ch_sinZ = ch_sinZ * ch_cosY
                    ch_cosZ = ch_cosZ * ch_cosY
                    ch_sinZ = ch_sinZ * ch_speed
                    ch_cosZ = ch_cosZ * ch_speed
                    ch_sinY = ch_sinY * ch_speed
                    ch_posX = ch_posX + ch_sinZ
                    ch_posY = ch_posY + ch_cosZ
                    ch_posZ = ch_posZ + ch_sinY
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_S) then
                    ch_curZ = ch_angZ + 180.0
                    ch_curY = ch_angY * -1.0
                    ch_radZ = math.rad(ch_curZ)
                    ch_radY = math.rad(ch_curY)
                    ch_sinZ = math.sin(ch_radZ)
                    ch_cosZ = math.cos(ch_radZ)
                    ch_sinY = math.sin(ch_radY)
                    ch_cosY = math.cos(ch_radY)
                    ch_sinZ = ch_sinZ * ch_cosY
                    ch_cosZ = ch_cosZ * ch_cosY
                    ch_sinZ = ch_sinZ * ch_speed
                    ch_cosZ = ch_cosZ * ch_speed
                    ch_sinY = ch_sinY * ch_speed
                    ch_posX = ch_posX + ch_sinZ
                    ch_posY = ch_posY + ch_cosZ
                    ch_posZ = ch_posZ + ch_sinY
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_A) then
                    ch_curZ = ch_angZ - 90.0
                    ch_radZ = math.rad(ch_curZ)
                    ch_radY = math.rad(ch_angY)
                    ch_sinZ = math.sin(ch_radZ)
                    ch_cosZ = math.cos(ch_radZ)
                    ch_sinZ = ch_sinZ * ch_speed
                    ch_cosZ = ch_cosZ * ch_speed
                    ch_posX = ch_posX + ch_sinZ
                    ch_posY = ch_posY + ch_cosZ
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_D) then
                    ch_curZ = ch_angZ + 90.0
                    ch_radZ = math.rad(ch_curZ)
                    ch_radY = math.rad(ch_angY)
                    ch_sinZ = math.sin(ch_radZ)
                    ch_cosZ = math.cos(ch_radZ)
                    ch_sinZ = ch_sinZ * ch_speed
                    ch_cosZ = ch_cosZ * ch_speed
                    ch_posX = ch_posX + ch_sinZ
                    ch_posY = ch_posY + ch_cosZ
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_SPACE) then
                    ch_posZ = ch_posZ + ch_speed
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if isKeyDown(VK_SHIFT) then
                    ch_posZ = ch_posZ - ch_speed
                    setFixedCameraPosition(ch_posX, ch_posY, ch_posZ, 0.0, 0.0, 0.0)
                end
    
                ch_radZ = math.rad(ch_angZ)
                ch_radY = math.rad(ch_angY)
                ch_sinZ = math.sin(ch_radZ)
                ch_cosZ = math.cos(ch_radZ)
                ch_sinY = math.sin(ch_radY)
                ch_cosY = math.cos(ch_radY)
                ch_sinZ = ch_sinZ * ch_cosY
                ch_cosZ = ch_cosZ * ch_cosY
                ch_sinZ = ch_sinZ * 1.0
                ch_cosZ = ch_cosZ * 1.0
                ch_sinY = ch_sinY * 1.0
                ch_poiX = ch_posX
                ch_poiY = ch_posY
                ch_poiZ = ch_posZ
                ch_poiX = ch_poiX + ch_sinZ
                ch_poiY = ch_poiY + ch_cosZ
                ch_poiZ = ch_poiZ + ch_sinY
                pointCameraAtPoint(ch_poiX, ch_poiY, ch_poiZ, 2)
    
                if ch_keyPressed == 0 and isKeyDown(VK_F10) then
                    ch_keyPressed = 1
                    if ch_radarHud == 0 then
                        ch_hide_interface(true)
                        ch_radarHud = 1
                    else
                        ch_hide_interface(false)
                        ch_radarHud = 0
                    end
                end
    
                if wasKeyReleased(VK_F10) and ch_keyPressed == 1 then
                    ch_keyPressed = 0
                end
    
                if isKeyDown(187) then
                    ch_speed = ch_speed + 0.01
                    printStringNow(ch_speed, 1000)
                end
    
                if isKeyDown(189) then
                    ch_speed = ch_speed - 0.01
                    if ch_speed < 0.01 then
                        ch_speed = 0.01
                    end
                    printStringNow(ch_speed, 1000)
                end
                if isKeysPressed(config.data[mynick()].camhack.key) then
                    ch_hide_interface(true)
                    ch_radarHud = 0
                    ch_angPlZ = ch_angZ * -1.0
                    lockPlayerControl(false)
                    restoreCameraJumpcut()
                    setCameraBehindPlayer()
                    ch_flymode = 0
                end
            end
        end
    end
end

ch_hide_interface = function(bool)
    if not bool then
        -- Чат выключен
        memory.write(sampGetBase() + 0x7140F, 0x1, 0x1, true)
        sampSetChatDisplayMode(0)
        -- Радар выключен
        ffi.fill(ffi.cast(ffi.typeof('void*'), 0x58FC53), 5, 0x90)
        -- Радар выключен
        displayHud(false)
        memory.setint8(0xBA676C, 2)
    else
        -- Чат включен
        memory.write(sampGetBase() + 0x7140F, 0x0, 0x1, true)
        sampSetChatDisplayMode(2)
        -- Радар включен
        ffi.copy(ffi.cast(ffi.typeof('void*'), 0x58FC53), ffi.cast(ffi.typeof('void*'), tonumber(ffi.cast('intptr_t', ffi.cast('const char*', "\xE8\xD8\xA6\xFF\xFF")))), 5)
        -- Радар включен
        displayHud(true)
        memory.setint8(0xBA676C, 0)
    end
end







function check_profile()
    while true do
        wait(0)
        local nick = mynick()
        if nick and config.data[nick] == nil then
            ensureProfile(nick)
            thisScript():reload()
            return
        end
    end
end

driveby_enable = false
car = 0
driver = 0
driveby_weapon = 0
driveby_ammo = 0

function hideweaponFunc()
    while true do wait(0)
        if config.data[mynick()].hideweapon.status then
            if isCharInAnyCar(playerPed) then
                car = storeCarCharIsInNoSave(playerPed)
                driver = getDriverOfCar(car)
                if driver ~= playerPed then
                  if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() and isKeyJustPressed(72) then
                    if driveby_enable then
                      driveby_weapon = getCurrentCharWeapon(playerPed)
                      driveby_ammo = getAmmoInCharWeapon(playerPed, getCurrentCharWeapon(playerPed))
                      if driveby_ammo > 1 then
                       -- wait(200)
                        setCharAmmo(playerPed, driveby_weapon, 1)
                     --   wait(100)
                        setVirtualKeyDown(1, true)
                        wait(250)
                        setVirtualKeyDown(1, false)
                      --  wait(800)
                        if getAmmoInCharWeapon(playerPed, getCurrentCharWeapon(playerPed)) == 0 then
                          setCharAmmo(playerPed, driveby_weapon, driveby_ammo - 1)
                        else
                          setCharAmmo(playerPed, driveby_weapon, driveby_ammo)
                        end
                        driveby_enable = false
                      else
                        driveby_enable = false
                      end
                    else
                      driveby_enable = true
                    end
                  end
                end
              else
                driveby_enable = false
            end
        end
    end
end

car = 0
driver = 0
weapon = 0
trig = false
local start_while = os.clock()

function changeweaponFunc()
    while true do wait(0)
        if config.data[mynick()].hideweapon.status then
            if isCharInAnyCar(playerPed) then
                car = storeCarCharIsInNoSave(playerPed)
                driver = getDriverOfCar(car)
                if driver ~= playerPed then
                  if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() and (wasKeyPressed(219) or wasKeyPressed(221)) then
                    local div = 0
                    if wasKeyPressed(109) then
                      div = -1
                    end
                    if wasKeyPressed(107) then
                      div = 1
                    end
                    weapon = getCurrentCharWeapon(playerPed)
                    weapon = weapon + div
      
                    if weapon == 24 then
                      weapon = weapon + div
                    end
                    start_while = os.clock()
                    trig = false
                    while getAmmoInCharWeapon(playerPed, weapon) <= 0 or weapon >= 50 or weapon <= 22 do
                      wait(0)
                      weapon = weapon + div
                     if weapon == 24 then
                        weapon = weapon + div
                      end
                      if div == 1 and weapon > 50 then
                        weapon = 0
                      end
                      if div == -1 and weapon < 0 then
                        weapon = 50
                      end
                      if os.clock() - start_while > 1 then
                        trig = true
                        break
                      end
                    end
                    if not trig then
                      bs = raknetNewBitStream()
                      raknetBitStreamWriteInt32(bs, weapon)
      
                      raknetBitStreamWriteInt32(bs, 0)
                      raknetEmulRpcReceiveBitStream(22, bs)
                      raknetDeleteBitStream(bs)
                    end
                  end
                end
            end
        end
    end
end



-- Полный список заборов, маркеров и ломающихся объектов
fence_list = {


    -- [РАЗРУШАЕМЫЕ ОБЪЕКТЫ (Конусы, урны, будки, ящики)]
    849, 917, 918, 920, 958, 1211, 1220, 1221, 1225, 1226, 1228, 1237, 1238, 
    1251, 1254, 1280, 1310, 1327, 1328, 1329, 1334, 1335, 1336, 1337, 1339, 
    1340, 1363, 1421, 1422, 1424, 1425, 1427, 1459, 1994, 1995, 1996, 1997, 
    2900, 2904, 3036,

    -- [МЕТАЛЛИЧЕСКИЕ И ДЕРЕВЯННЫЕ ЗАБОРЫ И СЕТКИ]
    966, 967, 968, 969, 970, 971, 972, 973, 974, 975, 976, 977, 978, 979, 
    980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 
    994, 995, 996, 997, 998, 1407, 1408, 1409, 1410, 1411, 1412, 1413, 1414, 
    1415, 1417, 1418, 1419, 1423, 1434, 1435, 1446, 1447, 1456, 1460, 1468, 
    1552, 1553, 1653, 2098, 2395, 2400, 2650, 2651, 3260, 3276, 3282, 3475, 
    3550, 3850, 7228, 7893, 7894, 7921, 7922, 7933, 8167, 8674, 10252, 11473, 
    11474, 14501, 14715, 14716, 14843, 14883, 15064, 16052, 16281, 16312, 
    16627, 16628, 16629, 16630, 16631, 16632, 16633, 16634, 16635, 16636, 
    18074, 18856, 19075, 19641, 19861, 19862, 19863, 19864, 19865, 19866, 
    18967, 19868, 19869, 19870, 19880, 19906, 19908, 19910, 19911, 19912, 
    19945, 19947, 3407, 3408, 1440, 1438, 1432, 3380, 3221
}

local fence_hash = {}
for _, id in ipairs(fence_list) do
    fence_hash[id] = true
end

function fenceFunc()
    while true do 
        wait(200) -- Оптимальная задержка против лагов
        
        if config.data[mynick()] ~= nil and config.data[mynick()].remove_fence.status and sampIsLocalPlayerSpawned() and not isCharDead(PLAYER_PED) then
            local xP, yP, zP = getCharCoordinates(PLAYER_PED)
            
            -- Высчитываем дистанцию в зависимости от того, в машине игрок или нет
            local dlina = isCharInAnyCar(PLAYER_PED) and config.data[mynick()].remove_fence.dist_car or config.data[mynick()].remove_fence.dist_onfoot
            if dlina == 100 then dlina = 9999 end
         minX = -162.36
         maxX = -149.54
         minY = 1135.63
         maxY = 1140.07

        -- Проверяем, входит ли текущая координата в этот диапазон
    
            for _, object in pairs(getAllObjects()) do
                if doesObjectExist(object) then
                    -- Важно: игнорируем оружие и аксессуары на игроках
                    if not isObjectAttached(object) then
                        local modelid = getObjectModel(object)
                        
                        -- Если объекта НЕТ в хэш-таблице исключений
                        if fence_hash[modelid] then
                            local recc, xO, yO, zO = getObjectCoordinates(object)
                            
                            -- Быстрая проверка дистанции и модели
                            if getDistanceBetweenCoords2d(xO, yO, xP, yP) <= dlina and modelid < 18000  and not ((xO >= minX) and  (xO <= maxX) and (yO >= minY) and  (yO <= maxY))  then
                                -- Если объект еще не спрятан под землю, прячем его
                                if zO > (zP - 20.0) then 
                                    setObjectCollision(object, false)
                                    setObjectScale(object, 0.0) 
                                    setObjectCoordinates(object, xO, yO, zO - 100.0)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end



function fence()
    imgui.ToggleButtonText("Удалять разрушаемые объекты", fence_status, function()
        config.data[mynick()].remove_fence.status = not config.data[mynick()].remove_fence.status
        config_save(config.data)
		object_all_status = imgui.new.bool((config.data[mynick()].remove_fence.status and config.data[mynick()].flashlight.status))
    end)    
    if imgui.SliderInt('Расстояние с ног', fence_len, 1, 100) then
        config.data[mynick()].remove_fence.dist_onfoot = fence_len[0]
        config_save(config.data)
    end

    if imgui.SliderInt('Расстояние в т/с', fence_car_len, 1, 100) then
        config.data[mynick()].remove_fence.dist_car = fence_car_len[0]
        config_save(config.data)
    end
end




function ReplacingWindowWithNickName()
    if config.data[mynick()] ~= nil and config.data[mynick()].ReplacingWindowWithNickName.status then
        ffi.C.SetWindowTextA(ffi.C.GetActiveWindow(), string.format("%s - %s", sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))), sampGetCurrentServerName()))
    else
        ffi.C.SetWindowTextA(ffi.C.GetActiveWindow(), "GTA:SA:MP")
    end
end


local flashlight_list = {
	1214, 1215, 1223, 1226, 1231, 1232, 1278, 1283, 1290, 1294, 1297, 1307, 1308, 3459, 1351, 1352
}
local flashlight_hash = {}
for _, id in ipairs(flashlight_list) do
    flashlight_hash[id] = true
end

function flashlightFunc()
    while true do 
        wait(200) -- Оставляем 200мс для высокой производительности
        
        if config.data[mynick()].flashlight.status and sampIsLocalPlayerSpawned() and not isCharDead(PLAYER_PED) then
            local xP, yP, zP = getCharCoordinates(PLAYER_PED)
            
            -- Проверка по высоте (как в вашем коде < 900)
            if zP and zP < 900 then
                
                -- Настройка дистанции
                local dlina = config.data[mynick()].flashlight.dist or 10
                if dlina == 100 then
                    dlina = 9999
                end
                
                for _, object in pairs(getAllObjects()) do
                    if doesObjectExist(object) then
                        local modelid = getObjectModel(object)
                        
                        -- ПРЯМАЯ ПРОВЕРКА: Если модель ЕСТЬ в списке flashlight_list
                        if flashlight_hash[modelid] then
                            local rec, xO, yO, zO = getObjectCoordinates(object)
                            
                            -- Считаем расстояние по горизонтали (чтобы скрытый объект под землей не "выпадал" из радиуса)
                            if getDistanceBetweenCoords2d(xO, yO, xP, yP) <= dlina then
                                
                                -- ЗАЩИТА ОТ ЛАГОВ: Если объект еще НЕ опущен под землю
                                if zO > (zP - 20.0) then
                                    -- 1. Отключаем физику (коллизию)
                                    setObjectCollision(object, false)
                                    
                                    -- 2. Сужаем масштаб в ноль (убираем визуально без эффектов)
                                    setObjectScale(object, 0.0)
                                    
                                    -- 3. Прячем глубоко под карту
                                    setObjectCoordinates(object, xO, yO, zO - 100.0)
                                end
                                
                            end
                        end
                    end
                end
                
            end
        end
    end
end

function glonass()
    imgui.ToggleButtonText("Мини-карта", webglonass, function()
        config.data[mynick()].glonass.status = not config.data[mynick()].glonass.status
        config_save(config.data)
						    if not WSstatus and config.data[mynick()].glonass.status then
                                markerWsCommand()
							elseif WSstatus and not config.data[mynick()].glonass.status and not config.data[mynick()].marker.status then
								markerWsCommand()
                            end  
    end)
    if glonass_hotkey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].glonass.key = glonass_hotkey:GetHotKey()
        config_save(config.data)
    end

    if imgui.SliderInt('Размер карты', map_size, 0, 2000) then
        config.data[mynick()].glonass.size = map_size[0]
        config_save(config.data)
    end

    if imgui.SliderInt('Размер маркера', marker_size, 0, 100) then
        config.data[mynick()].glonass.marker_size = marker_size[0]
        config_save(config.data)
    end

  --[[  if imgui.SliderInt('Размер фуры', matavoz_size, 0, 99) then
        config.data[mynick()].glonass.matavoz_size = matavoz_size[0]
        config_save(config.data)
    end]]

    if imgui.SliderInt('Размер персонажей', people_size, 0, 55) then
        config.data[mynick()].glonass.people_size = people_size[0]
        config_save(config.data)
    end

    if imgui.SliderInt('Размер ников', nick_size, 0, 25) then
        config.data[mynick()].glonass.nick = nick_size[0]
        webfont = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], 12, 4)
        fontSmall = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick + 2, 4)
        fontPlayer = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick, 4)
        config_save(config.data)
    end


    if imgui.SliderInt('Размер HP', hp_size, 0, 25) then
        config.data[mynick()].glonass.hp = hp_size[0]
        fontHp = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.hp, 4)
        config_save(config.data)
    end

    if imgui.Combo("Шрифт", gl_w_combo_int, gl_w_combo_items, #gl_w_combo_list) then
        config.data[mynick()].glonass.font = gl_w_combo_int[0]
        webfont = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], 12, 4)
        fontSmall = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick + 2, 4)
        fontPlayer = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.nick, 4)
        fontHp = renderCreateFont(gl_w_combo_list[config.data[mynick()].glonass.font + 1], config.data[mynick()].glonass.hp, 4)
        config_save(config.data)
    end

    if imgui.Combo("Иконка маркера", markker_combo_int, markker_combo_items, #markker_combo_list) then
        config.data[mynick()].glonass.marker = markker_combo_int[0]
        markerTexturePath = MAP_DIRECTORY .. "marker.png"
if config.data[mynick()].glonass.marker == 1 then
    markerTexturePath = MAP_DIRECTORY .. "marker2.png"
end
    if doesFileExist(markerTexturePath) then
        markerTexture = renderLoadTextureFromFile(markerTexturePath)
        if markerTexture then
         --   wsLog("MARKER ICON LOADED: " .. markerTexturePath)
        else
            wsLog("MARKER ICON LOAD FAILED: " .. markerTexturePath)
        end
    else
        wsLog("MARKER ICON NOT FOUND: " .. markerTexturePath)
    end
        config_save(config.data)
    end

    if imgui.Combo("Мини-карта##q", gl_combo_int, gl_combo_items, #gl_combo_list) then
        config.data[mynick()].glonass.tip = gl_combo_int[0]
        config_save(config.data)
        loadMapTextures()
    end
end

function flashlight()
    imgui.ToggleButtonText("Удалять столбы", flashlight_status, function()
        config.data[mynick()].flashlight.status = not config.data[mynick()].flashlight.status
        config_save(config.data)
		object_all_status = imgui.new.bool((config.data[mynick()].remove_fence.status and config.data[mynick()].flashlight.status))
    end)    
    if imgui.SliderInt('Расстояние', flashlight_len, 1, 100) then
        config.data[mynick()].flashlight.dist = flashlight_len[0]
        config_save(config.data)
    end
end


unmack = false
unmack2 = false
function unmackFunc()
	while true do wait(0)
	    if unmack then

			wait(700)
			sampSendClickTextdraw(pmask_cancel)
			unmack = false
		end
	end
end



function pmask_register()
	sampRegisterChatCommand("pmask", fastMask)
end

function fastMask()
	if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.pmask then
	fmask = true
	find = false
	sampSendChat('/items')
	end
end

function autorep()
	while true do wait(0)
		if isPlayerDead(PLAYER_HANDLE) or sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 1206 or sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 1205 then

		if load_all and config.data[mynick()].autoreport.status and killerId >= 0 and not is_whitelisted(KillerId) then
			if not config.data[mynick()].autoreport.capture or (config.data[mynick()].autoreport.capture and capture_status) then
        if  (os.time() - autoreport_time) > 119 then
            lua_thread.create(function()

                
                wait(config.data[mynick()].autoreport.wait)
                math.randomseed(os.time())
				                repeat
                    wait(0)
                until os.clock() * 1000 - antiflood > 1000
                local number = math.random(1, #config.data[mynick()].autoreport.list_prichin)
                prichina = u8:decode(config.data[mynick()].autoreport.list_prichin[number])
                sampSendChat(("/report %s %s"):format(killerId, prichina))
				
            end)
		else
			lua_thread.create(function()
                repeat
                    wait(0)
                until os.clock() * 1000 - antiflood > 1000
			     sampSendChat("/fc preport "..killerId)
			end)
        end
	    end
	    end
		checkCapture()
	    wait(5000)
	    end
    end
end

function proct_pr_func()
    while true do
        wait(300)

        if config.data[mynick()] ~= nil
            and config.data[mynick()].pr.status
            and not config.data[mynick()].pr.marker then

            if help_pr ~= nil or not config.data[mynick()].pr.family then
                local myResult, myId = sampGetPlayerIdByCharHandle(playerPed)

                for id = 0, sampGetMaxPlayerId(false) do
                    if sampIsPlayerConnected(id) and id ~= myId then
                        local result, ped = sampGetCharHandleBySampPlayerId(id)

                        if result and ped ~= 0 and doesCharExist(ped) then
                            -- Не удаляем один и тот же ped повторно каждые 300 мс.
                            -- Если SA-MP создаст новый ped для этого ID, он будет удалён один раз снова.
                            if pr_removed_peds[id] ~= ped then
                                if not is_whitelisted(id) or not config.data[mynick()].pr.family then
                                    local playerColor = sampGetPlayerColor(id)

                                    if color_filter[playerColor] == true then
                                        pr_removed_peds[id] = ped
                                if isCharInAnyCar(ped) then

									if not getDriverOfCar(storeCarCharIsInNoSave(ped)) and not isInVeh(getCarModel(storeCarCharIsInNoSave(ped))) then
										delChar(id)
									end
								else
									delChar(id)
								end
                                    else
                                        pr_removed_peds[id] = nil
                                    end
                                else
                                    pr_removed_peds[id] = nil
                                end
                            end
                        else
                            pr_removed_peds[id] = nil
                        end
                    else
                        pr_removed_peds[id] = nil
                    end
                end
            end
        else
            -- При включении режима маркера/выключении Player Remover
            -- сбрасываем историю удалённых ped.
            pr_removed_peds = {}
        end
    end
end



function update_fraction()
	color_filter = {
    [4280979824] = config.data[mynick()].pr.rifa,  
    [2852167424] = config.data[mynick()].pr.grove, 
    [3355573503] = config.data[mynick()].pr.aztec, 
    [4294958628] = config.data[mynick()].pr.vagos,
    [4289926119] = config.data[mynick()].pr.ballac,  
    [4290033079] = config.data[mynick()].pr.rm,   
    [4292716289] = config.data[mynick()].pr.lcn,   
    [2868838400] = config.data[mynick()].pr.yakudza,   
    [4281545523] = config.data[mynick()].pr.mongols,   
    [4281110935] = config.data[mynick()].pr.pagans,   
    [4294201344] = config.data[mynick()].pr.warlocks,    
	[16777215] = config.data[mynick()].pr.bich
}
end
----------------------------------------------------------------
------------------------------BIKERLIST-------------------------
----------------------------------------------------------------
--##bikerlist


bikerlist_organization = {
    [4294201344] = "Warlock MC",
    [4281545523] = "Mongols MC",
    [4281110935] = "Pagans MC",
}
function bikerlists()
    imgui.ToggleButtonText("Байкерлист", bikerlist_status, function()
        config.data[mynick()].bikerlist.status = not config.data[mynick()].bikerlist.status
        config_save(config.data)
    end)
    --[[imgui.ToggleButtonText("Информировать о заходе/выходе байкеров", bikerlist_checker, function()
        config.data[mynick()].bikerlist.checker = not config.data[mynick()].bikerlist.checker
        config_save(config.data)
    end)]]
    imgui.Text("Активация")
    if bikerlist_hotkey:ShowHotKey(imgui.ImVec2(390, 20)) then 
        config.data[mynick()].bikerlist.key = bikerlist_hotkey:GetHotKey()
        config_save(config.data)
    end
    imgui.PushItemWidth(390)
    imgui.InputText("", bikerlist_cmd, sizeof(bikerlist_cmd))
    imgui.PopItemWidth()
    if imgui.Button("Сохранить команду", imgui.ImVec2(390,22)) then
        bikerlist_command = config.data[mynick()].bikerlist.command:gsub("/", "")
        sampUnregisterChatCommand(bikerlist_commandd)
        config.data[mynick()].bikerlist.command = str(bikerlist_cmd)
        config_save(config.data)
        bikerlist_register()
    end
end

function bikerlistFunc()
    while true do wait(0)
        if isKeysPressed(config.data[mynick()].bikerlist.key) and isKeyCanBePressed() and config.data[mynick()].bikerlist.status then
            BikerlistMenu[0] = not BikerlistMenu[0]
        end

    end
end

function bikerlist_register()
    bikerlist_command = config.data[mynick()].bikerlist.command:gsub("/", "")
    sampRegisterChatCommand(bikerlist_command, function()
        BikerlistMenu[0] = not BikerlistMenu[0]
	end)
end

imgui.OnFrame(
    function() return BikerlistMenu[0] end,
    function()
        local function Vec4(text)
            return imgui.ImVec4(bit.band(bit.rshift(text, 16), 255) / 255, bit.band(bit.rshift(text, 8), 255) / 255, bit.band(text, 255) / 255, 1)
        end
        
        local x_screen, y_screen = getScreenResolution()
        
        imgui.SetNextWindowSize(imgui.ImVec2(400, 500), 2)
        imgui.SetNextWindowPos(imgui.ImVec2(x_screen / 2, y_screen / 2), 8, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(fa["MOTORCYCLE"]..'  EVOLVE MULTITOOL SPECIAL FOR PALERIDERS NATION  '..fa["MOTORCYCLE"].."##plrd", BikerlistMenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
          
        imgui.Columns(2, "Columns", false)
        imgui.Text(u8("Organization"))
        imgui.NextColumn()
        imgui.Text(u8("Nickname"))
        imgui.NextColumn()
        imgui.Separator()
      
        local bikerlist = {}
        local bikerlist_online = {}
      
        for i = 0, sampGetMaxPlayerId() do
          if sampIsPlayerConnected(i) or i == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
            local Colors = sampGetPlayerColor(i)
            if sampGetPlayerNickname(i):find("_") then
                if bikerlist_organization[Colors] then
                    bikerlist[#bikerlist + 1] = { clist = Colors, id = i }
                    
                    bikerlist_online[Colors] = (bikerlist_online[Colors] or 0) + 1
                end
            end
          end
        end
      

        local bikerlist_online_list = {}
        
        for color, count in pairs(bikerlist_online) do
          table.insert(bikerlist_online_list, { color = color, count = count })
        end

        for _, online_info in ipairs(bikerlist_online_list) do
          local list_color = online_info.color
          local count_online = online_info.count
          for _, v in ipairs(bikerlist) do
            if v.clist == list_color then
              local nick_list = sampGetPlayerNickname(v.id)
              imgui.TextColored(Vec4(list_color), bikerlist_organization[list_color])
              imgui.NextColumn()		
              imgui.Text(("%s [%s]"):format(nick_list, v.id))
              imgui.NextColumn()
            end
          end
          
          if count_online > 0 then 
              imgui.Text("Online: " .. tostring(count_online)) 
              imgui.NextColumn()
              imgui.Text("")
              imgui.NextColumn()
          end
        end
        imgui.End()
    end
)

my_font = renderCreateFont("Segoe UI", 12, 1)
 font_height = renderGetFontDrawHeight(my_font)
 text_msg = "ВЫ В КВАДРАТЕ "
 font_length = renderGetFontDrawTextLength(my_font, text_msg)

  base_blue_color = 0xFFd11313 
  local in_zone = false
function render_vkv2()
	while true do wait(0)
	if config.data[mynick()] ~= nil and config.data[mynick()].bikerlines.kv_render then
		    if isCharPlayingAnim(PLAYER_PED, "M_LOOK") or true then -- Просто условие присутствия в игре
                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                -- Вызываем нашу функцию
				in_zone = false
					if isPointInPolygon(mx, my, zone_montgomery2) or isPointInPolygon(mx, my, zone_blueberry2) or isPointInPolygon(mx, my, zone_palomino_creek2) or isPointInPolygon(mx, my, zone_angel_pine2) or isPointInPolygon(mx, my, zone_dillimore2) or isPointInPolygon(mx, my, zone_fort_carson2) or isPointInPolygon(mx, my, zone_las_barrancas2) or isPointInPolygon(mx, my, zone_el_quebrados2) then
						in_zone = true
					end
                --in_zone = isPointInPolygon(mx, my, zone_montgomery2)
            end
        if in_zone or pos_kvb then
            -- Рендерим текст на экране: строка, X, Y, цвет (ARGB)
                            local x = config.data[mynick()].bikerlines.kv_x
                local y = config.data[mynick()].bikerlines.kv_y

                local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12


                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
        end
	end
--[[		                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                -- Вызываем нашу функцию
                in_zone = isPointInPolygon(mx, my, zone_montgomery2)
				if in_zone then msg("3 ") end
   if config.data[mynick()] ~= nil and config.data[mynick()].bikerlines.kv_render and (in_b_zone or pos_kvb) then

                local x = config.data[mynick()].bikerlines.kv_x
                local y = config.data[mynick()].bikerlines.kv_y -- Исправлена опечатка cconfig
   local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12



                -- Размытие по бокам
                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                -- Главный синий прямоугольник (высота увеличена на 8 для запаса)
                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                -- Текст ровно внутри квадрата
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
            end

            -- 2. Блок для мафий
            if config.data[mynick()] ~= nil and config.data[mynick()].mafialines.kv_render and (in_m_zone or pos_kvm )then
                local x = config.data[mynick()].mafialines.kv_x
                local y = config.data[mynick()].mafialines.kv_y

   local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12


                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
            end
			]]
	end
end

function render_vkv3()
	while true do wait(0)
	if config.data[mynick()] ~= nil and config.data[mynick()].mafialines.kv_render then
		    if isCharPlayingAnim(PLAYER_PED, "M_LOOK") or true then -- Просто условие присутствия в игре
                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                -- Вызываем нашу функцию
				in_zone = false
					if isPointInPolygon(mx, my, zone_one) or isPointInPolygon(mx, my, zone_two) or isPointInPolygon(mx, my, zone_three) or isPointInPolygon(mx, my, zone_fo) or isPointInPolygon(mx, my, zone_five) or isPointInPolygon(mx, my, zone_six) or isPointInPolygon(mx, my, zone_seven) then
						in_zone = true
					end
                --in_zone = isPointInPolygon(mx, my, zone_montgomery2)
            end
        if in_zone or pos_kvm then
            -- Рендерим текст на экране: строка, X, Y, цвет (ARGB)
                            local x = config.data[mynick()].mafialines.kv_x
                local y = config.data[mynick()].mafialines.kv_y

                local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12


                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
        end
	end
--[[		                local mx, my, mz = getCharCoordinates(PLAYER_PED)
                -- Вызываем нашу функцию
                in_zone = isPointInPolygon(mx, my, zone_montgomery2)
				if in_zone then msg("3 ") end
   if config.data[mynick()] ~= nil and config.data[mynick()].bikerlines.kv_render and (in_b_zone or pos_kvb) then

                local x = config.data[mynick()].bikerlines.kv_x
                local y = config.data[mynick()].bikerlines.kv_y -- Исправлена опечатка cconfig
   local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12



                -- Размытие по бокам
                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                -- Главный синий прямоугольник (высота увеличена на 8 для запаса)
                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                -- Текст ровно внутри квадрата
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
            end

            -- 2. Блок для мафий
            if config.data[mynick()] ~= nil and config.data[mynick()].mafialines.kv_render and (in_m_zone or pos_kvm )then
                local x = config.data[mynick()].mafialines.kv_x
                local y = config.data[mynick()].mafialines.kv_y

   local font_height = renderGetFontDrawHeight(my_font)
                local font_length = renderGetFontDrawTextLength(my_font, text_msg) + 12


                local offset = 0
                local color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x - offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                offset = 0
                color_int = 90
                for i = 1, 10 do
                    offset = offset + 2
                    color_int = color_int + 10
                    local color = modifyAlpha(base_blue_color, -(color_int))
                    renderDrawBox(x + offset, y, font_length, font_height + 8, argb2abgr(color))
                end

                renderDrawBox(x, y, font_length, font_height + 8, argb2abgr(base_blue_color))
                renderFontDrawText(my_font, text_msg, x + 6, y + 4, argb2abgr(0xFFFFFFFF))
            end
			]]
	end
end

gz_render = LPH_NO_VIRTUALIZE(function()
    if (config.data[mynick()].mafialines.kv_render or config.data[mynick()].bikerlines.kv_render) and isPlayerInActionGangZone() then
		 text_msg = "ВЫ В МИГАЮЩЕМ "
	elseif (config.data[mynick()].mafialines.kv_render or config.data[mynick()].bikerlines.kv_render) and not isPlayerInActionGangZone() then
		 text_msg = "ВЫ В КВАДРАТЕ "
    end
end)

function gzrenderFunc()
	while true do wait(0)
        gz_render()
	end
end

function isPlayerInActionGangZone()
    local gz_pool = ffi.cast('struct stGangzonePool*', sampGetGangzonePoolPtr())
    local result = false
    for i = 0,1023 do
        if gz_pool.iIsListed[i] ~= 0 and gz_pool.pGangzone[i] ~= nil then
            local gz_pos = gz_pool.pGangzone[i].fPosition
            local color = gz_pool.pGangzone[i].dwColor
            local color_alt = gz_pool.pGangzone[i].dwAltColor
            if color ~= color_alt then
                local x,y, z = getCharCoordinates(PLAYER_PED)
                if ((x >= gz_pos[0] and x <= gz_pos[2]) or (x <= gz_pos[0] and x >= gz_pos[2])) and ((y >= gz_pos[1] and y <= gz_pos[3]) or (y <= gz_pos[1] and y >= gz_pos[3])) then
                    result = true
                    break
                end
            end
        end
    end
    return result
end
function isPointInPolygon(x, y, polygon)
    local wn = 0
    local count = #polygon
    
    for i = 1, count do
        -- Текущая точка полигона
        local p1 = polygon[i]
        -- Следующая точка (если дошли до конца, соединяем с первой точкой)
        local p2 = polygon[i == count and 1 or i + 1]
        
        if p1.y <= y then
            if p2.y > y then
                -- Луч пересекает грань при движении вверх
                local is_left = (p2.x - p1.x) * (y - p1.y) - (x - p1.x) * (p2.y - p1.y)
                if is_left > 0 then
                    wn = wn + 1
                end
            end
        else
            if p2.y <= y then
                -- Луч пересекает грань при движении вниз
                local is_left = (p2.x - p1.x) * (y - p1.y) - (x - p1.x) * (p2.y - p1.y)
                if is_left < 0 then
                    wn = wn - 1
                end
            end
        end
    end
    
    -- Если индекс вращения не равен 0, значит точка гарантированно находится внутри
    return wn ~= 0
end


--[[function playeer_removeFunc()
    while true do wait(0)
        if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.playeer_remove then
            -- Перебираем ID всех возможных игроков (от 0 до 999)
            for id = 0, 999 do
                -- Проверяем, подключен ли игрок и создан ли его персонаж в зоне стрима
                if sampIsPlayerConnected(id)  then
                    local result, ped = sampGetCharHandleBySampPlayerId(id)
                    -- Если хэндл персонажа успешно получен, удаляем его
                    if result and doesCharExist(ped) then
                        deleteChar(ped)
                    end
                end
            end
        end
    end
end]]

function config_nickname()
    -- Дополнительная страховка: даже если старый/внешний код успел записать
    -- профиль с (ID), не показываем его в списке профилей.
    cleanupProfileNames()

    local macciv_cetting = {}
    for k, v in pairs(config.data) do
        if k ~= "Default" and k ~= "Default_nickname" and k ~= "Default_int" then
            local normalized = normalizeProfileNick(k)
            if normalized ~= "" and normalized == k then
                table.insert(macciv_cetting, k)
            end
        end
    end

    table.sort(macciv_cetting, function(a, b)
        return a:lower() < b:lower()
    end)

    return macciv_cetting
end

function config_nickname_int()
    local macciv_xxx = config_nickname()
    local selected = config.data["Default_nickname"]
        and config.data["Default_nickname"].settings
        and normalizeProfileNick(config.data["Default_nickname"].settings.nickname)

    for i = 1, #macciv_xxx do
        if macciv_xxx[i] == selected then
            return i - 1
        end
    end

    return 0
end
function refreshSettingsProfileCombos(force)
    local fresh = config_nickname()

    local function sameList(a, b)
        if type(a) ~= "table" or #a ~= #b then
            return false
        end
        for i = 1, #a do
            if a[i] ~= b[i] then
                return false
            end
        end
        return true
    end

    if force or not sameList(combosettings, fresh) then
        local selected = combosettings and combosettings[int_settings[0] + 1]
        combosettings = fresh
        combo_settings = imgui.new['const char*'][#combosettings](combosettings)

        local selectedIndex = 0
        if selected then
            selected = normalizeProfileNick(selected)
            for i = 1, #combosettings do
                if combosettings[i] == selected then
                    selectedIndex = i - 1
                    break
                end
            end
        end
        int_settings[0] = selectedIndex
    end

    if force or not sameList(combosettings2, fresh) then
        local selected = combosettings2 and combosettings2[int_settings2[0] + 1]
        combosettings2 = fresh
        combo_settings2 = imgui.new['const char*'][#combosettings2](combosettings2)

        local selectedIndex = 0
        if selected then
            selected = normalizeProfileNick(selected)
            for i = 1, #combosettings2 do
                if combosettings2[i] == selected then
                    selectedIndex = i - 1
                    break
                end
            end
        end
        int_settings2[0] = selectedIndex
    end
end

function mynick()
    local result, playerId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if not result then
        return nil
    end

    local nick = sampGetPlayerNickname(playerId)
    return normalizeProfileNick(nick)
end

function renderpatronFunc()
    while true do wait(0)
        if config.data[mynick()] ~= nil and config.data[mynick()].render_gun.render then

            if shouldDraw(renderpatron.FamilySafeInfo.de) then
                renderFontDrawText(
                    font_for_notification,
                    ("Deagle: %d"):format(renderpatron.FamilySafeInfo.de),
                    config.data[mynick()].render_gun.x,
                    config.data[mynick()].render_gun.y,
                    argb2abgr(config.data[mynick()].render_gun.color)
                )
            end

            if shouldDraw(renderpatron.FamilySafeInfo.ak) then
                renderFontDrawText(
                    font_for_notification,
                    ("AK47: %d"):format(renderpatron.FamilySafeInfo.ak),
                    config.data[mynick()].render_gun.x,
                    config.data[mynick()].render_gun.y + 15,
                    argb2abgr(config.data[mynick()].render_gun.color)
                )
            end

            if shouldDraw(renderpatron.FamilySafeInfo.m4) then
                renderFontDrawText(
                    font_for_notification,
                    ("M4: %d"):format(renderpatron.FamilySafeInfo.m4),
                    config.data[mynick()].render_gun.x,
                    config.data[mynick()].render_gun.y + 30,
                    argb2abgr(config.data[mynick()].render_gun.color)
                )
            end

            if shouldDraw(renderpatron.FamilySafeInfo.sh) then
                renderFontDrawText(
                    font_for_notification,
                    ("Shotgun: %d"):format(renderpatron.FamilySafeInfo.sh),
                    config.data[mynick()].render_gun.x,
                    config.data[mynick()].render_gun.y + 45,
                    argb2abgr(config.data[mynick()].render_gun.color)
                )
            end

            if shouldDraw(renderpatron.FamilySafeInfo.ri) then
                renderFontDrawText(
                    font_for_notification,
                    ("Rifle: %d"):format(renderpatron.FamilySafeInfo.ri),
                    config.data[mynick()].render_gun.x,
                    config.data[mynick()].render_gun.y + 60,
                    argb2abgr(config.data[mynick()].render_gun.color)
                )
            end
        end
    end
end




function driftFunc()
    while true do wait(0)
        if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.driftmod_status then
            if isCharInAnyCar(playerPed) then 
                local car = storeCarCharIsInNoSave(playerPed)
                local speed = getCarSpeed(car)
                isCarInAirProper(car)
                setCarCollision(car, true)
                if isKeysDown(config.data[mynick()].small_tweaks.driftmod_key) and isVehicleOnAllWheels(car) and doesVehicleExist(car) and speed > 5.0 then
                    setCarCollision(car, false)
                    if isCarInAirProper(car) then
                        setCarCollision(car, true)
    
                        if isKeyDown(VK_A) then 
                            addToCarRotationVelocity(car, 0, 0, config.data[mynick()].small_tweaks.driftmod_speed)
                        end
    
                        if isKeyDown(VK_D) then 			
                            addToCarRotationVelocity(car, 0, 0, -config.data[mynick()].small_tweaks.driftmod_speed)	
                        end
                    end
                end
            end
        end
    end
end
function driftmod()
    imgui.ToggleButtonTextGear2("Drift Master", drift_status, function()
        config.data[mynick()].small_tweaks.driftmod_status = not config.data[mynick()].small_tweaks.driftmod_status
        config_save(config.data)
    end)  
--imgui.Question('Позволяет поворачивать авто в стороны.\nАктивация: '.. keys.id_to_name(config.data[mynick()].small_tweaks.driftmod_key)  .. ' + A и '.. keys.id_to_name(config.data[mynick()].small_tweaks.driftmod_key) .. ' + D.')

    if DriftHotKey:ShowHotKey(imgui.ImVec2(390, 20)) then 
		config.data[mynick()].small_tweaks.driftmod_key = DriftHotKey:GetHotKey()
        config_save(config.data)
    end

    if imgui.SliderFloat('Скорость##334', drift_speed, 0.001, 1) then
        config.data[mynick()].small_tweaks.driftmod_speed = drift_speed[0]
        config_save(config.data)
    end

end


function useraddFunc()
	while true do wait(0)
	if Menu[0] and page == 10 then
		tempTable2 = {}
       for k, v in pairs(table_nick_uc) do
		    local result, sId = getPlayerIdByNickname2(v)
            if result then
                table.insert(tempTable2, string.format("%s[%d]", v, sId))
            end
	   end
	   hudPlayers = tempTable2
		wait(5000)
	end
end
end

famfont = renderCreateFont("BankGothic Md B", 8.5, 5)
function famcheckrender()
	while true do wait(0)
	if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.fam_status and config.data[mynick()].eblochecker.families then
	renderFontDrawText(famfont, u82(families.text), config.data[mynick()].families.x, config.data[mynick()].families.y, 0xFFFFFFFF)
	end

	if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.fam_status and config.data[mynick()].eblochecker.statuses then
	    renderFontDrawText(famfont, u82(statuses.text), config.data[mynick()].statuses.x, config.data[mynick()].statuses.y, 0xFFFFFFFF)
	end
	end
end

function perevorot()
    imgui.ToggleButtonTextGear2("Переворот авто", perevorot_status, function()
        config.data[mynick()].perevorot.status = not config.data[mynick()].perevorot.status
        config_save(config.data)
    end, true, function() window_function = "perevorot" end)   

    if perevorot_one_hotkey:ShowHotKey(imgui.ImVec2(180,20)) then 
        config.data[mynick()].perevorot.key_one = perevorot_one_hotkey:GetHotKey()
        config_save(config.data)
    end

    imgui.SameLine()

    if perevorot_two_hotkey:ShowHotKey(imgui.ImVec2(180, 20)) then 
        config.data[mynick()].perevorot.key_two = perevorot_two_hotkey:GetHotKey()
        config_save(config.data)
    end

   if imgui.SliderInt(u8'Скорость', perevorot_speed, 0, 50) then
        config.data[mynick()].perevorot.speed = perevorot_speed[0]
        config_save(config.data)
    end
end


function perevorotFunc()
    while true do wait(0)
        if isCharInAnyCar(PLAYER_PED) and config.data[mynick()].perevorot.status and isKeyCanBePressed() then
			if isKeysDown(config.data[mynick()].perevorot.key_one) then
				addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, -tonumber(config.data[mynick()].perevorot.speed / 100), 0.0)
            elseif isKeysDown(config.data[mynick()].perevorot.key_two) then
				addToCarRotationVelocity(storeCarCharIsInNoSave(PLAYER_PED), 0.0, tonumber(config.data[mynick()].perevorot.speed / 100), 0.0)
			end
		end
    end
end
function obxod2f()
	while true do 
clickwarpFunc2()
	end
end

function dlcarFunc()
    dlcar_font = renderCreateFont("Verdana", 10, 5)
    while true do
		wait(0)
		if config.data[mynick()] ~= nil and config.data[mynick()].dlcar.status then
			if isCharInAnyCar(PLAYER_PED) then
				mycar = getCarCharIsUsing(PLAYER_PED)
			end
			for _, handle in ipairs(getAllVehicles()) do
				if doesVehicleExist(handle) and isCarOnScreen(handle) then
					vehName = getGxtText(getNameOfVehicleModel(getCarModel(handle)))
					myX, myY, myZ = getBodyPartCoordinates(8, PLAYER_PED)
					X, Y, Z = getCarCoordinates(handle)
                    if getDistanceBetweenCoords3d(myX, myY, myZ, X, Y, Z) <= config.data[mynick()].dlcar.dist then
                        result, point = processLineOfSight(myX, myY, myZ, X, Y, Z, true, false, false, true, false, false, false, false)
                        if not result then
                            local X, Y, Z = getOffsetFromCarInWorldCoords(handle, 0, 0, 0)
                            X, Y = convert3DCoordsToScreen(X, Y, Z)
                            local CarHP = getCarHealth(handle)
                            renderFontDrawText(dlcar_font, CarHP, X, Y, 0xFFFFFFFF)
                        end
                    end
				end
			end
		end
	end
end

function dlcar()
    imgui.ToggleButtonTextGear2("Показывать здоровье т/с", dlcar_status, function()
        config.data[mynick()].dlcar.status = not config.data[mynick()].dlcar.status
        config_save(config.data)
    end, true, function() end)

    if imgui.SliderInt('Дистанция', dlcar_dist, 1, 200) then
        config.data[mynick()].dlcar.dist = dlcar_dist[0]
        config_save(config.data)
    end


end

function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
end


function autohealFunc()
	while true do wait(0)
	if getCharHealth(PLAYER_PED) < 100 and config.data[mynick()].small_tweaks.autoheal and nawa_inta > 99 and nawa_inta < 103 then
	    autoheal = true
	end

	if autoheal then
	    repeat
            wait(0)
        until os.clock() * 1000 - antiflood > 1000
		sampSendChat("/healme")
		wait(150)
	end
end
end
function autodrugFunc()
	while true do wait(0)
		if getCharHealth(PLAYER_PED) <= 30 and config.data[mynick()].AutoCapt.autodrug then
			kolvodrug = ((160 - getCharHealth(PLAYER_PED))/10)

		    sampProcessChatInput(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, math.ceil(kolvodrug)))
			sampProcessChatInput(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, math.ceil(kolvodrug)))
			wait(30000)
	    end
	end
end
function famcheck2fnc()
	while true do wait(0)
		if pos_onef then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].statuses.x = curX
			config.data[mynick()].statuses.y = curY
			   
		--	update_render_position(statuses)
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_onef = false
			   config_save(config.data)
			end
		end
	end
end
function famcheckerFunc()
	while true do wait(0)
		if pos_twof then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].families.x = curX
			config.data[mynick()].families.y = curY
			--update_render_position(families)
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_twof = false
			   config_save(config.data)
			end
		end

		if pos_onef then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].statuses.x = curX
			config.data[mynick()].statuses.y = curY
			--update_render_position(families)
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_onef = false
			   config_save(config.data)
			end
		end

		        if script_enabled[0] then
            if sampGetCurrentServerName():lower():find("evolve") then
                statuses:new()
                families:new()
    
                for i = 0, MAX_3DTEXTS do
                    if sampIs3dTextDefined(i) then
                        local string, color, pos_x, pos_y, pos_z, distance, ignore_walls, player_id, veh_id = sampGet3dTextInfoById(i)
                        if player_id and player_id ~= 65535 then
                            local pattern = "%[(%S+)%]%s*(.-)%s*Family?"
                            local symbol, family_name = string:match(pattern)
            
                            if symbol then
            
                                local user_type = statuses.list[symbol]
                                if user_type then
                                    user_type.count = user_type.count + 1
                                end
                            end
                            if family_name then
                                local family = families.list[family_name]
                                if family then
                                    family.count = family.count + 1
                                else
                                    families.list[family_name] = {name = family_name, count = 1}
                                end
                            end
                        end
                    end
                end
    
                statuses:process()
                families:process()
            end
        end
	end
end

function clickwarpFunc2()



    if config.data[mynick()] ~= nil and isKeyJustPressed(keyToggle) and config.data[mynick()].clickwarp.status  then
		ffi.C.SetCursorPos(sw/2, sh/(3/4))
      cursorEnabled = not cursorEnabled
      showCursor2(cursorEnabled)
    end

    if cursorEnabled then
      local mode = sampGetCursorMode()
      if mode == 0 then
        showCursor2(true)
      end
      local sx, sy = getCursorPos()
      local sw, sh = getScreenResolution()
      -- is cursor in game window bounds?
      if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
        local posX2, posY2, posZ2 = convertScreenCoordsToWorld3D(sx, sy, 700.0)
        local camX, camY, camZ = getActiveCameraCoordinates()
        -- search for the collision point
        local result23, colpoint = processLineOfSight(camX, camY, camZ, posX2, posY2, posZ2, true, true, false, true, false, false, false)
        if result23 and colpoint.entity ~= 0 then
          local normal = colpoint.normal
          local pos33 = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
           zOffset = 300
          if normal[3] >= 0.5 then zOffset = 1 end
          -- search for the ground position vertically down
          local result23, colpoint2 = processLineOfSight(pos33.x, pos33.y, pos33.z + zOffset, pos33.x, pos33.y, pos33.z - 0.3,
            true, true, false, true, false, false, false)
          if result23 then
            pos332 = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

            local curX2, curY2, curZ2  = getCharCoordinates(playerPed)
            local dist2              = getDistanceBetweenCoords3d(curX2, curY2, curZ2, pos332.x, pos332.y, pos332.z)
            local hoffs             = renderGetFontDrawHeight(font)
           if dist2 >= 20 then
  -- 1. Получаем координаты камеры и игрока
            local camX, camY, camZ = getActiveCameraCoordinates()
            local targetX, targetY, targetZ = getActiveCameraPointAt()
            local pX, pY, pZ = getCharCoordinates(PLAYER_PED)

            -- 2. Ищем точку коллизии (куда упирается взгляд)
            local result, hitX, hitY, hitZ = processLineOfSight(
                camX, camY, camZ, 
                targetX, targetY, targetZ, 
                true, true, true, true, true, false, false, false
            )

            local finalX, finalY, finalZ = targetX, targetY, targetZ
            if result then
                finalX, finalY, finalZ = hitX, hitY, hitZ
            end

            -- 3. Математическое ограничение дистанции в 20 метров
            local dx = finalX - pX
            local dy = finalY - pY
            local dz = finalZ - pZ
            local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

            if distance > 20.0 then
                local multiplier = 20.0 / distance
                finalX = pX + (dx * multiplier)
                finalY = pY + (dy * multiplier)
                finalZ = pZ + (dz * multiplier)
            end

            -- 4. Проверяем видимость точки на экране
            if isPointOnScreen(finalX, finalY, finalZ, 1.0) then
                local sx, sy = convert3DCoordsToScreen(finalX, finalY, finalZ)
                
                if sx and sy then
                    -- Принудительное приведение к целому числу (integer)
                    local posX = math.floor(sx)
                    local posY = math.floor(sy)

                    -- УДАЛЕНО: sampToggleCursor(true) больше не блокирует персонажа
                    
                    -- Двигаем системный курсор. Персонаж продолжает бежать!
                    ffi.C.SetCursorPos(posX, posY)
                end
            end
            end
            sy = sy - 2
            sx = sx - 2
            renderFontDrawText(clickwarpfont, string.format("%0.2fm", dist2), sx, sy - hoffs, 0xEEEEEEEE)

            local tpIntoCar = nil
            if colpoint.entityType == 2 then
              local car = getVehiclePointerHandle(colpoint.entity)
              if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                local color = 0xAAFFFFFF
                if isKeyDown(VK_RBUTTON) then
                  tpIntoCar = car
                  color = 0xFFFFFFFF
                end
                renderFontDrawText(clickwarpfont2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
              end
            end

            createPointMarker(pos332.x, pos332.y, pos332.z)

            -- teleport!
            if isKeyJustPressed(keyApply) and not isKeyJustPressed(VK_CTRL) then
              if tpIntoCar then
                if not jumpIntoCar(tpIntoCar) then
                  -- teleport to the car if there is no free seats
                 if dist2 <= 20 then teleportPlayer(pos332.x, pos332.y, pos332.z) end
                end
              else
                if isCharInAnyCar(playerPed) then
                  local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                  local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                  rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                  pos332 = pos332 - norm * 1.8
                  pos332.z = pos332.z - 0.8
                end
                if dist2 <= 20 then teleportPlayer(pos332.x, pos332.y, pos332.z) end
              end
              removePointMarker()


              showCursor2(false)
            elseif isKeyJustPressed(keyApply) and isKeyJustPressed(VK_CTRL) then
              pos332.z = select(3, getCharCoordinates(PLAYER_PED))
              if tpIntoCar then
                if not jumpIntoCar(tpIntoCar) then
                  -- teleport to the car if there is no free seats
                  if dist2 <= 20 then teleportPlayer(pos332.x, pos332.y, pos332.z) end
                end
              else
                if isCharInAnyCar(playerPed) then
                  local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                  local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                  rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                  pos332 = pos332 - norm * 1.8
                  pos332.z = pos332.z - 0.8
                end
                if dist2 <= 20 then teleportPlayer(pos332.x, pos332.y, pos332.z) end
              end
              removePointMarker()

              showCursor2(false)
            end
          end
        end
      end
    end
    wait(0)
    removePointMarker()

end
function onScriptTerminate(script, quitGame)
    if script == thisScript() then
        -- Restore exactly the bytes saved before installing native hooks.
        pcall(uninstallHooks)

        if keepAliveCallbacks[1] then
            pcall(function() keepAliveCallbacks[1]:free() end)
            keepAliveCallbacks[1] = nil
        end
        OrigGetWheelStatus = nil
        nativeHooksInstalled = false

        if status_hotkey and hotkey.uninitialize then
            pcall(hotkey.uninitialize)
        end
    end

    pcall(closeWs)
    pcall(clearMarker)
end

function uninstallHooks()
    if not ffi then
        return
    end

    local function restoreHook(addr)
        local bytes = nativeHookOriginalBytes[addr]
        if not bytes then return end

        pcall(function()
            local hookAddr = ffi.cast('void*', addr)
            local oldProtect = ffi.new('unsigned long[1]')
            if ffi.C.VirtualProtect(hookAddr, 5, 0x40, oldProtect) ~= 0 then
                ffi.copy(hookAddr, bytes, 5)
                ffi.C.VirtualProtect(hookAddr, 5, oldProtect[0], oldProtect)
            end
        end)
        nativeHookOriginalBytes[addr] = nil
    end

    restoreHook(0x6A55FE)
    restoreHook(0x6A5ACC)
    hook1, hook2 = nil, nil
    nativeHooksInstalled = false
end

--[[function clickwarpFunc()
	while true do wait(0)
	if config.data[mynick()] ~= nil and config.data[mynick()].clickwarp.status then
    if cursorEnabled then
     local mode = sampGetCursorMode()
     if mode == 0 then
        showCursor2(true)
      end
      local sx, sy = getCursorPos()
      local sw, sh = getScreenResolution()
      -- is cursor in game window bounds?
      if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
        local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
        local camX, camY, camZ = getActiveCameraCoordinates()
        -- search for the collision point
        local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
        if result and colpoint.entity ~= 0 then
          local normal = colpoint.normal
          local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
          local zOffset = 300
          if normal[3] >= 0.5 then zOffset = 1 end
          -- search for the ground position vertically down
          local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
            true, true, false, true, false, false, false)
          if result then

            
            pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

            local curX, curY, curZ  = getCharCoordinates(playerPed)
            local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
            local hoffs             = renderGetFontDrawHeight(font)
           if dist <= 20 then
              pov.x, pov.y  = getCursorPos()
              else
                ffi.C.SetCursorPos(pov.x, pov.y)
            end
            sy = sy - 2
            sx = sx - 2
            renderFontDrawText(clickwarpfont, string.format("%0.2f", dist), sx, sy - hoffs, 0xEEEEEEEE)

            local tpIntoCar = nil
            if colpoint.entityType == 2 then
              local car = getVehiclePointerHandle(colpoint.entity)
              if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                local color = 0xAAFFFFFF
                if isKeyDown(VK_RBUTTON) then
                  tpIntoCar = car
                  color = 0xFFFFFFFF
                end
                renderFontDrawText(clickwarpfont2, "Hold right mouse button to teleport into the car", sx, sy - hoffs * 3, color)
              end
            end

            --createPointMarker(pos.x, pos.y, pos.z)

            -- teleport!

          end
        end
      end
    end
    wait(0)
    removePointMarker()
end
end
end
]]

function initializeRender()
  clickwarpfont = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
  clickwarpfont2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
end

function rotateCarAroundUpAxis(car, vec)
  local mat = Matrix3X3(getVehicleRotationMatrix(car))
  local rotAxis = Vector3D(mat.up:get())
  vec:normalize()
  rotAxis:normalize()
  local theta = math.acos(rotAxis:dotProduct(vec))
  if theta ~= 0 then
    rotAxis:crossProduct(vec)
    rotAxis:normalize()
    rotAxis:zeroNearZero()
    mat = mat:rotate(rotAxis, -theta)
  end
  setVehicleRotationMatrix(car, mat:get())
end

function readFloatArray(ptr, idx)
  return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray(ptr, idx, value)
  writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function getVehicleRotationMatrix(car)
  local entityPtr = getCarPointer(car)
  if entityPtr ~= 0 then
    local mat = readMemory(entityPtr + 0x14, 4, false)
    if mat ~= 0 then
      local rx, ry, rz, fx, fy, fz, ux, uy, uz
      rx = readFloatArray(mat, 0)
      ry = readFloatArray(mat, 1)
      rz = readFloatArray(mat, 2)

      fx = readFloatArray(mat, 4)
      fy = readFloatArray(mat, 5)
      fz = readFloatArray(mat, 6)

      ux = readFloatArray(mat, 8)
      uy = readFloatArray(mat, 9)
      uz = readFloatArray(mat, 10)
      return rx, ry, rz, fx, fy, fz, ux, uy, uz
    end
  end
end

function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
  local entityPtr = getCarPointer(car)
  if entityPtr ~= 0 then
    local mat = readMemory(entityPtr + 0x14, 4, false)
    if mat ~= 0 then
      writeFloatArray(mat, 0, rx)
      writeFloatArray(mat, 1, ry)
      writeFloatArray(mat, 2, rz)

      writeFloatArray(mat, 4, fx)
      writeFloatArray(mat, 5, fy)
      writeFloatArray(mat, 6, fz)

      writeFloatArray(mat, 8, ux)
      writeFloatArray(mat, 9, uy)
      writeFloatArray(mat, 10, uz)
    end
  end
end

function displayVehicleName(x, y, gxt)
  x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
  useRenderCommands(true)
  setTextWrapx(640.0)
  setTextProportional(true)
  setTextJustify(false)
  setTextScale(0.33, 0.8)
  setTextDropshadow(0, 0, 0, 0, 0)
  setTextColour(255, 255, 255, 230)
  setTextEdge(1, 0, 0, 0, 100)
  setTextFont(1)
  displayText(x, y, gxt)
end

function createPointMarker(x, y, z)
  pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker()
  if pointMarker then
    removeUser3dMarker(pointMarker)
    pointMarker = nil
  end
end

function getCarFreeSeat(car)
  if doesCharExist(getDriverOfCar(car)) then
    local maxPassengers = getMaximumNumberOfPassengers(car)
    for i = 0, maxPassengers do
      if isCarPassengerSeatFree(car, i) then
        return i + 1
      end
    end
    return nil -- no free seats
  else
    return 0 -- driver seat
  end
end

function jumpIntoCar(car)
  local seat = getCarFreeSeat(car)
  if not seat then return false end                         -- no free seats
  if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
  else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
  end
  restoreCameraJumpcut()
  return true
end

function teleportPlayer(x, y, z)
  if isCharInAnyCar(playerPed) then
    setCharCoordinates(playerPed, x, y, z)
  end
  setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
  if doesCharExist(char) then
    local ptr = getCharPointer(char)
    setEntityCoordinates(ptr, x, y, z)
  end
end

function setEntityCoordinates(entityPtr, x, y, z)
  if entityPtr ~= 0 then
    local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
    if matrixPtr ~= 0 then
      local posPtr = matrixPtr + 0x30
      writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
      writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
      writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
    end
  end
end

--[[function showCursor2(toggle)
  if toggle then
    sampSetCursorMode(CMODE_LOCKCAM)
  else
    sampToggleCursor(false)
  end
  cursorEnabled = toggle
end]]


function FamCheckFunc()
	while true do wait(0)
		if fam_check then
			sampSendChat("/fpanel")
			wait(400)
		end
    end
end
 delete_cue_spawn_status = 1

function deletecueFunc()
    while true do wait(0)
        if sampIsLocalPlayerSpawned() and config.data[mynick()].delete_melee_weapon.status and authorization then
            if delete_cue_spawn_status ~= 0 and os.time() - delete_cue_spawn_status > 0 then
                repeat
                    wait(0)
                until os.clock() * 1000 - antiflood > 1000

                if hasCharGotWeapon(PLAYER_PED, 7) and config.data[mynick()].delete_melee_weapon.kiy then
                    removeWeaponFromChar(PLAYER_PED, 7)
                end

				if hasCharGotWeapon(PLAYER_PED, 1) and config.data[mynick()].delete_melee_weapon.knuckles then
                    removeWeaponFromChar(PLAYER_PED, 1)
                end
                if hasCharGotWeapon(PLAYER_PED, 5) and config.data[mynick()].delete_melee_weapon.bat then
                    removeWeaponFromChar(PLAYER_PED, 5)
                end
                if hasCharGotWeapon(PLAYER_PED, 2) and config.data[mynick()].delete_melee_weapon.stick then
                    removeWeaponFromChar(PLAYER_PED, 2)
                end

                if hasCharGotWeapon(PLAYER_PED, 8) and config.data[mynick()].delete_melee_weapon.katana then
                    removeWeaponFromChar(PLAYER_PED, 8)
                end
                delete_cue_spawn_status = 0 
            end
        end
    end
end

--[[function check_user()
	while true do wait(0)
		if check_users then
			wait(500)
			cheking_users("https://raw.githubusercontent.com/Mafizik/scripts/refs/heads/main/users.json")
			wait(500)
			list2 = {}
			for i = 1, #list.player do
				if list.authorization[i]:find("t") and sampIsPlayerConnected(sampGetPlayerIdByNickname(list.player[i]))then
					table.insert(list2, list.player[i])
				end    
			end
			check_users = false
		end
	end
end]]

--local base64 = require('base64')
--local json = require('dkjson')

--local table_url = 'https://api.github.com/repos/User653478/script/contents/users.json'
--local table_token = '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'
--[[local function updateFile(table_token, sha, newContent)
    local response = requests.put(table_url, {
        headers = {
            ["Authorization"] = "Bearer " .. table_token,
            ["X-GitHub-Api-Version"] = '2022-11-28',
            ["Accept"] = 'application/vnd.github+json'
        },
        data = json.encode({
            message = 'Add new text to the file',
            sha = sha,
            content = base64.encode(newContent)
        })
    })
    assert(response.status_code == 200, response.status_code .. '\n' .. response.text)
end
]]

--[[function add_user()
    my_nickname = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    date = os.date("%d.%m.%Y")
    time = os.date('%H:%M')
    if not check_table(mass.player, my_nickname) then
        mass.player[#mass.player + 1] = my_nickname
        mass.date[#mass.date + 1] = date
        mass.time[#mass.time + 1] = time
		if authorization then
			mass.authorization[number] = "true"
		else
			mass.authorization[number] = "false"
		end
        updateFile(table_token, sha, json.encode(mass))
    elseif check_table(mass.player, my_nickname) then
        number = index_number(mass.player, my_nickname)
        if number ~= -1 and mass.date[number] ~= date or number ~= -1 and mass.date[number] == date and time ~= mass.time[number] then
            mass.date[number] = date
            mass.time[number] = time
			if authorization then
			   mass.authorization[number] = "true"
			else
			   mass.authorization[number] = "false"
			end
            updateFile(table_token, sha, json.encode(mass))
        end
    end
end]]


function TruckFunc()
	while true do wait(0)
		if truck_flooder and not truck_choice and authorization then
			sampSendChat("/materials get")
			wait(800)
		elseif truck_flooder and truck_choice and authorization then
			sampSendChat("/bput")
			wait(800)
		end
	end
end

function TruckrFunc()
	while true do wait(0)
		--msg(sampGetObjectSampIdByHandle(sampGetObjectHandleBySampId(2358)))
		if doesObjectExist(sampGetObjectHandleBySampId(2358)) and config.data[mynick()].small_tweaks.truck and not truck_flooder then
		--	local mX, mY, mZ = getCharCoordinates(PLAYER_PED)
		--	local _, bX, bY, bZ = getObjectCoordinates(sampGetObjectHandleBySampId(2358))
		--	if getDistanceBetweenCoords3d(mX, mY, mZ, bX, bY, bZ) <= 3.5 then
			msg(("Введите /%s чтобы запустить автоматическое взятие/загрузку ящиков"):format(config.data[mynick()].small_tweaks.truck_command))
		    wait(60000)
		--	end
		end
	end
end

function check_folder(directory)
	local path = ("%s//%s"):format(getWorkingDirectory(), directory)
	if not doesDirectoryExist(path) then
		createDirectory(("%s//%s//%s"):format(getGameDirectory(), "moonloader", directory))--getWorkingDirectory
		thisScript():reload()
	end
end

function check_resource()
    if not doesDirectoryExist(getGameDirectory() .. "\\moonloader\\Palenation Tool Extended\\resource") then
      createDirectory(getGameDirectory() .. "\\moonloader\\Palenation Tool Extended\\resource")
    end
	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\marker.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/marker.png", "marker.png")
	end

    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\marker2.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/marker2.png", "marker2.png")
	end
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\matavoz.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/matavoz.png", "matavoz.png")
	end
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\pla.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/pla.png", "pla.png")
	end

    for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/"..i..".png", ""..i..".png")
	end
    end

        for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'k.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/"..i.."k.png", ""..i.."k.png")
	end
    end

    for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'d.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/"..i.."d.png", ""..i.."d.png")
	end
    end

            for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'c.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/"..i.."c.png", ""..i.."c.png")
	end
    end
	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\Russia.png') then
	    download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/Russia.png", "Russia.png")
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\English.png') then
		download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/English.png", "English.png")
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\discord.png') then
		download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/discord.png", "discord.png")
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\vk.png') then
		download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/vk.png", "vk.png")
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\paleriders.png') then
		download_resource("https://raw.githubusercontent.com/Mafizik/lib/refs/heads/main/paleriders.png", "paleriders.png")
	end
end
function check_resource2()
    if not doesDirectoryExist(getGameDirectory() .. "\\moonloader\\Palenation Tool Extended\\resource") then
      return false
    end
	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\marker.png') then
	    return false
	end

    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\marker2.png') then
	    return false
	end
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\matavoz.png') then
	    return false
	end
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\pla.png') then
	   return false
	end

    for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'.png') then
	    return false
	end
    end

        for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'k.png') then
	    return false
	end
    end

    for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'d.png') then
	    return false
	end
    end

            for i = 1, 16 do
    if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\'..i..'c.png') then
	   return false
	end
    end
	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\Russia.png') then
	    return false
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\English.png') and doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\Russia.png') then
		return false
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\discord.png') then
		return false
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\vk.png') then
		return false
	end

	if not doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\paleriders.png') then
		return false
	end
	return true
end

function OpenCarFunc()
	while true do wait(0)
		if config.data[mynick()] ~= nil and isKeyJustPressed(76) and config.data[mynick()].small_tweaks.car and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() and authorization then
			sampSendChat("/lock")
			wait(250)
		end
	end
end

function CollisionFunc()
	while true do wait(0)
		if config.data[mynick()] ~= nil and config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.collision and nawa_inta == 10 then
			for i = 0, sampGetMaxPlayerId(false) do
				if sampIsPlayerConnected(i) then
					local result, id = sampGetCharHandleBySampPlayerId(i)
					if result then
						if doesCharExist(id) then
							local x, y, z = getCharCoordinates(id)
							local mX, mY, mZ = getCharCoordinates(playerPed)
							if 1 > getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) then
								setCharCollision(id, false)
							end
						end
					end
				end
			end
		end
	end
end

function CollisionAllFunc()
	while true do wait(0)
		if config.data[mynick()] ~= nil and (status_collision_all[0] or config.data[mynick()].small_tweaks.collision_all) then
			for i = 0, sampGetMaxPlayerId(false) do
				if sampIsPlayerConnected(i) then
					 result, id = sampGetCharHandleBySampPlayerId(i)
					if result then
						if doesCharExist(id) then
							local x, y, z = getCharCoordinates(id)
							local mX, mY, mZ = getCharCoordinates(playerPed)
							if 1 > getDistanceBetweenCoords3d(x, y, z, mX, mY, mZ) then
								setCharCollision(id, false)
							end
						end
					end
				end
			end
		end
	end
end
function send_zaxod_one()
	while true do wait(0)
		repeat
	    wait(0)
		until os.clock() * 1000 - antiflood > 1000
		if welcome and zaxod and authorization and not fam_check then
			sampSendChat("/fc РєСѓ Р°Р»Р»")
			zaxod = false
		end
	end
end



function checkrankoff()
	while true do wait(0)
		if check_rank then wait(2600) check_rank = false end   
	end
end

function One()
	while true do wait(0)
        if help_notifications then wait(3000) help_notifications = false end
	end
end

function Two()
	while true do wait(0)
	    if helpeee then wait(3000) helpeee = false end
	end
end



function Four()
	while true do wait(0)
		if help_m4_net or help_ak_net or help_deagle_net then
			wait(1000)
		end
		if help_m4_net and not help_ak_net and not help_deagle_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на M4")
			help_m4_net = false
			wait(1000)
		end
		if help_ak_net and not help_m4_net and not help_deagle_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на AK47")
			help_ak_net = false
			wait(1000)
		end
		if help_deagle_net and not help_ak_net and not help_m4_netv then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 1 тыс. патронов на Desert Eagle")
			help_deagle_net = false
			wait(1000)
		end
		if help_deagle_net and help_ak_net and help_m4_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на Desert Eagle, M4, AK47")
			help_deagle_net = false
			help_ak_net = false
			help_m4_net = false
			wait(1000)
		end
		if help_deagle_net and help_ak_net and not help_m4_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на Desert Eagle, AK47")
			help_ak_net = false
			help_deagle_net = false
			wait(1000)
		end
		if help_deagle_net and help_m4_net and not help_ak_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на Desert Eagle, M4")
			help_m4_net = false
			help_deagle_net = false
			wait(1000)
		end
		if not help_deagle_net and help_ak_net and help_m4_net and authorization then
			sampSendChat("/fc ВНИМАНИЕ! В сейфе осталось меньше 3 тыс. патронов на M4, AK47")
			help_ak_net = false
			help_m4_net = false
			wait(1000)
		end
    end
end

function Five()
	while true do wait(0)
		if (config.data[mynick()].squad.status or config.data[mynick()].pr.family) and not check_rank and not bflooder and not mflooder and not flood and not truck_flooder and not check_rank then
			if not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() then
				repeat
					wait(0)
				until os.clock() * 1000 - antiflood > 1000
				sampSendChat("/fmembers")
				netfmem = true
			end
			wait(15000)
		end
	end
end
--------------------------------------------------------------------------------
-------------------------------------OnFrame------------------------------------
--------------------------------------------------------------------------------
--#MIMGUI #FRAME #ONDRAWDRAME #WINDOW
--удалитьлокал


window_function_1 = ""
window_function_6 = ""
window_function_8 = ""
window_function_9 = ""
window_function_gl = ""
window_web = ""
imgui.OnFrame(
    function() return Menu[0] end,
    function(player)
         res = imgui.ImVec2(getScreenResolution());
        imgui.SetNextWindowPos(imgui.ImVec2(res.x / 2, res.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(650, 610), imgui.Cond.FirstUseEver)
        imgui.Begin(fa["MOTORCYCLE"]..'  EVOLVE MULTITOOL SPECIAL FOR PALERIDERS NATION  '..fa["MOTORCYCLE"], Menu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)

        imgui.BeginChild('tabs2', imgui.ImVec2(200, -1), true)
        imgui.BeginChild('tabs', imgui.ImVec2(200, -1), false)
		--(config.data[mynick()].render.align == 1 and "По середине" or "К правому краю")
     --[[   if imgui.PageButton(page == 1, fa["USER"], (config.data[mynick()].language.number == 1 and 'Управление составом' or 'Squad management')) then
            page = 1
        end]]    
	--		if imgui.PageButton(page == 1, fa["USER"], (config.data[mynick()].language.number == 1 and 'Авторизация' or 'Authorization')) then
		--		page = 1
		--	end				
		if authorization then
			if imgui.PageButton(page == 1, fa["HOUSE"], (config.data[mynick()].language.number == 1 and 'Главное меню' or 'Menu')) then
				page = 1
			end		
			if imgui.PageButton(page == 2, fa["CAR_SIDE"], (config.data[mynick()].language.number == 1 and 'Транспорт' or 'Transport')) then
				page = 2
			end		
  				if imgui.PageButton(page == 3, fa["WAREHOUSE"], (config.data[mynick()].language.number == 1 and 'Склад и сейф' or 'Transport')) then
				page = 3
			end		
            
			if imgui.PageButton(page == 8, fa["SITEMAP"],  (config.data[mynick()].language.number == 1 and 'Мелкие твики' or 'Small tweaks')) then
				page = 8
			end
           	if imgui.PageButton(page == 67, fa["MINUS"], (config.data[mynick()].language.number == 1 and 'Рендер границ' or 'Border rendering')) then
                page = 67
            end  
			if imgui.PageButton(page == 9, fa["USER_GROUP"], (config.data[mynick()].language.number == 1 and 'Сквад' or "Squad")) then
				page = 9
			end



			if imgui.PageButton(page == 11, fa["TRIANGLE_EXCLAMATION"], (config.data[mynick()].language.number == 1 and 'Запрещенка' or "Danger")) then
				page = 11
			end

	--[[		if imgui.PageButton(page == 12, fa["ROBOT"], (config.data[mynick()].language.number == 1 and 'Ботоводство' or "Bot farming")) then
				page = 12
			end]]

			if imgui.PageButton(page == 14, fa["USER_SLASH"], (config.data[mynick()].language.number == 1 and 'Player Remover' or "Player Remover")) then
				page = 14
			end

			if imgui.PageButton(page == 15, fa["MAP"], (config.data[mynick()].language.number == 1 and 'Навигация' or "Navigation")) then
				page = 15
			end


			
	    end
	--	if imgui.PageButton(page == 10, fa["USER_TIE"], (config.data[mynick()].language.number == 1 and 'Пользователи онлайн' or "User list")) then
       --     page = 10
       -- end
        imgui.EndChild()
    --    if imgui.PageButton(page == 13, fa["FILE"], 'Лог обновлений') then
    --        page = 13
    --    end  
	
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild('workspace', imgui.ImVec2(-1, -1), true, imgui.WindowFlags.NoScrollbar)

        -- PALERIDERS watermark only inside the right workspace/settings area.
        -- It is drawn first, so all controls/text remain above it.
        if PaleridersBackground then
            local bgDrawList = imgui.GetWindowDrawList()
            local bgPos = imgui.GetWindowPos()
            local bgSize = imgui.GetWindowSize()
            local margin = 8

            -- Квадрат 1:1, строго по центру workspace.
            -- Берём меньшую сторону окна, чтобы изображение не растягивалось.
            local side = math.min(bgSize.x, bgSize.y) - margin * 2
            local bgX = bgPos.x + (bgSize.x - side) / 2
            local bgY = bgPos.y + (bgSize.y - side) / 2

            bgDrawList:AddImage(
                PaleridersBackground,
                imgui.ImVec2(bgX, bgY),
                imgui.ImVec2(bgX + side, bgY + side),
                imgui.ImVec2(0, 0),
                imgui.ImVec2(1, 1),
                0x26FFFFFF
            )
        end
          --[[
			if page == 1 then
                LeadersManagement()
            else
				]]
			if page == 1 then 
              --  users()		
			elseif page == 2 then
				if window_function_1 == "" then
				fastcar()	
				    imgui.ToggleButtonTextGear("Переворот авто", perevorot_status, function()
        config.data[mynick()].perevorot.status = not config.data[mynick()].perevorot.status
        config_save(config.data)
    end, true, function() window_function_1 = "perevorot" end)   
				    imgui.ToggleButtonTextGear("Drift Master", drift_status, function()
        config.data[mynick()].small_tweaks.driftmod_status = not config.data[mynick()].small_tweaks.driftmod_status
        config_save(config.data)
    end, true, function() window_function_1 = "drift" end)   
				    imgui.ToggleButtonTextGear("Показывать здоровье т/с", dlcar_status, function()
        config.data[mynick()].dlcar.status = not config.data[mynick()].dlcar.status
        config_save(config.data)
    end, true, function() window_function_1 = "heal" end)
	
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and 'Открывать/Закрывать транспорт на клавишу L' or "Open/Close vehicles the key L"), status_open_car, function()
		config.data[mynick()].small_tweaks.car = not config.data[mynick()].small_tweaks.car
		config_save(config.data)
	end, true, function() end)
				else
							 if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(390,20)) then
                                window_function_1 = ""
                            end
							imgui.Spacing()

					if window_function_1 == "fexit" then
    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Быстрый транспорт ФХ" or "Fast transport Family House"), status_fcar_fx, function()
        config.data[mynick()].fastcarfx.status = not config.data[mynick()].fastcarfx.status
        config_save(config.data)
    end, true, function() window_function_1 = "fexit" end)
	    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовыход из ФХ" or "Autoexit from house"), status_fcarexit_fx, function()
        config.data[mynick()].fastcarfx.status_exit = not config.data[mynick()].fastcarfx.status_exit
        config_save(config.data)
    end)

    if FastCarFXHotKey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].fastcarfx.key = FastCarFXHotKey:GetHotKey()
        config_save(config.data)
    end
end

	if window_function_1 == "gd" then
				imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Нормальная езда без колес" or "Good drive"), gd_status, function()
        config.data[mynick()].good_drive.status = not config.data[mynick()].good_drive.status
        config_save(config.data)
    end, true, function() end)
			imgui.InputTextWithHint("##Командаже2234", (config.data[mynick()].language.number == 1 and "Введите команду##22" or "Enter the command##42"), gdCom, sizeof(gdCom))
		if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить команду" or "Save command"), imgui.ImVec2(276,20)) then
			sampUnregisterChatCommand(config.data[mynick()].good_drive.cmd)
			config.data[mynick()].good_drive.cmd = str(gdCom)
			config.data[mynick()].good_drive.cmd = config.data[mynick()].good_drive.cmd:gsub("/","")
			config_save(config.data)
			gd_cmd_register()
		end
	end
	if window_function_1 == "perevorot" then
		perevorot()
	end

	if window_function_1 == "drift" then
		driftmod()
	end

		if window_function_1 == "heal" then
		dlcar()
	end
				end
			elseif page == 3 then
				sklad_and_safe()
            elseif page == 67 then
				render_granica()
            elseif page == 8 then
                SmallTweaks()
			elseif page == 9 then
				squad_text()
			elseif page == 11 then	
				cheatting()
			elseif page == 12 then	
			--	render_botovodcto()

			elseif page == 14 then	
				prmenu()

			elseif page == 15 then	
				web_socket()
            end

			if  page == 1 then


					if window_function_gl ~= "" then
						if imgui.Button("Назад##multi.menu_func2", imgui.ImVec2(410,20)) then
                            window_function_gl = ""
                        end
						imgui.Spacing()
			        end
				if window_function_gl == "" then
					if imgui.Button("Конфликтующие скрипты", imgui.ImVec2(410,30)) then
                        window_function_gl = "konflikt"
                    end

				imgui.SetCursorPos(imgui.ImVec2(0, 550))
				if imgui.IconButton(English_Flag, imgui.ImVec2(35, 17)) then
					config.data[mynick()].language.number = 2
					config_save(config.data)
				end
	
				imgui.SetCursorPos(imgui.ImVec2(40, 550))
				if imgui.IconButton(Russian_Flag, imgui.ImVec2(35, 17)) then
					config.data[mynick()].language.number = 1
					config_save(config.data)
				end
				if config.data[mynick()] ~= nil and config.data[mynick()].language.number == 1 then
					lafa = imgui.ImVec2(225, 530)
					imgui.SetCursorPos(lafa)
					imgui.Text((config.data[mynick()].language.number == 1 and "Разработчик: mafizik" or "Developer: mafizik"))
					imgui.SetCursorPos(imgui.ImVec2(225, 530 + 18))
					imgui.Text((config.data[mynick()].language.number == 1 and "Идейный автор: Сергей Метцен" or "Author: Sergey Metzen"))
				else
					lafa = imgui.ImVec2(285, 530)
					imgui.SetCursorPos(lafa)
					imgui.Text((config.data[mynick()].language.number == 1 and "Разработчик: mafizik" or "Developer: mafizik"))
					imgui.SetCursorPos(imgui.ImVec2(285, 530 + 18))
					imgui.Text((config.data[mynick()].language.number == 1 and "Идейный автор: Сергей Метцен" or "Author: Sergey Metzen"))
				end

				imgui.SetCursorPos(imgui.ImVec2(82, 550))
					if imgui.Text(fa["GEAR"], imgui.ImVec2(50, 70)) then
					config.data[mynick()].language.number = 1
					config_save(config.data)
				end
								if imgui.IsItemClicked() then
    window_function_gl = "sett"
end
				imgui.SetCursorPos(imgui.ImVec2(100, 550))
				if imgui.Text(fa["USER_GROUP"], imgui.ImVec2(50, 70)) then
				end

				if imgui.IsItemClicked() then
    window_function_gl = "users"
end

imgui.SetCursorPos(imgui.ImVec2(122, 548))
				if imgui.IconButton(DS, imgui.ImVec2(20, 20)) then
					os.execute("start \"\" \"https://discord.gg/p4NjpT77Ga\"")
				end
				imgui.Question("Вступить в дискорд")
imgui.SetCursorPos(imgui.ImVec2(147, 548))
				if imgui.IconButton(VK, imgui.ImVec2(20, 20)) then
					os.execute("start \"\" \"https://vk.ru/paleridersmc_erp\"")
				end
				imgui.Question("Паблик в ВК")
			elseif window_function_gl == "users" then
				users_draw()

			elseif window_function_gl == "sett" then
				settings_menu()

			elseif window_function_gl == "konflikt" then
				imgui.Text(("Список скриптов, конфликтующих с модулями мультитула:\n" ..
"1. Player Remover Menu или иной скрипт, удаляющий игроков.\n" ..
"2. Mafia/Biker рендеры линий границ.\n" ..
"3. АнтиАФК (либо выключайте встроенный модуль в мультитуле)"))

			end

			end
				--imgui.Text((config.data[mynick()].language.number == 1 and "Идейный автор: Сергей Метцен" or "Ideological author: Сергей Метцен"))
			--imgui.Text((config.data[mynick()].language.number == 1 and "Разработчик: mafizik" or "Developer: mafizik"))
        imgui.EndChild()
    
        imgui.End()
    end
)

function web_socket()
	
	if window_web == "" then
							imgui.ToggleButtonTextGear("Маркер", marker_status, function()
                        config.data[mynick()].marker.status = not config.data[mynick()].marker.status
                        config_save(config.data)
						    if not WSstatus and config.data[mynick()].marker.status then
                                markerWsCommand()
							elseif WSstatus and not config.data[mynick()].glonass.status and not config.data[mynick()].marker.status then
								markerWsCommand()
                            end    
                    end, true, function() window_web = "marker" end)    
					imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"],"Ставит маркер на карте для всех пользователей скрипта.")

					imgui.ToggleButtonTextGear("Мини-карта", webglonass, function()
                        config.data[mynick()].glonass.status = not config.data[mynick()].glonass.status
                        config_save(config.data)
						    if not WSstatus and config.data[mynick()].glonass.status then
                                markerWsCommand()
							elseif WSstatus and not config.data[mynick()].glonass.status and not config.data[mynick()].marker.status then
								markerWsCommand()
                            end  
                    end, true, function() window_web = "glonass" end)  
					imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"], 'Выводит на экран мини-карту со всеми пользователями скрипта.')
	else
							if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(390,20)) then
                                window_web= ""
                            end
							imgui.Spacing()
	end

	if window_web == "glonass" then
		glonass()
	end
	if window_web == "marker" then
		    imgui.ToggleButtonText("Маркер", marker_status, function()
        config.data[mynick()].marker.status = not config.data[mynick()].marker.status
        config_save(config.data)
								    if not WSstatus and config.data[mynick()].marker.status then
                                markerWsCommand()
							elseif WSstatus and not config.data[mynick()].glonass.status and not config.data[mynick()].marker.status then
								markerWsCommand()
                            end  
    end, true, function() window_function = "marker" end)   
	imgui.Spacing()
    if marker_hotkey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].marker.key = marker_hotkey:GetHotKey()
        config_save(config.data)
    end
	end
end

function prmenu()
	    imgui.ToggleButtonText("Player Remover", pr_status, function()
        config.data[mynick()].pr.status = not config.data[mynick()].pr.status
        config_save(config.data)
    end, true, function() end)   
		    imgui.ToggleButtonText("Оставить маркер на радаре", pr_marker, function()
        config.data[mynick()].pr.marker = not config.data[mynick()].pr.marker
        config_save(config.data)
    end, true, function() end)   
    imgui.ToggleButtonText("Френдлист по скваду", pr_family, function()
        config.data[mynick()].pr.family = not config.data[mynick()].pr.family
        config_save(config.data)
    end, true, function() end)   
	imgui.Spacing()
	imgui.Spacing()


						--imgui.PopFont()
					--	imgui.Dummy(imgui.ImVec2(0, 1))
						imgui.Columns(3, "fractions_columns", false)
	    imgui.ToggleButtonTextGear2("{009F00}Grove", grove2, function()
        config.data[mynick()].pr.grove = not config.data[mynick()].pr.grove
        config_save(config.data)
		update_fraction()
    end, true, function() end)   
	

	
	    imgui.ToggleButtonTextGear2("{FFDE24}Vagos", vagos2, function()
        config.data[mynick()].pr.vagos = not config.data[mynick()].pr.vagos
        config_save(config.data)
		update_fraction()
    end, true, function() end)   


	    imgui.ToggleButtonTextGear2("{B313E7}Ballas", ballac2, function()
        config.data[mynick()].pr.ballac = not config.data[mynick()].pr.balla
        config_save(config.data)
		update_fraction()
    end, true, function() end)   


	    imgui.ToggleButtonTextGear2("{2EA07B}Rifa", rifa2, function()
        config.data[mynick()].pr.rifa = not config.data[mynick()].pr.rifa
        config_save(config.data)
		update_fraction()
    end, true, function() end)   

	    imgui.ToggleButtonTextGear2("{01FCFF}Aztec", aztec2, function()
        config.data[mynick()].pr.aztec = not config.data[mynick()].pr.aztec
        config_save(config.data)
		update_fraction()
    end, true, function() end)   
						imgui.NextColumn()
						imgui.ToggleButtonTextGear2("{DDA701}LCN", lcn2, function()
        config.data[mynick()].pr.lcn = not config.data[mynick()].pr.lcn
        config_save(config.data)
		update_fraction()
    end, true, function() end) 

						imgui.ToggleButtonTextGear2("{B4B5B7}RM", rm2, function()
        config.data[mynick()].pr.rm = not config.data[mynick()].pr.rm
        config_save(config.data)
		update_fraction()
    end, true, function() end) 

						imgui.ToggleButtonTextGear2("{FF0000}Yakuza", yakudza2, function()
        config.data[mynick()].pr.yakudza = not config.data[mynick()].pr.yakudza
        config_save(config.data)
		update_fraction()
    end, true, function() end) 
								imgui.ToggleButtonTextGear2("{FFFFFF}Bomj", bich2, function()
        config.data[mynick()].pr.bich = not config.data[mynick()].pr.bich
        config_save(config.data)
		update_fraction()
    end, true, function() end) 
						imgui.NextColumn()



	
							imgui.ToggleButtonTextGear2("{333333}Mongols", mongols2, function()
        config.data[mynick()].pr.mongols = not config.data[mynick()].pr.mongols
        config_save(config.data)
		update_fraction()
    end, true, function() end) 
							imgui.ToggleButtonTextGear2("{2C9197}Pagans", pagans2, function()
        config.data[mynick()].pr.pagans = not config.data[mynick()].pr.pagans
        config_save(config.data)
		update_fraction()
    end, true, function() end) 
							imgui.ToggleButtonTextGear2("{F45000}Warlocks", warlocks2, function()
        config.data[mynick()].pr.warlocks = not config.data[mynick()].pr.warlocks
        config_save(config.data)
		update_fraction()
    end, true, function() end) 
end
--[[
				lomkaFunc()
                skillFunc()	
                FullCycleFunc()	
                ckylfunc()
]]
function settings_menu()
	-- Актуализируем оба списка профилей без перезапуска скрипта.
	refreshSettingsProfileCombos(false)
	imgui.PushItemWidth(200)
	if imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Дефолт настройки" or "Default settings")), int_settings, combo_settings, #combosettings) then
		config.data["Default_nickname"].settings.nickname = combosettings[int_settings[0] + 1]
		config_save(config.data)
	end
	imgui.PopItemWidth()
		imgui.SameLine()
		imgui.TextQuestion(fa["CIRCLE_QUESTION"], (config.data[mynick()].language.number == 1 and "Выбранный ник станет главным. \nЕго настройки будут автоматически применяться ко всем \nновым аккаунтам при первом заходе." or 'The selected nickname will become the main one. \nIts settings will be automatically applied to all \nnew accounts upon first login.'))
	
	imgui.PushItemWidth(200)
	imgui.Spacing()
	imgui.Combo(u8((config.data[mynick()].language.number == 1 and "##44" or "#52")), int_settings2, combo_settings2, #combosettings2) 
	imgui.SameLine()
	if imgui.Button("Удалить настройки", imgui.ImVec2(150, 20)) then
        local selectedNick = combosettings2[int_settings2[0] + 1]
        local currentNick = normalizeProfileNick(mynick())

        if selectedNick and selectedNick ~= "" and currentNick and currentNick ~= "" then
            selectedNick = normalizeProfileNick(selectedNick)

            if selectedNick ~= currentNick then
                -- Другой аккаунт: полностью удаляем его профиль из памяти и файла.
                config.data[selectedNick] = nil
                config_save(config.data, false, { selectedNick })

                -- Сразу перечитываем список, чтобы удалённый ник исчез из Combo.
                refreshSettingsProfileCombos(true)
            else
                -- Текущий аккаунт: профиль оставляем, но ВСЕ его настройки
                -- заменяем независимой копией базового профиля.
                config.data[currentNick] = deepCopy(config.data["Default"])
                config_save(config.data)

                -- Перезапуск нужен, чтобы обновились все уже созданные runtime/UI
                -- значения (hotkey, font, int/bool и т.п.), а не только JSON.
				msg("Настройки сброшены, выполянется перезагрузка скрипта")
                thisScript():reload()
            end
        end
	end

	imgui.Spacing()
	imgui.Spacing()
			    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Режим откатов" or "Режим откатов"), status_otkat, function()
        config.data[mynick()].small_tweaks.otkat = not config.data[mynick()].small_tweaks.otkat
        config_save(config.data)
    end, true, function() end)
		imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Скрывает сообщения ботов скрипта: autoreport, wl pale")
end

--[[function render_botovodcto()
    local sizeX = imgui.GetWindowWidth() / 4 - 10

    if b_border_tab[0] == 2 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end


	if b_border_tab[0] == 0 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end
	if imgui.PageButton2(b_border_tab[0] == 0, _, "Полный цикл", sizeX, 25) then
		b_border_tab[0] = 0
	end


	imgui.SameLine()
	if imgui.PageButton2(b_border_tab[0] == 1, _, "Бот ломка", sizeX, 25) then
		b_border_tab[0] = 1
	end

    imgui.SameLine()

    if b_border_tab[0] == 1 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end


	if imgui.PageButton2(b_border_tab[0] == 2, _, "Бот скиллы", sizeX, 25) then
		b_border_tab[0] = 2
	end

	imgui.SameLine()



    if b_border_tab[0] == 3 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end


	if imgui.PageButton2(b_border_tab[0] == 3, _, "Другое", sizeX, 25) then
		b_border_tab[0] = 3
	end

    imgui.Separator()
    imgui.Spacing()
	imgui.Spacing()
    if b_border_tab[0] == 0 then
        FullCycleFunc()	
	elseif b_border_tab[0] == 1 then
        lomkaFunc()
	elseif b_border_tab[0] == 2 then
		skillFunc()
	elseif b_border_tab[0] == 3 then
		ckylfunc()
    end
end]]
function render_granica()
	   local sizeX = imgui.GetWindowWidth() / 2 - 12

    if border_tab[0] == 1 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end
	if imgui.PageButton2(border_tab[0] == 1, _, "Байкеры", sizeX, 25) then
		 border_tab[0] = 1
	end
   --[[if imgui.Button(u8("Байкеры"), imgui.ImVec2(sizeX, 25)) then
        border_tab[0] = 1
    end]]
    imgui.SameLine()
    if border_tab[0] == 0 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
	end

	if imgui.PageButton2(border_tab[0] == 0, _, "Мафии", sizeX, 25) then
		 border_tab[0] = 0
	end








    imgui.Separator()
    imgui.Spacing()

    if border_tab[0] == 0 then
        mlines()
    else
        blines()
    end
end

function flooder_and_autocapture()
	   local sizeX = imgui.GetWindowWidth() / 2 - 12

    if flooder_and_capture_tab[0] == 0 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
	end

	if imgui.PageButton2(flooder_and_capture_tab[0] == 0, _, "Автокапт", sizeX, 25) then
		 flooder_and_capture_tab[0] = 0
	end




    imgui.SameLine()

    if flooder_and_capture_tab[0] == 1 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end
	if imgui.PageButton2(flooder_and_capture_tab[0] == 1, _, "Флудер", sizeX, 25) then
		 flooder_and_capture_tab[0] = 1
	end
   --[[if imgui.Button(u8("Байкеры"), imgui.ImVec2(sizeX, 25)) then
        border_tab[0] = 1
    end]]

    imgui.Separator()
    imgui.Spacing()

    if flooder_and_capture_tab[0] == 0 then
        autocapterka()
    else
        flooderc()
    end
end

function sklad_and_safe()
	   local sizeX = imgui.GetWindowWidth() / 2 - 12

    if flooder_and_capture_tab[0] == 0 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
	end

	if imgui.PageButton2(flooder_and_capture_tab[0] == 0, _, "Склад", sizeX, 25) then
		 flooder_and_capture_tab[0] = 0
	end




    imgui.SameLine()

    if flooder_and_capture_tab[0] == 1 then
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.35,0.35,0.35,1))
    end
	if imgui.PageButton2(flooder_and_capture_tab[0] == 1, _, "Сейф", sizeX, 25) then
		 flooder_and_capture_tab[0] = 1
	end
   --[[if imgui.Button(u8("Байкеры"), imgui.ImVec2(sizeX, 25)) then
        border_tab[0] = 1
    end]]

    imgui.Separator()
    imgui.Spacing()
    if flooder_and_capture_tab[0] == 0 then
       getgun()
    else
        LeadersManagement()
        fastsafe()
    end
end

function autocapterka()
	if imgui.InputTextWithHint("Для байкеров/банд##Командаже33", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), bcaptCom, sizeof(bcaptCom)) then
			sampUnregisterChatCommand(config.data[mynick()].AutoCapt.bautocapt)
			config.data[mynick()].AutoCapt.bautocapt = str(bcaptCom)
			config.data[mynick()].AutoCapt.bautocapt = config.data[mynick()].AutoCapt.bautocapt:gsub("/","")
			config_save(config.data)
			bcapture_cmd_register()
	end
	if imgui.InputTextWithHint("Для мафии##Командаже223", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), mcaptCom, sizeof(mcaptCom)) then
			sampUnregisterChatCommand(config.data[mynick()].Autocapt.mautocapt)
			config.data[mynick()].AutoCapt.mautocapt = str(mcaptCom)
			config.data[mynick()].AutoCapt.mautocapt = config.data[mynick()].AutoCapt.mautocapt:gsub("/","")
			config_save(config.data)
			mcapture_cmd_register()
	end

	--    AutoCapterWait = imgui.new.char[256](u8(config.data[mynick()].AutoCapt.wait))
	if imgui.SliderInt("Задержка", AutoCapterWait, 100, 1300) then
        config.data[mynick()].AutoCapt.wait = AutoCapterWait[0]
        config_save(config.data)
    end
end

function bcapture_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].AutoCapt.bautocapt) then
        sampUnregisterChatCommand(config.data[mynick()].AutoCapt.bautocapt)
    end

	sampRegisterChatCommand(config.data[mynick()].AutoCapt.bautocapt, function()
		bflooder = not bflooder
		if bflooder then msg((config.data[mynick()].language.number == 1 and 'Автокаптер запущен.' or "The flooder is running.")) end
		if not bflooder then  msg((config.data[mynick()].language.number == 1 and 'Автокаптер остановлен.' or 'Flooder has stopped.')) return end
		bflood()
	end)
end

function bflood()
	lua_thread.create(function()
		while bflooder do
			sampSendChat("/capture")
			wait(config.data[mynick()].AutoCapt.wait)
		end
	end)
end

function mcapture_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].AutoCapt.mautocapt) then
        sampUnregisterChatCommand(config.data[mynick()].AutoCapt.mautocapt)
    end

	sampRegisterChatCommand(config.data[mynick()].AutoCapt.mautocapt, function(arg)
		if #arg == 0 or not arg:find('(%d+)') then return msg((config.data[mynick()].language.number == 1 and 'Ошибка, используйте: /'..config.data[mynick()].AutoCapt.mautocapt..' [id]' or 'Error, use: /mcapture [id]')) end
		mflooder = not mflooder
		if mflooder then msg((config.data[mynick()].language.number == 1 and 'Автокаптер запущен.' or "The flooder is running.")) end
		if not mflooder then  msg((config.data[mynick()].language.number == 1 and 'Автокаптер остановлен.' or 'Flooder has stopped.')) return end
		cekkond = arg:match("(%d+)")
		mflood(cekkond)
	end)
end
--[[
	sampRegisterChatCommand(config.data[mynick()].AutoCapt.flooder_com, function(arg)
		if config.data[mynick()] ~= nil and config.data[mynick()].AutoCapt.flooder_status then
		if not flood then msg((config.data[mynick()].language.number == 1 and 'Флудер запущен.' or "The flooder is running.")) end
		if flood then flood = false msg((config.data[mynick()].language.number == 1 and 'Флудер остановлен.' or 'Flooder has stopped.')) return end
		if #arg == 0 or not arg:find('(%d+)') then return msg((config.data[mynick()].language.number == 1 and 'Ошибка, используйте: /flood [sec] [text]' or 'Error, use: /flood [sec] [text]')) end
		local sec, text = arg:match('^(.-) (.+)')
		if #text == 0 or not tonumber(sec) then return msg((config.data[mynick()].language.number == 1 and 'Ошибка, используйте: /flood [sec] [text]' or 'Error, use: /flood [sec] [text]')) end
		flooder(tonumber(sec), text)
		end
	end)]]
function mflood(arg)
	lua_thread.create(function()
		while mflooder do
			sampSendChat("/mafiawar "..arg)
			wait(config.data[mynick()].AutoCapt.wait)
		end
	end)
end

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------TEXT IN WINDOW----------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--[[avt_pass = imgui.new.char[256](u8(config.data[mynick()].user.key))
function users()
	windowSizeX, windowSizeY = 650, 600
	imgui.Text((authorization and (config.data[mynick()].language.number == 1 and "Связь с сервером установлена" or "Connection to the server established") or (config.data[mynick()].language.number == 1 and "Связь с сервером не установлена" or "Connection to the server not established")))
	imgui.Spacing()
	imgui.Spacing()
	imgui.PushItemWidth(300)
	imgui.InputText( (config.data[mynick()].language.number == 1 and "Ключ доступа" or "Access key"), avt_pass, sizeof(avt_pass), imgui.InputTextFlags.Password)
	imgui.PopItemWidth()
	--imgui.Spacing()
	if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить ключ" or "Save key"), imgui.ImVec2(300,25)) then
		config.data[mynick()].user.key = str(avt_pass)
		config_save(config.data)
	--	check_key()
	end
end]]


function check_key()
	authorization = true
end



function users_list()
	imgui.SetCursorPos(imgui.ImVec2(10, 535))
	if imgui.Button("Обновить", imgui.ImVec2(405, 20)) then
		check_users = true
	end

	for k, v in pairs(list2) do
		
		imgui.SetCursorPos(imgui.ImVec2(10, k * 18 - 10))
		imgui.Text(""..v)
	end
	--[[imgui.NextColumn()
	imgui.CenterColumnText(u8'неавторизованные') imgui.SameLine() imgui.CenterColumnText(u8'\nпользователи онлайн') imgui.SetColumnWidth(3, 100) 
	imgui.NextColumn()
	imgui.Columns(2) 
	list2 = {}
	list3 = {}
	for i = 1, #list.player do
		if list.authorization[i]:find("t") then
			table.insert(list2, list.player[i])
		end   
		if list.authorization[i]:find("f") then
			table.insert(list3, list.player[i])
		end   
	end
	if #list2 > #list3 then
		for i = 1, #list3 do
			imgui.Separator()
			imgui.CenterColumnText(list2[i])
			imgui.NextColumn()
			imgui.CenterColumnText(list3[i])
			imgui.NextColumn()
		end
		for k = tonumber(#list3 + 1), #list2 do
			imgui.Separator()
			imgui.CenterColumnText(list2[k])
		
			imgui.NextColumn()
			imgui.CenterColumnText("")
			imgui.NextColumn()
		end
	end

	if #list3 > #list2 then
		for i = 1, #list2 do
			imgui.Separator()
			imgui.CenterColumnText(list2[i])
			imgui.NextColumn()
			imgui.CenterColumnText(list3[i])
			imgui.NextColumn()
		end

		for k = tonumber(#list2 + 1), #list3 do
			imgui.Separator()
			imgui.CenterColumnText(list3[k])
			imgui.NextColumn()
			imgui.CenterColumnText(" ")
			imgui.NextColumn()
		end
	end

	if #list3 == #list2 then
		for i = 1, #list2 do
			imgui.Separator()
			imgui.CenterColumnText(list2[i])
			imgui.NextColumn()
			imgui.CenterColumnText(list3[i])
			imgui.NextColumn()
		end
	end
	imgui.Columns(1)
	imgui.Separator()
	]]
end
		--[[if (list.authorization[i] == "true" or list.authorization[i] == "false") and sampIsPlayerConnected(sampGetPlayerIdByNickname(list.player[i]))then
		   imgui.Separator()
		end   
		if list.authorization[i] == "true" and sampIsPlayerConnected(sampGetPlayerIdByNickname(list.player[i])) then
			imgui.CenterColumnText(list.player[i])
			imgui.NextColumn()
		end   
		if list.authorization[i] == "false" and sampIsPlayerConnected(sampGetPlayerIdByNickname(list.player[i])) then
			imgui.CenterColumnText(list.player[i])
			imgui.NextColumn()
		end   ]]
function squad_text()
    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображние участников сквада" or "Displaying squad members"), status_sm, function()
		config.data[mynick()].squad.status = not config.data[mynick()].squad.status
		config_save(config.data)
	end, true, function() end)
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображение зашедших/вышедших игроков в чате" or "Displaying entered/exited players in chat"), status_players, function()
		config.data[mynick()].squad.players = not config.data[mynick()].squad.players
		config_save(config.data)
	end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображние онлайна сквада" or "Online squad display"), status_squad_online, function()
		config.data[mynick()].squad.online_status = not config.data[mynick()].squad.online_status
		config_save(config.data)
	end, true, function() end)

	if config.data[mynick()] ~= nil and config.data[mynick()].squad.online_status or status_squad_online[0] then
		local squad_raskladka = (config.data[mynick()].squad.language == 0 and (config.data[mynick()].language.number == 1 and "Английский" or "English") or (config.data[mynick()].language.number == 1 and "Русский" or "Russian"))
		if imgui.Button((config.data[mynick()].language.number == 1 and "Текст рендера онлайна: "..squad_raskladka.."##multi.online.squad" or "Online render text: "..squad_raskladka.."##multi.online.squad"), imgui.ImVec2(390,20)) then
			config.data[mynick()].squad.language = config.data[mynick()].squad.language + 1
			if config.data[mynick()] ~= nil and config.data[mynick()].squad.language >= 2 then
				config.data[mynick()].squad.language = 0
			end
			config_save(config.data)
		end
	end

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию" or "Change position"), imgui.ImVec2(390,20)) then pos_squad = true end

	imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Цвет" or "Color")), int_squad, combo_squad, #combosquad)
	if config.data[mynick()] ~= nil and config.data[mynick()].squad.int == 3 or int_squad[0] == 3 then if imgui.ColorEdit4((config.data[mynick()].language.number == 1 and "Цвет ников" or "Nickname color"), castom_color_squad) then config.data[mynick()].squad.color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(castom_color_squad[0], castom_color_squad[1], castom_color_squad[2], castom_color_squad[3])) config_save(config.data) end end
	imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Надпись сверху" or "Inscription on top")), int_namesq, squad_combo, #squadcombo)
	imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Сортировка игроков" or "Sorting players")), int_squad2, combo_squad2, #combosquad2)
	if imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Шрифт" or "Font")), int_cq, combo_cq, #combocq) then
		config.data[mynick()].squad.intfont = int_cq[0]
		if int_cq[0] < 3 then
			config.data[mynick()].squad.font = combocq[int_cq[0] + 1]
		end
		config_save(config.data)
		sfont_sfont = imgui.new.char[256](u8(config.data[mynick()].squad.font))
	end
    if config.data[mynick()] ~= nil and config.data[mynick()].squad.intfont == 3 then imgui.InputText((config.data[mynick()].language.number == 1 and "Название шрифта" or "Font name"), sfont_sfont, sizeof(sfont_sfont)) end
    imgui.InputText((config.data[mynick()].language.number == 1 and "Размер шрифта" or "Font size"), sfont_ssize, sizeof(sfont_ssize))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Стиль шрифта" or "Font style"), sfont_flag, sizeof(sfont_flag))
	
	if imgui.Button((config.data[mynick()].language.number == 1 and "Сбросить настройки##m" or "Reset settings##m"), imgui.ImVec2(390,25)) then
		int_squad[0] = 2
		int_namesq[0] = 1
		int_squad2[0] = 0
		 sfont_sfont = imgui.new.char[256](u8("Arial"))
         sfont_ssize = imgui.new.char[256](u8(12))
         sfont_flag = imgui.new.char[256](u8(13))
		status_squad_online[0] = false
		config.data[mynick()].squad.x_pos = PosSquadX
		config.data[mynick()].squad.y_pos = PosSquadY
		config.data[mynick()].squad.font = 'Arial'
		config.data[mynick()].squad.size = 12
        config.data[mynick()].squad.flag = 13
		config.data[mynick()].squad.online_status = false
		config.data[mynick()].squad.int = 2
		config.data[mynick()].squad.rank = 0
		config.data[mynick()].squad.name_squad = 1
		config.data[mynick()].squad.color = 4294967295
		config.data[mynick()].squad.language = 0
		config_save(config.data)
		renderReleaseFont(squad_font)
		squad_font = renderCreateFont(config.data[mynick()].squad.font, config.data[mynick()].squad.size, config.data[mynick()].squad.flag)
    end

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##multi.squad.save" or "Save##multi.squad.save"), imgui.ImVec2(390,25)) then
		config.data[mynick()].squad.name_squad = int_namesq[0]
		config.data[mynick()].squad.rank = int_squad2[0]
		config.data[mynick()].squad.int = int_squad[0]
		config.data[mynick()].squad.font = str(sfont_sfont)
		config.data[mynick()].squad.size = tonumber(str(sfont_ssize))
		config.data[mynick()].squad.flag = tonumber(str(sfont_flag))
		config_save(config.data)
		renderReleaseFont(squad_font)
		squad_font = renderCreateFont(config.data[mynick()].squad.font, config.data[mynick()].squad.size, config.data[mynick()].squad.flag)
    end

end

function narkotimer()
    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Наркотаймер" or "Drugtimer"), status_drug_timer, function()
		config.data[mynick()].drugtimer.status = not config.data[mynick()].drugtimer.status
		config_save(config.data)
    end, true, function() end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Юзать нарко после смерти" or "Use drugs after death"), death_drug_timer, function()
        config.data[mynick()].drugtimer.death = not config.data[mynick()].drugtimer.death
        config_save(config.data)
    end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автонарко при >= 30 hp" or "Autodrugs at >= 30 hp"), autodrugStatus, function()
		config.data[mynick()].AutoCapt.autodrug = not config.data[mynick()].AutoCapt.autodrug
		config_save(config.data)
	end, true, function() end)

    if DrugHotKey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].drugtimer.key = DrugHotKey:GetHotKey()
        config_save(config.data)
    end

    if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию таймера" or "Change timer position"), imgui.ImVec2(390,20)) then pos = true end

    imgui.InputText((config.data[mynick()].language.number == 1 and "Текст без таймера" or "Text without timer"), nark_lines_one, sizeof(nark_lines_one))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Текст с таймером" or "Text with timer"), nark_lines_two, sizeof(nark_lines_two))
	if imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Шрифт" or "Font")), int_narkow, combo_narkow, #combonarkow) then
		config.data[mynick()].drugtimer.int = int_narkow[0]
		if int_narkow[0] < 4 then
			config.data[mynick()].render.font = combonarkow[int_narkow[0] + 1]
		end
		config_save(config.data)
		nark_font_font = imgui.new.char[256](u8(config.data[mynick()].render.font))
	end
    if config.data[mynick()] ~= nil and config.data[mynick()].drugtimer.int == 4 then imgui.InputText((config.data[mynick()].language.number == 1 and "Название шрифта" or "Font name"), nark_font_font, sizeof(nark_font_font)) end
    imgui.InputText((config.data[mynick()].language.number == 1 and "Размер шрифта" or "Font size"), nark_font_size, sizeof(nark_font_size))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Стиль шрифта" or "Font style"), nark_font_flag, sizeof(nark_font_flag))
    if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##multi.nark.save" or "Save##multi.nark.save"), imgui.ImVec2(390,25)) then
        if str(nark_font_size):find("^%d+$") and str(nark_font_flag):find("^%d+$") then
            config.data[mynick()].lines.one = str(nark_lines_one)
            config.data[mynick()].lines.two = str(nark_lines_two)
            config.data[mynick()].render.font = str(nark_font_font)
            config.data[mynick()].render.size = tonumber(str(nark_font_size))
            config.data[mynick()].render.flag = tonumber(str(nark_font_flag))
            config_save(config.data)
            renderReleaseFont(font)
            font = renderCreateFont(config.data[mynick()].render.font, config.data[mynick()].render.size, config.data[mynick()].render.flag)
        end
    end
    imgui.Spacing()
    imgui.Spacing()
    local align = (config.data[mynick()].render.align == 0 and (config.data[mynick()].language.number == 1 and "К левому краю" or "Towards the left edge") or
        (config.data[mynick()].render.align == 1 and (config.data[mynick()].language.number == 1 and "По середине" or "In the middle") or (config.data[mynick()].language.number == 1 and "К правому краю" or "Towards the right edge")))
    if imgui.Button((config.data[mynick()].language.number == 1 and "Выравнивание: "..align.."##multi.nark.align" or "Alignment: "..align.."##multi.nark.align"), imgui.ImVec2(390,25)) then
        config.data[mynick()].render.align = config.data[mynick()].render.align + 1
        if config.data[mynick()] ~= nil and config.data[mynick()].render.align >= 3 then
            config.data[mynick()].render.align = 0
        end
        config_save(config.data)
    end
    imgui.PushItemWidth(150)
    if imgui.SliderInt((config.data[mynick()].language.number == 1 and 'Расстояние между строк таймера' or "Distance between timer lines"), nark_height, 2, 10) then
        config.data[mynick()].render.height = nark_height[0]
        config_save(config.data)
    end
    if imgui.SliderInt((config.data[mynick()].language.number == 1 and 'Максимальное кол-во грамм' or "Maximum quantity grams"), nark_max_gramm, 0, 20) then
        config.data[mynick()].drugtimer.max_use_gram = nark_max_gramm[0]
        config_save(config.data)
    end
    if imgui.SliderInt((config.data[mynick()].language.number == 1 and 'Максимальное кол-во HP' or "Maximum HP"), nark_max_hp, 0, 200) then
        config.data[mynick()].drugtimer.hp = nark_max_hp[0]
        config_save(config.data)
    end
end

function autosklad()
    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовзятие склада для гетто" or "Take materials automatically when opening a warehouse"), autogetguns_status, function()
		config.data[mynick()].autogetguns.status = not config.data[mynick()].autogetguns.status
		config_save(config.data)
	end, true, function() end)
end

function fastcar()
    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Быстрый транспорт ФХ" or "Fast transport Family House"), status_fcar_fx, function()
        config.data[mynick()].fastcarfx.status = not config.data[mynick()].fastcarfx.status
        config_save(config.data)
    end, true, function() window_function_1 = "fexit" end)




		imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Нормальная езда без колес" or "Good drive"), gd_status, function()
        config.data[mynick()].good_drive.status = not config.data[mynick()].good_drive.status
        config_save(config.data)
    end, true, function() window_function_1 = "gd" end)

end

function mlines()


	imgui.ToggleButtonTextGear2("Мафия линии", lines_status, function()
		saveINI()
	end, true, function() end)
		imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Рисует линии вокруг квадрата. Быстрое открытие меню - /mlines")
	if imgui.Checkbox(u8("ID 1 - Карьер"), id1_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 2 - Деревня"), id2_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 3 - Аэропорт"), id3_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 4 - Угольная шахта"), id4_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 5 - Стройка"), id5_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 6 - Пилигрим Центр"), id6_status) then
		saveINI()
	end

	if imgui.Checkbox(u8("ID 7 - Стройка Рокшор"), id7_status) then
		saveINI()
	end

	imgui.Spacing()
	imgui.Spacing()

	if imgui.Checkbox(u8("Рисовать только во время стрелы"), time_capt) then
		saveINI()
	end

	if imgui.Checkbox(u8("Рисовать на радаре"), radar_lines) then
		saveINI()
	end

	if imgui.Combo(u8("Тип радара"), type_radar, combo_list, #combolist) then
		saveINI()
	end

	imgui.Spacing()

	if imgui.SliderInt(u8("Ширина линии"), var_0_27, 1, 10) then
		saveINI()
	end

	if imgui.SliderInt(u8("Дистанция"), var_0_28, 0, 3600) then
		saveINI()
	end

	imgui.Spacing()

	if imgui.Combo(u8("Режим отображения"), var_0_29, combo_two, #combotwo) then
		saveINI()
	end

	imgui.Spacing()

	if var_0_29[0] == 1 then
		if imgui.SliderInt(u8("Скорость"), ev1, 1, 10) then
			saveINI()
		end

		if imgui.SliderInt(u8("Прозрачность"), ev0, 1, 255) then
			saveINI()
		end

	elseif imgui.ColorEdit4(u8("Цвет линии"), ev2) then
		var_0_14 = join_argb(ev2[3] * 255, ev2[0] * 255, ev2[1] * 255, ev2[2] * 255)
		saveINI()
	end

	
	imgui.Spacing()
	imgui.Spacing()

	imgui.ToggleButtonTextGear2('Рендер "В квадрате"', v_kv_mafia, function()
		config.data[mynick()].mafialines.kv_render = not config.data[mynick()].mafialines.kv_render
		config_save(config.data)
	end, true, function() end)

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию##2235" or "Change position##3235"), imgui.ImVec2(390,20)) then pos_kvm = true end
end

function blines()

	imgui.ToggleButtonTextGear2("Байкер линии", b_lines_status, function()
	   config.data[mynick()].bikerlines.activated = b_lines_status[0]
	   config_save(config.data)
	end, true, function() end)
		imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Рисует линии вокруг квадрата. Быстрое открытие меню - /blines")



if imgui.Checkbox(u8("Блюберри"), zone_blueberry) then
	bsaveINI()
end

if imgui.Checkbox(u8("Монтгомери"), zone_montgomery) then
	bsaveINI()
end

if imgui.Checkbox(u8("Паломино-Крик"), zone_palomino_creek) then
	bsaveINI()
end

if imgui.Checkbox(u8("Диллимор"), zone_dillimore) then
	bsaveINI()
end

if imgui.Checkbox(u8("Форт-Карсон"), zone_fort_carson) then
	bsaveINI()
end

if imgui.Checkbox(u8("Лас-Барранкас"), zone_las_barrancas) then
	bsaveINI()
end

if imgui.Checkbox(u8("Эль-Кебрадос"), zone_el_quebrados) then
	bsaveINI()
end

if imgui.Checkbox(u8("Энджел-Пайн"), zone_angel_pine) then
	bsaveINI()
end



	imgui.Spacing()
	imgui.Spacing()


	if imgui.Checkbox(u8("Рисовать на радаре##2"), b_radar_lines) then
		bsaveINI()
	end

	if imgui.Combo(u8("Тип радара"), type_radar, combo_list, #combolist) then
		saveINI()
	end

	if imgui.SliderInt(u8("Ширина линии##2"), b_var_0_27, 1, 10) then
		bsaveINI()
	end

	if imgui.SliderInt(u8("Дистанция##2"), b_var_0_28, 0, 3600) then
		bsaveINI()
	end

	imgui.Spacing()

	if imgui.Combo(u8("Режим отображения##2"), b_var_0_29, b_combo_two, #b_combotwo) then
		bsaveINI()
	end

	imgui.Spacing()

	if var_0_29[0] == 1 then
		if imgui.SliderInt(u8("Скорость##2"), b_ev1, 1, 10) then
			bsaveINI()
		end

		if imgui.SliderInt(u8("Прозрачность##2"), b_ev0, 1, 255) then
			bsaveINI()
		end

	elseif imgui.ColorEdit4(u8("Цвет линии##2"), b_ev2) then
		var_0_142 = join_argb(b_ev2[3] * 255, b_ev2[0] * 255, b_ev2[1] * 255, b_ev2[2] * 255)
		bsaveINI()
	end
	imgui.Spacing()
	imgui.Spacing()
	imgui.ToggleButtonTextGear2('Рендер "В квадрате"', v_kv_biker, function()
		config.data[mynick()].bikerlines.kv_render = not config.data[mynick()].bikerlines.kv_render
		config_save(config.data)
	end, true, function() end)

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию##2235" or "Change position##3235"), imgui.ImVec2(390,20)) then pos_kvb = true end
	imgui.Spacing()
	imgui.Spacing()
	imgui.Spacing()

end


function fastsafe()
    imgui.ToggleButtonText((config.data[mynick()].language.number == 1 and "Быстрый сейф ФХ" or "Fast safe Family House"), statusfsafe, function()
        config.data[mynick()].fsafe.status = statusfsafe[0]
        config_save(config.data)
    end)
    imgui.Text((config.data[mynick()].language.number == 1 and "Активация" or "Activation"))
    if fsafeoneHotKey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].fsafe.key = fsafeoneHotKey:GetHotKey()
        config_save(config.data)
    end 
    imgui.Spacing()
    imgui.Spacing()
    imgui.Text((config.data[mynick()].language.number == 1 and "Введите кол-во патрон" or "Enter the number of cartridges"))
    imgui.PushItemWidth(150)
    imgui.InputText((config.data[mynick()].language.number == 1 and "Пин-код" or "Pin-code"), fsafe.pin, sizeof(fsafe.pin)) 
    imgui.InputText((config.data[mynick()].language.number == 1 and "АК-47" or "АК-47"), fsafe.ak, sizeof(fsafe.ak))
    imgui.InputText((config.data[mynick()].language.number == 1 and "M4" or "M4"), fsafe.m4, sizeof(fsafe.m4))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Deagle" or "Deagle"), fsafe.deagle, sizeof(fsafe.deagle))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Rifle" or "Rifle"), fsafe.rifle, sizeof(fsafe.rifle))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Shotgun" or "Shotgun"), fsafe.shotgun, sizeof(fsafe.shotgun))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Антифлуд задержка (мс)" or "Anti-flood delay (ms)"), fsafe.wait, sizeof(fsafe.wait))
    imgui.PopItemWidth()
    if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##save.fsafe" or "Save##save.fsafe"), imgui.ImVec2(380, 25)) then
        config.data[mynick()].fsafe.pin = str(fsafe.pin)
        local list = { "ak", "m4", "deagle", "rifle", "shotgun", "wait"}
        for i = 1, #list do
            local text = str(fsafe[list[i]])
            if text:find("^%d+$") then
                config.data[mynick()].fsafe[list[i]] = tonumber(text)
            else
                imgui.StrCopy(fsafe[list[i]], tostring(config.data[mynick()].fsafe[list[i]]))
            end
        end
        config_save(config.data)
    end
	imgui.Spacing()
	imgui.Spacing()
	imgui.Spacing()
	if imgui.Checkbox(u8((config.data[mynick()].language.number == 1 and "Автовзятие нарко с сейфа до максимума" or "Auto-take drugs from safe to maximum")), drug_status) then
		config.data[mynick()].fsafe.drugs_status = not config.data[mynick()].fsafe.drugs_status
		config_save(config.data)
	end
end


function getgun()
    imgui.ToggleButtonText((config.data[mynick()].language.number == 1 and "Быстрый склад байкеров/мафий" or "Fast warehouse for bikers/mafia"), getguns_status, function()
        config.data[mynick()].getguns.status = getguns_status[0]
        config_save(config.data)
    end)
	
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовзятие склада для гетто" or "Autotake warehouse for ghetto"), autogetguns_status, function()
		config.data[mynick()].autogetguns.status = not config.data[mynick()].autogetguns.status
		config_save(config.data)
	end, true, function() end)
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Принимать запрос на открытие склада" or "Accept a request to open a warehouse"), request_wlpale, function()
		config.data[mynick()].LeaderManagement.warehouse_request = not config.data[mynick()].LeaderManagement.warehouse_request
		config_save(config.data)
	end, true, function() end)
	imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], (config.data[mynick()].language.number == 1 and "Для запроса открытия склада для членов состава, напишите в чат семьи" or 'To request the opening of a warehouse for cast members, write to the family chat'))
    imgui.Text((config.data[mynick()].language.number == 1 and "Активация" or "Activation"))

    if GetgunsHotKey:ShowHotKey(imgui.ImVec2(390,20)) then 
        config.data[mynick()].getguns.key = GetgunsHotKey:GetHotKey()
        config_save(config.data)
    end  

    imgui.Spacing()
    imgui.Spacing()
    imgui.Spacing()
	imgui.Text((config.data[mynick()].language.number == 1 and "Указывать количество кликов, а не патронов" or "Specify the number of clicks, not bullets"))
    imgui.PushItemWidth(150)
    imgui.InputText("АК-47", getguns.ak, sizeof(getguns.ak))
    imgui.InputText("M4", getguns.m4, sizeof(getguns.m4))
    imgui.InputText("Deagle", getguns.deagle, sizeof(getguns.deagle))
    imgui.InputText("Rifle", getguns.rifle, sizeof(getguns.rifle))
    imgui.InputText("Shotgun", getguns.shotgun, sizeof(getguns.shotgun))
    imgui.PopItemWidth()
	imgui.Checkbox(u8((config.data[mynick()].language.number == 1 and "Брать броню" or "Take armor")), armor_status)
	if imgui.Checkbox((config.data[mynick()].language.number == 1 and "Использовать аптечки при взятии оружия" or "Use first aid kits when taking weapons"), autoheal_for_mafia) then
        config.data[mynick()].getguns.autoheal = autoheal_for_mafia[0]
        config_save(config.data)
    end
    if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##save.getguns" or "Save##save.getguns"), imgui.ImVec2(380, 25)) then
		config.data[mynick()].getguns.armor = armor_status[0]
        local list = { "ak", "m4", "deagle", "rifle", "shotgun" }
        for i = 1, #list do
            local text = str(getguns[list[i]])
            if text:find("^%d+$") then
                config.data[mynick()].getguns[list[i]] = tonumber(text)
            else
                imgui.StrCopy(getguns[list[i]], tostring(config.data[mynick()].getguns[list[i]]))
            end
        end
        config_save(config.data)
    end

    imgui.Spacing()
    imgui.Spacing()
    imgui.Spacing()

    if imgui.Checkbox((config.data[mynick()].language.number == 1 and "Брать нарко до фулла при переходе в меню бара > Наркотики" or "Take drugs until full when going to the bar menu > Drugs"), getguns.drugs) then
        config.data[mynick()].getguns.auto_get_drugs = getguns.drugs[0]
        config_save(config.data)
    end

    if imgui.Checkbox((config.data[mynick()].language.number == 1 and "Пополнять сытость полностью при переходе в меню бара" or "Replenish satiety completely when going to the bar menu"), getguns.drink) then
        config.data[mynick()].getguns.auto_get_drink = getguns.drink[0]
        config_save(config.data)
    end
end



function LeadersManagement()
	    imgui.ToggleButtonText((config.data[mynick()].language.number == 1 and "Рендер оружия" or "Рендер оружия"), render_gun_bool, function()
        config.data[mynick()].render_gun.render = render_gun_bool[0]
        config_save(config.data)
    end)

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию##223" or "Change position##323"), imgui.ImVec2(390,20)) then pos_ptr = true end


			--imgui.InputText((config.data[mynick()].language.number == 1 and "Название шрифта" or 'Font name'), ld_font, sizeof(ld_font))

	if imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Шрифт" or "Font")), int_gun, combo_gun, #combogun) then
		config.data[mynick()].render_gun.int = int_gun[0]
		if int_gun[0] < 3 then
			config.data[mynick()].render_gun.font = combogun[int_gun[0] + 1]
		end
		config_save(config.data)
		ld_font = imgui.new.char[256](u8(config.data[mynick()].render_gun.font))
	end
    if config.data[mynick()] ~= nil and config.data[mynick()].render_gun.int == 3 then imgui.InputText((config.data[mynick()].language.number == 1 and "Название шрифта" or 'Font name'), ld_font, sizeof(ld_font)) end
			imgui.InputText((config.data[mynick()].language.number == 1 and "Размер шрифта" or 'Font size'), ldfont_size, sizeof(ldfont_size))
			imgui.InputText((config.data[mynick()].language.number == 1 and "Стиль шрифта" or 'Font style'), ldfont_flag, sizeof(ldfont_flag))	
			if imgui.ColorEdit4("Цвет", color_ld) then 	
				config.data[mynick()].render_gun.color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(color_ld[0], color_ld[1], color_ld[2], color_ld[3])) 
				config_save(config.data) 
			end

			if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##multi.lead.save" or 'Save##multi.lead.save'), imgui.ImVec2(390,25)) then
				config.data[mynick()].render_gun.font = str(ld_font)
				config.data[mynick()].render_gun.size = tonumber(str(ldfont_size))
				config.data[mynick()].render_gun.flag = tonumber(str(ldfont_flag))
				config_save(config.data)
				renderReleaseFont(font_for_notification)
				font_for_notification = renderCreateFont(config.data[mynick()].render_gun.font, config.data[mynick()].render_gun.size, config.data[mynick()].render_gun.flag)
			end

	imgui.Spacing()
    imgui.Spacing()
    imgui.Separator()
    imgui.Spacing()
    imgui.Spacing()
end

--yyyyyy
function eblocheck()
	if window_function_6 == "" then
			imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Фам чекер" or "Famcheck"), famccheckbool, function()
            config.data[mynick()].eblochecker.fam_status = not config.data[mynick()].eblochecker.fam_status
            config_save(config.data)
    end, true, function() window_function_6 = "fam" end)

	    imgui.ToggleButtonTextGear("Байкерлист", bikerlist_status, function()
        config.data[mynick()].bikerlist.status = not config.data[mynick()].bikerlist.status
        config_save(config.data)
    end, true, function() window_function_6 = "bli" end)
					imgui.Spacing()
	imgui.Spacing()
			imgui.Spacing()
	imgui.Spacing()


	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер банд" or "Gang checker"), EbloGangStatus, function()
        config.data[mynick()].eblochecker.gang_status = not config.data[mynick()].eblochecker.gang_status
        config_save(config.data)
    end, true, function() window_function_6 = "gang" end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and  "Банды в зоне стрима" or "Gangs in the stream area"), EbloGangStream, function()
        config.data[mynick()].eblochecker.gang_stream = not config.data[mynick()].eblochecker.gang_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер банд" or "Move gang checker"), imgui.ImVec2(390, 25)) then
        pos_gang = true
    end
imgui.Spacing()
imgui.Spacing()
imgui.Spacing()
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер мафий" or "Mafia checker"), EbloMafiaStatus, function()
        config.data[mynick()].eblochecker.maf_status = not config.data[mynick()].eblochecker.maf_status
        config_save(config.data)
    end, true, function() end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Мафии в зоне стрима" or "Mafia in the stream zone"), EbloMafiaStream, function()
        config.data[mynick()].eblochecker.maf_stream = not config.data[mynick()].eblochecker.maf_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер мафий" or "Move Mafia Checker"), imgui.ImVec2(390, 25) ) then
        pos_maf = true
    end
imgui.Spacing()
imgui.Spacing()
imgui.Spacing()
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер байкеров" or "Biker checker"), EbloBikersStatus, function()
        config.data[mynick()].eblochecker.biker_status = not config.data[mynick()].eblochecker.biker_status
        config_save(config.data)
    end, true, function() end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Байкеры в зоне стрима" or "Bikers in the stream zone"), EbloBikersStream, function()
        config.data[mynick()].eblochecker.biker_stream = not config.data[mynick()].eblochecker.biker_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер байкеров" or "Move the bikers checker"), imgui.ImVec2(390, 25) ) then
        pos_biker = true
    end


   --[[ imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Чекер банд" or "Gang checker"), EbloGangStatus, function()
        config.data[mynick()].eblochecker.gang_status = not config.data[mynick()].eblochecker.gang_status
        config_save(config.data)
    end, true, function() window_function_6 = "gang" end)

    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Чекер мафий" or "Mafia checker"), EbloMafiaStatus, function()
        config.data[mynick()].eblochecker.maf_status = not config.data[mynick()].eblochecker.maf_status
        config_save(config.data)
    end, true, function() window_function_6 = "mafia" end)


    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Чекер байкеров" or "Biker checker"), EbloBikersStatus, function()
        config.data[mynick()].eblochecker.biker_status = not config.data[mynick()].eblochecker.biker_status
        config_save(config.data)
    end, true, function() window_function_6 = "biker" end)]]
imgui.Spacing()
imgui.Spacing()
imgui.Spacing()
imgui.Spacing()


    local style = (config.data[mynick()].eblochecker.style == 0 and "1" or "2")
    if imgui.Button((config.data[mynick()].language.number == 1 and "Стиль №" or "Style №")..style.."##multi.nark.style", imgui.ImVec2(390,25)) then
        config.data[mynick()].eblochecker.style = config.data[mynick()].eblochecker.style + 1
        if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style >= 2 then
            config.data[mynick()].eblochecker.style = 0
        end
        config_save(config.data)
    end

		imgui.Spacing()
	imgui.Spacing()
else
								 if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(390,20)) then
                                window_function_6 = ""
                            end
							imgui.Spacing()
	if window_function_6 == "gang" then
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер банд" or "Gang checker"), EbloGangStatus, function()
        config.data[mynick()].eblochecker.gang_status = not config.data[mynick()].eblochecker.gang_status
        config_save(config.data)
    end, true, function() window_function_6 = "gang" end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and  "Банды в зоне стрима" or "Gangs in the stream area"), EbloGangStream, function()
        config.data[mynick()].eblochecker.gang_stream = not config.data[mynick()].eblochecker.gang_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер банд" or "Move gang checker"), imgui.ImVec2(390, 25)) then
        pos_gang = true
    end
	end
	if window_function_6 == "mafia" then
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер мафий" or "Mafia checker"), EbloMafiaStatus, function()
        config.data[mynick()].eblochecker.maf_status = not config.data[mynick()].eblochecker.maf_status
        config_save(config.data)
    end, true, function() end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Мафии в зоне стрима" or "Mafia in the stream zone"), EbloMafiaStream, function()
        config.data[mynick()].eblochecker.maf_stream = not config.data[mynick()].eblochecker.maf_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер мафий" or "Move Mafia Checker"), imgui.ImVec2(390, 25) ) then
        pos_maf = true
    end
	end

	if window_function_6 == "biker" then
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Чекер байкеров" or "Biker checker"), EbloBikersStatus, function()
        config.data[mynick()].eblochecker.biker_status = not config.data[mynick()].eblochecker.biker_status
        config_save(config.data)
    end, true, function() end)

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Байкеры в зоне стрима" or "Bikers in the stream zone"), EbloBikersStream, function()
        config.data[mynick()].eblochecker.biker_stream = not config.data[mynick()].eblochecker.biker_stream
        config_save(config.data)
    end, true, function() end)

    if imgui.Button((config.data[mynick()].language.number == 1 and "Переместить чекер байкеров" or "Move the bikers checker"), imgui.ImVec2(390, 25) ) then
        pos_biker = true
    end
	end

	
end
end
--xyi
function ebloccheck2()
	if window_function_6 == "fam" then
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Фам чекер" or "Famcheck"), famccheckbool, function()
            config.data[mynick()].eblochecker.fam_status = not config.data[mynick()].eblochecker.fam_status
            config_save(config.data)
    end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Онлайн игроков в семьях" or "error"), famccheckbool3, function()
            config.data[mynick()].eblochecker.families = not config.data[mynick()].eblochecker.families 
            config_save(config.data)
    end, true, function() end)


		if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию##554234" or "Change position##4r25433"), imgui.ImVec2(390,20)) then  
			pos_twof = true
		end

	imgui.Spacing()
		imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Онлайн игроков по статусам" or "error"), famccheckbool2, function()
            config.data[mynick()].eblochecker.statuses = not config.data[mynick()].eblochecker.statuses
            config_save(config.data)
    end, true, function() end)
    if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию##5542" or "Change position##4r254"), imgui.ImVec2(390,20)) then            
    pos_onef = true

	end 
end
	if window_function_6 == "bli" then
        bikerlists()
	end
--bikerlists()


end

function log_update()
    if imgui.BeginChild('Version 1.0.', imgui.ImVec2(410, 270), true) then
        imgui.CenterText("Version 1.0. | Palenation Tool Extended")
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text("Создание базы мультитула.")
        imgui.Text("Создание первичного интерфейса и дизайна.")
        imgui.Spacing()
        imgui.Text("Добавление модулей:")
        imgui.Text("Управление лидером,")
        imgui.Text("Быстрый транспорт,")
        imgui.Text("Быстрый склад,")
        imgui.Text("Быстрый сейф,")
        imgui.Text("Наркотаймер,")
        imgui.Text("Автокаптер,")
        imgui.Text("Еблочекер.")
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Text("                                                                                 Дата: 15.09.2024")
        imgui.EndChild() 
    end

	imgui.Spacing()
	imgui.Spacing()

	if imgui.BeginChild('Version 2.0.', imgui.ImVec2(410, 270), true, imgui.WindowFlags.NoScrollbar) then
        imgui.CenterText("Version 2.0. | Palenation Tool Extended")
        imgui.Spacing()
        imgui.Separator()
        imgui.Spacing()

        imgui.Text("Управление лидером.")
        imgui.Text("Добавлено ответное СМС от лидера как уведомление о \nвыполнении или невыполнении команды.")
        imgui.Text("Отчетное сообщение теперь выводится не во фракционный чат,\nа в чат семьи.")
		imgui.Spacing()
		imgui.Spacing()
        imgui.Text("Быстрый транспорт.")
        imgui.Text("Была добавлена возможность автоматического выхода после\nспавна автомобиля.")
        imgui.Text("Была добавлена функция автовзятия материалов при открытии\nсклада в банде.")
		imgui.Spacing()
		imgui.Spacing()
        imgui.Text("Быстрый склад.")
        imgui.Text("Функция быстрый склад была также адаптирована под мафии.")
		imgui.Spacing()
		imgui.Spacing()
        imgui.Text("Быстрый сейф.")
		imgui.Text("Функция быстрый сейф была адаптирована под ДНК.")
		imgui.Text('Изменена система взятия оружия, что позволило брать оружие \nбыстрее и без ошибок "не флуди".')
		imgui.Spacing()
		imgui.Text("Была добавлена функция линий границ для мафий.")
		imgui.Spacing()
        imgui.Spacing()
		imgui.Text("Еблочекер.")
		imgui.Text("В еблочекер был добавлен альтернативный внешний стиль.")
		imgui.Text("В еблочекер добавлена возможность показывать количество")
		imgui.Text("байкеров/бандитов/мафиози в зоне прорисовки.")
		imgui.Spacing()
		imgui.Text("Добавлена функция сбива.")
		imgui.Spacing()
		imgui.Text("Пофикшен ряд багов, исправлены недоработки в модулях.")
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Spacing()
        imgui.Text("                                                                                 Дата: 24.09.2024")
        imgui.EndChild() 
    end
end


function SmallTweaks()
	if window_function_8 == "" then

			    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Наркотаймер" or "Drugtimer"), status_drug_timer, function()
		config.data[mynick()].drugtimer.status = not config.data[mynick()].drugtimer.status
		config_save(config.data)
    end, true, function() window_function_8 = "drugtimer"  end)
						imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Автокапт и флудер" or "Autocapt and flooder"), FlooderStatus, function()
		config.data[mynick()].AutoCapt.flooder_status = not config.data[mynick()].AutoCapt.flooder_status
		config_save(config.data)
	end, true, function() window_function_8 = "captureflood" end)
	imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Еблочекер" or "Eblochecker"), Eblo_Status, function()
		config.data[mynick()].eblochecker.status = not config.data[mynick()].eblochecker.status
		config_save(config.data)
	end, true, function() window_function_8 = "eblo" end)		
						imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"],"Отображение онлайна фам, банд, мафии, байкеров на экране")
		imgui.Spacing()
		imgui.Spacing()
		    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Уведомления в чате" or "chat notifications"), notif_status, function()
        config.data[mynick()].small_tweaks.notifications = not config.data[mynick()].small_tweaks.notifications
        config_save(config.data)
    end, true, function() window_function_8 = "notf" end)	

		imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Автоматическая погрузка материалов для байкеров" or "Auto loading of materials for bikers"), status_truck, function()
		config.data[mynick()].small_tweaks.truck = not config.data[mynick()].small_tweaks.truck
		config_save(config.data)
	end, true, function() window_function_8 = "amat" end)
		imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Удаление оружия ближнего боя" or "Removal of melee weapons"), status_melee2, function()
		config.data[mynick()].delete_melee_weapon.status = not config.data[mynick()].delete_melee_weapon.status
		config_save(config.data)
	end, true, function() window_function_8 = "melee" end)		
	                    imgui.ToggleButtonTextGear2("Отображение ID игроков в киллисте", id_killlist, function()
                        config.data[mynick()].id_killlist.status = not config.data[mynick()].id_killlist.status
                        config_save(config.data)
                    end)   		              

	imgui.ToggleButtonTextGear2("Замена названия окна игры на никнейм", ReplacingWindowWithNickName_status, function()
                        config.data[mynick()].ReplacingWindowWithNickName.status = not config.data[mynick()].ReplacingWindowWithNickName.status
                        config_save(config.data)
                        ReplacingWindowWithNickName()
                    end)    
										imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"], 'Заменяет имя окна на ник персонажа + сервер')
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автоматическое использование аптечек для мафий" or "Autoheal for the mafia"), status_autoheal, function()
		config.data[mynick()].small_tweaks.autoheal = not config.data[mynick()].small_tweaks.autoheal
		config_save(config.data)
	end, true, function() end)

 



	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовход в дом" or "automatic entry into the house"), status_exit, function()
        config.data[mynick()].small_tweaks.exit = not config.data[mynick()].small_tweaks.exit
        config_save(config.data)
    end, true, function() end)
	
	                        imgui.ToggleButtonTextGear2("Быстрая маска", pmask, function()
                            config.data[mynick()].small_tweaks.pmask = not config.data[mynick()].small_tweaks.pmask
                            config_save(config.data)
                        end, true, function() end)     
						imgui.SameLine()
                        imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Активация: /pmask")	


					imgui.ToggleButtonTextGear2("Отключение фриза при выходе и входе в интерьер", NoInteriorFreeze, function()
                        config.data[mynick()].NoInteriorFreeze.status = not config.data[mynick()].NoInteriorFreeze.status
                        config_save(config.data)
                    end)  
					imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"],"Убирает фризы при спавне.")


					imgui.ToggleButtonTextGear2("Управление оружием на пассажирке", hideweapon_status, function()
                        config.data[mynick()].hideweapon.status = not config.data[mynick()].hideweapon.status
                        config_save(config.data)
                    end)   
					imgui.SameLine()
                    imgui.TextQuestion(fa["CIRCLE_QUESTION"],'Позволяет убирать оружие на пассажирке и менять его по нажатию "[" и "]"')
					 imgui.ToggleButtonTextGear("Camhack", camhack_status, function()
                        config.data[mynick()].camhack.status = not config.data[mynick()].camhack.status
                        config_save(config.data)
                    end, true, function() window_function_8 = "camhack" end)    



	imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Быстрый банкомат" or "Fast Bank"), status_bank, function()
		config.data[mynick()].small_tweaks.bank = not config.data[mynick()].small_tweaks.bank
		config_save(config.data)
	end, true, function() window_function_8 = "bank" end)

else 

	if window_function_8 == "captureflood" then
							if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(410,20)) then
                                window_function_8 = ""
                            end
						else
														if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(390,20)) then
                                window_function_8 = ""
                            end
	end
							imgui.Spacing()
if window_function_8 == "captureflood" then
	flooder_and_autocapture()
end

	if window_function_8 == "notf" then
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображение зашедших/вышедших игроков в чате" or "Displaying entered/exited players in chat"), status_players, function()
		config.data[mynick()].squad.players = not config.data[mynick()].squad.players
		config_save(config.data)
	end, true, function() end)
	
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отключение уведомлений о спавне транспорта" or "Disabling vehicle spawn notifications"), status_spawncar, function()
		config.data[mynick()].small_tweaks.spawncar = not config.data[mynick()].small_tweaks.spawncar
		config_save(config.data)
	end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отключение уведомлений о взятии оружия" or "Disabling notifications about picking up weapons"), status_takegun, function()
		config.data[mynick()].small_tweaks.takegun = not config.data[mynick()].small_tweaks.takegun
		config_save(config.data)
	end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отключение уведомлений от Контрабандиста" or "Turn off notifications from Smuggler"), status_smuggler, function()
		config.data[mynick()].small_tweaks.smuggler = not config.data[mynick()].small_tweaks.smuggler
		config_save(config.data)
	end, true, function() end)

	end
							if window_function_8 == "camhack" then
								camhack()
							end
							if window_function_8 == "melee" then
									imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Удаление оружия ближнего боя" or "Removal of melee weapons"), status_melee2, function()
		config.data[mynick()].delete_melee_weapon.status = not config.data[mynick()].delete_melee_weapon.status
		config_save(config.data)
	end, true, function() window_function_8 = "melee" end)	
	imgui.Spacing()
	imgui.Spacing()
local list_melee = {["knuckles"] = "Кастет", ["kiy"] = "Кий", ["stick"] = "Клюшка", ["katana"] = "Катана", ["bat"] = "Бита"}

-- Матрица, которая перегруппирует элементы для построчного вывода:
-- Ряд 1: Кастет (1), Кий (2), Клюшка (3)
-- Ряд 2: Катана (4), Бита (5)
local vertical_order = {
    "knuckles", "kiy", "stick",
    "katana",   "bat"
}

counter = 0
for _, k in ipairs(vertical_order) do
    local v = list_melee[k]
    counter = counter + 1

    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and v or k), status_melee[k], function()
        config.data[mynick()].delete_melee_weapon[k] = not config.data[mynick()].delete_melee_weapon[k]
        config_save(config.data)
    end, true, function() end)

    -- Делаем 3 ровные колонки по горизонтали
    local position_in_row = counter % 2

    if position_in_row == 1 then
        imgui.SameLine(130) -- Позиция второго столбика (Кий / Бита)
    elseif position_in_row == 2 then
        imgui.SameLine(200) -- Позиция третьего столбика (Клюшка)
    end
end



							end
	if window_function_8 == "eblo" then
                eblocheck()
				ebloccheck2()
	end
		if window_function_8 == "drugtimer" then
			narkotimer()
	end
	if window_function_8 == "amat" then
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автоматическая погрузка материалов для байкеров" or "Auto loading of materials for bikers"), status_truck, function()
		config.data[mynick()].small_tweaks.truck = not config.data[mynick()].small_tweaks.truck
		config_save(config.data)
	end, true, function() end)

		imgui.InputTextWithHint("##Командаже", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), TruckCom, sizeof(TruckCom))
		if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить команду" or "Save command"), imgui.ImVec2(276,20)) then
			sampUnregisterChatCommand(config.data[mynick()].small_tweaks.truck_command)
			config.data[mynick()].small_tweaks.truck_command = str(TruckCom)
			config.data[mynick()].small_tweaks.truck_command = config.data[mynick()].small_tweaks.truck_command:gsub("/","")
			config_save(config.data)
			truck_cmd_register()
		end
	end--cccc
	if window_function_8 == "bank" then
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Банк" or "Bank"), status_bank, function()
		config.data[mynick()].small_tweaks.bank = not config.data[mynick()].small_tweaks.bank
		config_save(config.data)
	end, true, function() window_function_8 = "bank" end)
	imgui.Spacing()
imgui.Spacing()
	if imgui.InputTextWithHint("Снятие средств##Командаже22", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), withdrawCom, sizeof(withdrawCom)) then
			sampUnregisterChatCommand(config.data[mynick()].bank.withdraw)
			config.data[mynick()].bank.withdraw = str(withdrawCom)
			config.data[mynick()].bank.withdraw = config.data[mynick()].bank.withdraw:gsub("/","")
			config_save(config.data)
			withdraw_cmd_register()
	end
	if imgui.InputTextWithHint("Пополнение счета##Командаже33", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), depositCom, sizeof(depositCom)) then
			sampUnregisterChatCommand(config.data[mynick()].bank.deposit)
			config.data[mynick()].bank.deposit = str(depositCom)
			config.data[mynick()].bank.deposit = config.data[mynick()].bank.deposit:gsub("/","")
			config_save(config.data)
			deposit_cmd_register()
	end
	if imgui.InputTextWithHint("Перевод средств##Командаже223", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), transferCom, sizeof(transferCom)) then
			sampUnregisterChatCommand(config.data[mynick()].bank.transfer)
			config.data[mynick()].bank.transfer = str(transferCom)
			config.data[mynick()].bank.transfer = config.data[mynick()].bank.transfer:gsub("/","")
			config_save(config.data)
			transfer_cmd_register()
	end

	end
end
end


function withdraw_cmd_register()
	if sampIsChatCommandDefined(config.data[mynick()].bank.withdraw) then
        sampUnregisterChatCommand(config.data[mynick()].bank.withdraw)
    end

    sampRegisterChatCommand(config.data[mynick()].bank.withdraw, withdraw_process)
end

function deposit_cmd_register() 
    if sampIsChatCommandDefined(config.data[mynick()].bank.deposit) then
        sampUnregisterChatCommand(config.data[mynick()].bank.deposit)
    end

    sampRegisterChatCommand(config.data[mynick()].bank.deposit, deposit_process)
end

function transfer_cmd_register() 
    if sampIsChatCommandDefined(config.data[mynick()].bank.transfer) then
        sampUnregisterChatCommand(config.data[mynick()].bank.transfer)
    end

    sampRegisterChatCommand(config.data[mynick()].bank.transfer,transfer_process)
end

function transfer_process(arg)
	if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.bank then
    if deposit.process or withdraw.process then sampAddChatMessage('Ошибка! Активен другой процесс. Что-бы отменить: /bwd или /bdp', 0xABCDEF) return end
    if transfer.process then sampAddChatMessage('Перевод средств отменён.', 0xABCDEF) transfer.process = false transfer.nick = '' transfer.summ = 0 return end
    if arg:find('^%d+ %d+$') then
        if sampIsPlayerConnected(tonumber(arg:match('^%d+ (%d+)$'))) then
            local babki = arg:match('^(%d+) %d+$')
            local name = sampGetPlayerNickname(tonumber(arg:match('^%d+ (%d+)$')))
            arg = babki..' '..name
        else
            sampAddChatMessage('Ошибка! Игрока нет на сервере!', 0xABCDEF)
            return
        end
    end
    if not arg or not arg:find('^%d+ .+$') then sampAddChatMessage('Ошибка! Неверный синтаксис. Пример: /btr *Сумма* *Ник* или *Id*',0xABCDEF) return end
    if tonumber(arg:match('^(%d+) .+$')) <= 0 then sampAddChatMessage('Ошибка! Введите корректную сумму!', -1) return end
    if tonumber(arg:match('^(%d+) .+$')) > getPlayerMoney(playerHandle) then sampAddChatMessage('Ошибочка, вы не располагаете такой суммой!(на руках)', 0xABCDEF) return end
    transfer.summ = tonumber(arg:match('^(%d+) .+$'))
    transfer.nick = arg:match('^%d+ (.+)$')
    transfer.process = true
    sampAddChatMessage('Теперь подойдите к банкомату и нажмите Enter', 0xABCDEF)
    sampAddChatMessage('Будет переведено: '..transfer.summ..' На ник: '..transfer.nick, 0xABCDEF)
end
end

function deposit_process(arg)
	if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.bank then
    if transfer.process or withdraw.process then sampAddChatMessage('Ошибка! Активен другой процесс. Что-бы отменить: /bwd или /btr', 0xABCDEF) return end
    if deposit.process then sampAddChatMessage('Пополнение счёта отменено!', 0xABCDEF) deposit.process = false deposit.summ = 0 return end
    if not arg or not arg:find('^%d+$') then sampAddChatMessage('Ошибка! Неверный синтаксис. Пример: /bdp *Сумма*',0xABCDEF) return end
    if tonumber(arg) <= 0 then sampAddChatMessage('Ошибка! Введите корректную сумму!', -1) return end
    if tonumber(arg) > getPlayerMoney(playerHandle) then sampAddChatMessage('Ошибочка, вы не располагаете такой суммой!', 0xABCDEF) return end
    deposit.summ = tonumber(arg)
    deposit.process = true
    sampAddChatMessage('Теперь подойдите к банкомату и нажмите Enter. Положим на счёт: '..arg, 0xABCDEF)
	end
end

function withdraw_process(arg)
	if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.bank then
    if deposit.process or transfer.process then sampAddChatMessage('Ошибка! Активен другой процесс. Что-бы отменить: /btr или /bdp', 0xABCDEF) return end
    if withdraw.process then sampAddChatMessage('Снятие денег отменено!', 0xABCDEF) withdraw.summ = 0 withdraw.process = false return end
    if not arg or not arg:find('^%d+$') then sampAddChatMessage('Ошибка! Неверный синтаксис. Пример: /bwd *Сумма*',0xABCDEF) return end
    if tonumber(arg) <= 0 then sampAddChatMessage('Ошибка! Введите корректную сумму!', 0xABCDEF) return end
    withdraw.summ = tonumber(arg)
    withdraw.process = true
    sampAddChatMessage('Теперь подойдите к банкомату и нажмите Enter. Будет снято: '..arg, 0xABCDEF)
	end
end

function flooderc()
	imgui.Text((config.data[mynick()].language.number == 1 and 'Флудер для каптов в мафии и бандах' or "")) 
	imgui.PushItemWidth(390)
	imgui.InputTextWithHint("##Команда флуда", (config.data[mynick()].language.number == 1 and "Введите команду для флуда" or "Enter the command to flood"), FlooderCommand, sizeof(FlooderCommand))
    if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить команду##aa" or "Save command##aa"), imgui.ImVec2(390,20)) then	
        sampUnregisterChatCommand(config.data[mynick()].AutoCapt.flooder_com)
        config.data[mynick()].AutoCapt.flooder_com = str(FlooderCommand)
        config.data[mynick()].AutoCapt.flooder_com = config.data[mynick()].AutoCapt.flooder_com:gsub("/","")
        config_save(config.data)
        flooder_cmd_register()
    end
	imgui.PopItemWidth()

imgui.Spacing()


end


function sampev.onPlayerDeathNotification(killerId, playerId, reason)

    if config.data[mynick()] ~= nil and config.data[mynick()].id_killlist.status then
        	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)

	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(playerId) or playerId == myid ) and sampGetPlayerNickname(playerId) or nil
	eventThreadCreate(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. playerId .. ']' ):sub(1, 24) ) end
	end)
    end
end

function onReceiveRpc(id, bs)
    if id == 15 and sampGetCurrentServerName():lower():find("evolve") and config.data[mynick()].NoInteriorFreeze.status then
        return false
    end
end

--------------------------------------------------------------------------------
-----------------------------------onServerMessage------------------------------
--------------------------------------------------------------------------------
local pale_list_ranks = {
[1] = "hanged", 
[2] = "comrade", 
[3] = "paleprospect", 
[4] = "fullpatch", 
[5] = "lifetime", 
[6] = "officer", 
[7] = "national president"
}

local two_name = {
	[7] = "sturmmann",
	[6] = "rottenfuhrer",
	[5] = "scharfuhrer",
	[4] = "untersturmfuhrer",
	[3] = "hauptsturmfuhrer",
	[2] = "obersturmbannfuhrer",
	[1] = "sturmbannfuhrer"
}
-- Отправитель: Контрабандист -65366
-- Контрабандист -858993409

------------------------------------------------------------------
----------------------------onCreate3DText------------------------
------------------------------------------------------------------

vremya_mcg = 0
function sampev.onCreate3DText(idObject, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, textObject)
    if textObject:find("materials get") and config.data[mynick()].small_tweaks.truck and not truck_flooder then
		if vremya_mcg == 0 or (vremya_mcg > 0 and (os.time() - vremya_mcg) > 119) then
		    vremya_mcg = os.time()
		    msg(("Введите /%s чтобы запустить автоматическое взятие/загрузку ящиков"):format(config.data[mynick()].small_tweaks.truck_command))
		end
    end
end

function sampev.onSendCommand(command)

	antiflood = os.clock() * 1000
	if (command:find("/CAPTURE (%d+)") or command:find("/cAPTURE (%d+)") or command:find("/CaPTURE (%d+)") or command:find("/CapTURE (%d+)") or command:find("/CaptURE (%d+)") or command:find("/CaptuRE (%d+)") or command:find("/capturE (%d+)") or command:find("/capture (%d+)") or command:find("/Capture (%d+)") or command:find("/CApture (%d+)") or command:find("/CAPture (%d+)") or command:find("/CAPTure (%d+)") or command:find("/CAPTUre (%d+)") or command:find("/CAPTURe (%d+)") or command:find("/CAPTURE (%d+)")) and not capture_on_command then
		capture_biz = command:match("/capture (%d+)")
		capture_on_command = true
		AutoCapterstart = true
	elseif (command:find("/capture") or command:find("/CAPTURE") or command:find("/CAPTURE (%d+)") or command:find("/cAPTURE (%d+)") or command:find("/CaPTURE (%d+)") or command:find("/CapTURE (%d+)") or command:find("/CaptURE (%d+)") or command:find("/CaptuRE (%d+)") or command:find("/capturE (%d+)") or command:find("/capture (%d+)") or command:find("/Capture (%d+)") or command:find("/CApture (%d+)") or command:find("/CAPture (%d+)") or command:find("/CAPTure (%d+)") or command:find("/CAPTUre (%d+)") or command:find("/CAPTURe (%d+)") or command:find("/CAPTURE (%d+)")) and capture_on_command then
		capture_on_command = false
		AutoCapterstart = false
		capture_biz = nil
	end
end
--#onServerMessage
autoreport_time = 0
efcs.blocked_slots = {}
prinyatrep = false
idkilera = -1

function sampev.onApplyPlayerAnimation(animId, animLib, animName)
	if config.data[mynick()] ~= nil and config.data[mynick()].hidechar.status then
		if sampFindAnimationIdByNameAndFile(animName, animLib) == 1151 then
			local var_1_0, var_1_1 = sampGetCharHandleBySampPlayerId(animId)

			if var_1_0 then
				emul_rpc("onPlayerStreamOut", {
					animId,
				})
			end
		end

		if animName == "KD_left" or animName == "KD_right" or animName == "KO_shot_face" or animName == "KO_shot_front" or animName == "KO_shot_stom" or animName == "KO_skid_back" or animName == "KO_skid_front" or animName == "KO_spin_L" or animName == "KO_spin_R" then
			local var_1_2, var_1_3 = sampGetCharHandleBySampPlayerId(animId)

			if var_1_2 then
				emul_rpc("onPlayerStreamOut", {
					animId,
				})
			end
		end
	end
end

function sampev.onServerMessage(color, message)
	if load_all then


		if message:find("Доступно администрации / VIP 2 уровня / саппортам") and color == -1263159297 and config.data[mynick()].adminchecker.status then
		    EvolveAdminsCommand()
			return false
		end
		if message:find("Война за территорию окончена") then
			capture_status = false
		end
		if message:find("PALЕRIDERS") and message:find("preport (%d+)") and config.data[mynick()].autoreport.status and (os.time() - autoreport_time) > 119 then
			prinyatrep = true
			idkrl = message:match("preport (%d+)")
			lua_thread.create(function()
			    repeat
				wait(0)
				until os.clock() * 1000 - antiflood > 1000
				sampSendChat("/fc РїСЂРёРЅСЏР»СЂРµРї")
				idkilera = idkrl
			end)
			if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
		elseif message:find("PALЕRIDERS") and message:find("preport (%d+)") then
			if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
		end

		if prinyatrep and message:find("PALЕRIDERS") and message:find("РїСЂРёРЅСЏР»СЂРµРї") then
			if not message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) then
				prinyatrep = false
			elseif message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) then

				eventThreadCreate(function()
							repeat
				wait(0)
				until os.clock() * 1000 - antiflood > 1000
				                math.randomseed(os.time())
                local number = math.random(1, #config.data[mynick()].autoreport.list_prichin)
                prichina = u8:decode(config.data[mynick()].autoreport.list_prichin[number])
				    math.randomseed(os.time())
				    random_number = math.random(500, 5000)
					wait(random_number)
				sampSendChat("/report "..idkilera.." "..prichina)
				prinyatrep = false
			end)
			end
			message = message:gsub("РїСЂРёРЅСЏР»СЂРµРї", "Принял запрос на репорт")
			if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
			return {color, message}
		end
		if message:find("PALЕRIDERS") and message:find("РїСЂРёРЅСЏР»СЂРµРї") then
			if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
			message = message:gsub("РїСЂРёРЅСЏР»СЂРµРї", "Принял запрос на репорт")
			return {color, message}
		end
	if message:find('^ Сначала нужно надеть маску') then
		eventThreadCreate(function()
			wait(888)
			fastMask()
		end)
	end
		 if message:find("припарковал") and message:find("из слота (%d+)") then

            local slotStr = message:match("из слота (%d+)")

            efcs.blocked_slots[tonumber(slotStr)] = os.time() + 10 
            -- Разблокировка произойдет автоматически, когда os.time() превысит значени
        end

		if message:find("Жалоба от "..mynick()) and config.data[mynick()].autoreport.status then
			autoreport_time = os.time()
			return true
		end
		if message:find("Команда доступна с 6 ранга")  and bflooder then
			bflooder = false
			msg((config.data[mynick()].language.number == 1 and 'Автокаптер остановлен.' or 'Flooder has stopped.'))
		end
    local weapon, left = message:match("из сейфа %d+ пт%. ([%w]+)%. Осталось:%s*(%d+)")
	local left2, weapon2 = message:match("в сейф (%d+) пт%. (.+)")
	if weapon2 and left2 then

        left2 = tonumber(left2)

        if weapon2 == "Deagle" then
            renderpatron.FamilySafeInfo.de = renderpatron.FamilySafeInfo.de + left2
        elseif weapon2 == "AK47" then
            renderpatron.FamilySafeInfo.ak = renderpatron.FamilySafeInfo.ak + left2
        elseif weapon2 == "M4" then
            renderpatron.FamilySafeInfo.m4 = renderpatron.FamilySafeInfo.m4 + left2
        elseif weapon2 == "Shotgun" then
            renderpatron.FamilySafeInfo.sh = renderpatron.FamilySafeInfo.sh + left2
        elseif weapon2 == "Rifle" then
            renderpatron.FamilySafeInfo.ri = renderpatron.FamilySafeInfo.ri + left2
        end
    end
    if weapon and left then

        left = tonumber(left)

        if weapon == "Deagle" then
            renderpatron.FamilySafeInfo.de = left
        elseif weapon == "AK47" then
            renderpatron.FamilySafeInfo.ak = left
        elseif weapon == "M4" then
            renderpatron.FamilySafeInfo.m4 = left
        elseif weapon == "Shotgun" then
            renderpatron.FamilySafeInfo.sh = left
        elseif weapon == "Rifle" then
            renderpatron.FamilySafeInfo.ri = left
        end
    end

	if message:find("Доступно только для мафий") then
		if mflooder then
			mflooder = false
		end

		return true
	end

    --[[if string.find(message, "В сейфе нет столько пт.") and botovod.tatus_skill then
        shutdown()
    end]]
	if message:find("В инвентарь не поместится столько зел") and config.data[mynick()].fsafe.drugs_status then
		return false
	end

	 if (message:find("Вы здоровы") or message:find("В этом месте нет аптечек")) and autoheal then
		autoheal = false
		return false
	 end
    if message:find("PALЕRIDERS:%{......%} (.+) (%w+_%w+)%[(%d+)%]: inv (%d+)") and config.data[mynick()].small_tweaks.autoinv then
        eventThreadCreate(function()
            rankkk, nick, id_inva, wmy_id = message:match("PALЕRIDERS:%{......%} (.+) (%w+_%w+)%[(%d+)%]: inv (%d+)")
			if tonumber(wmy_id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
				idinvite = id_inva
			    check_rank = true
                autoinvited = true
			    				repeat
					wait(0)
				until os.clock() * 1000 - antiflood > 1000
			    sampSendChat('/members')
			end
		end)
		if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
        return true
    end

	if message:find("(%w+_%w+) шепнул%(а%): inv") and config.data[mynick()].small_tweaks.autoinv then
		eventThreadCreate(function()
			nicknamechebrika = message:match("(%w+_%w+) шепнул%(а%): inv")
			idinvite = sampGetPlayerIdByNickname(nicknamechebrika)
			if idinvite ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
				check_rank = true
                autoinvited = true
			    				repeat
					wait(0)
				until os.clock() * 1000 - antiflood > 1000
		    	sampSendChat('/members')
			end
		end)
		return true
	end
	if message:find("(%w+_%w+) шепнул%(а%): finv") and config.data[mynick()].small_tweaks.autoinv then
		eventThreadCreate(function()
			nicknamechebrika = message:match("(%w+_%w+) шепнул%(а%): finv")
							repeat
					wait(0)
				until os.clock() * 1000 - antiflood > 1000
	
		    sampSendChat('/finvite ' .. sampGetPlayerIdByNickname(nicknamechebrika))
		end)
		return true
	end
	if message:find("В этом месте нет аптечек") and healme then
		healme = false
		autoheal = false
	end
	if message:find("Вам необходимо состоять в семье") and fam_check then
		thisScript():unload()
	end
	if message:find("В инвентарь не поместится столько наркотиков. Доступно для хранения: (%d+)") then
		take_d = message:match("В инвентарь не поместится столько наркотиков. Доступно для хранения: (%d+)")
		config.data[mynick()].fsafe.take_drugs = take_d
		config_save(config.data)
	end


	if message:find("Отправитель: Контрабандист") and color == -65366 or message:find("Контрабандист") and color == -858993409 then
		if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.smuggler then
			return false
		end
	end

	if message:find("Несите ящик в фургон") and truck_flooder then
		eventThreadCreate(function()
			truck_choice = true
		end)
	end
	if message:find("Фургон заполнен") and truck_flooder then
		truck_flooder = false
	end
	if message:find("Несите канистру в фургон") and truck_flooder then
		eventThreadCreate(function()
			truck_choice = true
		end)
	end
	if message:find("Вы уронили ящик") and truck_flooder then
		eventThreadCreate(function()
			truck_choice = false
		end)
	end
	if message:find("Вы уронили канистру") and truck_flooder then
		eventThreadCreate(function()
			truck_choice = false
		end)
	end
	if message:find("Вы положили в фургон") and truck_flooder then
		eventThreadCreate(function()
			truck_choice = false
		end)
	end


	if message:find("припарковал") and message:find("из слота") or message:find("убрал") and message:find("слот") or message:find("Транспортное средство используется") then
		if message:find("припарковал") then
			parking_time = os.time()
		end
		if status_spawncar[0] or config.data[mynick()].small_tweaks.spawncar then
		    return false
		end
	end

	if message:find("(.+) (%w+_%w+) взял из сейфа (%d+) пт.") and status_takegun[0] or message:find("(.+) (%w+_%w+) взял из сейфа (%d+) пт.") and config.data[mynick()].small_tweaks.takegun or message:find("(.+) (%w+_%w+) взяла из сейфа (%d+) пт.") and status_takegun[0] or message:find("(.+) (%w+_%w+) взяла из сейфа (%d+) пт.") and config.data[mynick()].small_tweaks.takegun then
		return false
	end

	if message:find("РєСѓ Р°Р»Р»") and (message:find("PALЕRIDERS:") or message:find("RTC:")) then
		s, a, b, c = string.match(message, "(.+) (.+) (%w+_%w+)%[(%d+)%]")
		if config.data[mynick()] ~= nil and config.data[mynick()].squad.players then 
			if check_table(pale_list_ranks, a) then
				for k, v in pairs(pale_list_ranks) do
					if v == a then
						if k >= tonumber(config.data[mynick()].squad.rank + 1) then
							sampAddChatMessage("{C0C0C0}"..s.." {FFFFFF}"..a.." " .. b .. " подключился к серверу!", -1) 
						end
					end
				end
			elseif check_table(two_name, a) then
				for k, v in pairs(two_name) do
					if v == a then
						if k >= tonumber(config.data[mynick()].squad.rank + 1) then
							sampAddChatMessage("{20214F}"..s.." {FFFFFF}"..a.." " .. b .. " подключился к серверу!", -1) 
						end
					end
				end
		    end
		end
		zaxod = false
		return false
	end

	if message:find("Р±Р± Р°Р»Р»") and (message:find("PALЕRIDERS:") or message:find("RTC:"))then
		s, a, b, c = string.match(message, "(.+) (.+) (%w+_%w+)%[(%d+)%]")
		if config.data[mynick()] ~= nil and config.data[mynick()].squad.players then
			if check_table(pale_list_ranks, a) then
				for k, v in pairs(pale_list_ranks) do
					if v == a then
						if k >= tonumber(config.data[mynick()].squad.rank + 1) then
							sampAddChatMessage("{C0C0C0}"..s.." {FFFFFF}"..a.." " .. b .. " отключился от сервера.", -1) 
						end
					end
				end
			elseif check_table(two_name, a) then
				for k, v in pairs(two_name) do
					if v == a then
						if k >= tonumber(config.data[mynick()].squad.rank + 1) then
							sampAddChatMessage("{20214F}"..s.." {FFFFFF}"..a.." " .. b .. " отключился от сервера.", -1) 
						end
					end
				end
			end
		end
		return false
	end

    if string.find(message, "ID: (%d+) | (%d+):(%d+) (%d+).(%d+).(%d+) | (%w+_%w+)(.+): (.+)%[(%d+)%]") and check_rank then
        idbv, hourbv, minbv, dbv, mbv, ybv, nicbvk, vbv, name_rankldi, rankldi = string.match(message, "ID: (%d+) | (%d+):(%d+) (%d+).(%d+).(%d+) | (%w+_%w+)(.+): (.+)%[(%d+)%]")

        if nicbvk == mynick() then
		 	if tonumber(rankldi) >= 7 and otkritwl then
				eventThreadCreate(function()
				repeat
					wait(0)
				until os.clock() * 1000 - antiflood > 1000
				  if (time_open - time_wl) <= 0 then
				    random_number = math.random(0, 500)
					wait(random_number)
					sampSendChat("/fc РїСЂРёРЅСЏР»")
				  end
					otkritwl = false
				end)
			end

            if tonumber(rankldi) >= 6 and autoinvited and idinvite ~= 0 then
                eventThreadCreate(function()
					repeat
				        wait(0)
			        until os.clock() * 1000 - antiflood > 1000
                    sampSendChat("/invite "..idinvite)
					table.insert(lictgiverank, idinvite)
                    idinvite = 0
                end)
                autoinvited = false
            end
        end
        return false
    end

 --   if #message > 0 and check_rank and not message:find("ID: (%d+) | (%d+):(%d+) (%d+).(%d+).(%d+) | (%w+_%w+)(.+): (.+)%[(%d+)%]") then return false end
	--msg(message)
	if message == " " or message == "  " or message == "  " and check_rank then
		return false
	end
     if (message:find("Член") or message:find("Всего")) and check_rank then

		return false
	 end
	if message:find("wl pale") then
	if  message:find("PALЕRIDERS") then
		if config.data[mynick()] ~= nil and config.data[mynick()].LeaderManagement.warehouse_request then
		eventThreadCreate(function()
			open_sklad = true 
			time_wl = os.time()
			check_rank = true
            otkritwl = true
			repeat
				wait(0)
			until os.clock() * 1000 - antiflood > 1000
			sampSendChat('/members')
		end)
	   end
	end
	if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
    end
    if message:find("PALЕRIDERS") and message:find("РїСЂРёРЅСЏР»") and config.data[mynick()].LeaderManagement.warehouse_request and not message:find("РїСЂРёРЅСЏР»СЂРµРї") then
		eventThreadCreate(function()
		if not message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) and open_sklad then
			time_open = os.time()
			open_sklad = false
		elseif message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) and open_sklad then
			time_open = os.time()
			repeat
			    wait(0)
			until os.clock() * 1000 - antiflood > 1000
			sampSendChat("/warelock")
			open_sklad = false
		end
	    end)
		message = message:gsub("РїСЂРёРЅСЏР»", "Принял запрос на открытие склада")
		if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat then return false end
		return {color, message}
	elseif  message:find("PALЕRIDERS") and message:find("РїСЂРёРЅСЏР»") and not message:find("РїСЂРёРЅСЏР»СЂРµРї") then
		if config.data[mynick()] ~= nil and config.data[mynick()].small_tweaks.otkat  then return false end
		message = message:gsub("РїСЂРёРЅСЏР»", "Принял запрос на открытие склада")
		return {color, message}
	end

--pipirkka

    if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))).." передал (.+) (%w+_%w+)") and not message:find("семьи") and (config.data[mynick()].small_tweaks.autogiverank or config.data[mynick()].small_tweaks.pautogiverank) then
       _, nickname_ranka = message:match("передал (.+) (%w+_%w+)")
	   		eventThreadCreate(function()                 
			repeat
                wait(0)
             until os.clock() * 1000 - antiflood > 1000
	   if tonumber(inlictfunc(lictgiverank, nickname_ranka)) > -1 then
		if getCharModel(PLAYER_PED) == 254 or getCharModel(PLAYER_PED) == 247 or getCharModel(PLAYER_PED) == 248 or getCharModel(PLAYER_PED) == 100 then
		   sampSendChat("/giverank " ..inlictfunc(lictgiverank, nickname_ranka) .. " " .. 5)
		else
			sampSendChat("/giverank " ..inlictfunc(lictgiverank, nickname_ranka) .. " " .. 6)
		end
	    elseif config.data[mynick()].small_tweaks.pautogiverank then
		if getCharModel(PLAYER_PED) == 254 or getCharModel(PLAYER_PED) == 247 or getCharModel(PLAYER_PED) == 248 or getCharModel(PLAYER_PED) == 100 then
		   sampSendChat("/giverank " ..sampGetPlayerIdByNickname(nickname_ranka).. " " .. 5)
		else
			sampSendChat("/giverank " ..sampGetPlayerIdByNickname(nickname_ranka) .. " " .. 6)
		end
	    end
	end)
	end




	if message:find('%[Внимание%]: (.+) спровоцировала войну') or message:find('Ваша фракция уже в состоянии войны') then
		if bflooder then
			msg((config.data[mynick()].language.number == 1 and 'Автокаптер остановлен.' or 'Flooder has stopped.'))
			bflooder = false
		end
		if mflooder then
			msg((config.data[mynick()].language.number == 1 and 'Автокаптер остановлен.' or 'Flooder has stopped.'))
			mflooder = false
		end
		capture_status = true
		if AutoCapterstart then
	     	AutoCapterstart = false
		end
	end


	if message:find('Открыл %{......%}доступ к складу') then
		if config.data[mynick()] ~= nil and config.data[mynick()].autogetguns.status and not get_guns_status then
			get_guns_status = true
		end
	end

	if string.find(message, "Вы должны находиться в привязанном к семье доме") and color == -1347440726 then
		fclick = false
		fsafes = false
	end

    if (string.find(message, "Семейный склад закрыт")) or (string.find(message, "Вы не можете взять со склада более")) or (string.find(message, "Недостаточно патронов")) then
		fclick = false
		fsafes = false
		fsak = false
		sfm4 = false
		sfde = false
		fsri = false
		fssh = false
		return true
	end

    if (message:find("Пин%-код не совпал") or message:find('Не флуди!') or message:find("Данный дом не привязан к Вашей семье")) and color == -858993409 and fsafes then
		eventThreadCreate(function()
			wait(500)
			inputFsafeCode = false
			--[[
			if not helpfordnk then
			    sampSendChat("/fsafe")
			else 
				sampSendChat("/safe")
			end
			]]
		end)
    end

    if message:find("Вы далеко от сейфа") and color == -86 then
		fsafes = false
		inputFsafeCode = false
		fclick = false
	end

  --[[  if message:find("SMS: /warelock. Получатель: (%w+_%w+)%[(%d+)%]") or message:find("SMS: /clear. Получатель: (%w+_%w+)%[(%d+)%]") or message:find("SMS: /giverank (%d+) (%d+). Получатель: (%w+_%w+)%[(%d+)%]") or message:find("SMS: /uninvite (%d+) (.+). Получатель: (%w+_%w+)%[(%d+)%]") or message:find("SMS: /invite (%d+). Получатель: (%w+_%w+)%[(%d+)%]") then 
        if hidesms then
            msg("Запрос отправлен!")
            return false
        end
    end

    if message:find("(%w+_%w+) достает мобильник") and hidesms then 
        return false
    end

    if message:find("Сообщение доставлено")  and hidesms then 
        hidesms = false
        return false
    end
]]	
    if message:find("Склад закрыт") then
        if gg_evolve.getgun  then
            gg_evolve.getgun = false
        end
    end

    if message:find("Вы сыты") then
        gg_evolve.getgun = false
        gg_evolve.getgun_st = 0
    end

    if check_boostinfo == 2 and message:find("Действует до") then
		return false
	end

	if (message == " (( Здоровье не пополняется чаще, чем раз в минуту ))" or message == ' (( Здоровье можно пополнить не чаще, чем раз в минуту ))') then not_drugs_timer = true end
	
	if string.find(message, mynick()) then
		if string.find(message, "употребил%(а%) наркотик") then
			if not not_drugs_timer then drugs_timer = os.time() else not_drugs_timer = false end
		end
		if string.find(message, "оружие из материалов") then
			check_get_mats = true
		end
	end

	if message:find('выбросил') and (message:find('аркотики') or message:find('атериалы')) and string.find(message, my_name) then
		check_get_mats = true
	end

	if message:find('Вы взяли несколько комплектов') then
		check_get_mats = true
	end

	if message:find('Вы ограбили дом! Наворованный металл можно сдать около порта.') then
		check_get_mats = true
	end

	if message:find('У вас (%d+)/500 материалов с собой') then
		config.data[mynick()].drugtimer.mats = message:match('У вас (%d+)/500 материалов с собой')
		config_save(config.data)
	end

	if string.find(message, " %(%( Остаток: (%d+) грамм зелёной растительности %)%)") then
		config.data[mynick()].drugtimer.drugs = string.match(message, " %(%( Остаток: (%d+) грамм зелёной растительности %)%)")
		config.data[mynick()].fsafe.drugs = string.match(message, " %(%( Остаток: (%d+) грамм зелёной растительности %)%)")
		config_save(config.data)
	end

	if message:find("Вы взяли (%d+) наркотиков") then
		addnarko = message:match("Вы взяли (%d+) наркотиков")
		config.data[mynick()].drugtimer.drugs = tonumber(config.data[mynick()].drugtimer.drugs + addnarko)
		config.data[mynick()].fsafe.drugs = tonumber(config.data[mynick()].fsafe.drugs + addnarko)
		config_save(config.data)
	end

    if string.find(message, " %(%( Здоровье пополнено до: (%d+) %)%)") then
		if not not_drugs_timer and getCharHealth(PLAYER_PED) > 0 then drugs_timer = os.time() else not_drugs_timer = false end
		config_save(config.data)
	end

	if string.find(message, '%(%( Остаток: (%d+) материалов %)%)') then
		config.data[mynick()].drugtimer.mats = message:match('%(%( Остаток: (%d+) материалов %)%)')
		config_save(config.data)
	end

	if message:find('Вы купили %d+ грамм наркотиков за %d+ вирт %(У вас есть (%d+) грамм%)') then
		config.data[mynick()].drugtimer.drugs = message:match('Вы купили %d+ грамм наркотиков за %d+ вирт %(У вас есть (%d+) грамм%)')
		config_save(config.data)
	end

	if message:find('Вы купили (%d+) грамм наркотиков за %d+ вирт у .+') then
		local s1 = message:match('Вы купили (%d+) грамм наркотиков за %d+ вирт у .+')
		config.data[mynick()].drugtimer.drugs = tonumber(s1) + config.data[mynick()].drugtimer.drugs
		config_save(config.data)
	end

    if os.time() - efcs.start < 5 then
        if message:find(getLocalPlayerNickname()) and message:find("припарковал транспорт") then
            efcs.start = 9999
        end
    end

	if string.find(message, "Не флуди!") and check_squad_members then
    	return false
	end
end
end

function inlictfunc(macciv, nickame_dyraka)

	for k,v in pairs(macciv) do
		if sampIsPlayerConnected(v) then
		   if sampGetPlayerNickname(v) == nickame_dyraka then
			return v
		   end
		end
	end
	return -1
end
--------------------------------------------------------------------------------
------------------------------------onSetInterior-------------------------------
--------------------------------------------------------------------------------

sampev.onSetInterior = function(id)
	nawa_inta = id
    if id == 0 then
        efcs_autoexit = false
    end
end
--------------------------------------------------------------------------------
------------------------------------#Пользователи--------------------------------
--------------------------------------------------------------------------------
if status_requests then
requests = require 'requests'
end
-- Единоразовая отправка данных при заходе в игру
function sendJoinNotification()
    serverIP = sampGetCurrentServerAddress()
    local localUnixTime = os.time() -- Получаем текущее время на ПК (в секундах)

    eventThreadCreate(function()
        local url = string.format("%spte_online/%s.json", FIREBASE_URL, myNick)
        --msg(myNick)
        -- Записываем IP сервера и время входа os.time()
        local payload = { 
            data = string.format('{"last_seen": %d, "server": "%s"}', localUnixTime, serverIP) 
        }
        
        pcall(function() 
            requests.patch(url, payload) 
        end)
    end)
end

-- Вспомогательная функция для безопасного поиска ID игрока по его нику на сервере
function getPlayerIdByNickname2(name)
    for i = 0, 1000 do
        if sampIsPlayerConnected(i) then
            local currentName = sampGetPlayerNickname(i)
            if currentName == name then
                return true, i
            end
        end
    end
    return false, -1
end

-- Автоматическое скачивание, фильтрация еженедельного списка и проверка ОНЛАЙНА
function updateOnlinePlayers()
    eventThreadCreate(function()
        local url = string.format("%spte_online.json", FIREBASE_URL)
        local status, response = pcall(function() return requests.get(url) end)
        
        if not status or not response or response.status_code ~= 200 or response.text == "null" or response.text == "" then
            hudPlayers = {} 
            return
        end

        local tempTable = {}
        local currentLocalTime = os.time() -- Текущее время для сверки

        -- Парсим JSON блоки игроков
        for nick, block in response.text:gmatch('"(.-)":%s*({.-})') do
            local lastSeenStr = block:match('"last_seen":%s*(%d+)')
            local server = block:match('"server":%s*"(.-)"')
            if lastSeenStr and server then
                local lastSeen = tonumber(lastSeenStr)
                
                -- Вычисляем разницу во времени между входом игрока и текущим моментом
                local diffSeconds = currentLocalTime - lastSeen

                -- 1. УСЛОВИЕ: Если игрок заходил со скриптом в течение последней недели
                if diffSeconds <= SECONDS_IN_WEEK then
                    table.insert(table_nick_uc, nick)
                    local result, sId = getPlayerIdByNickname2(nick)
                    
                    if result then
                        -- Добавляем игрока со скриптом. Ник белый, а ID в скобках — серый ({AFAFAF})
                        table.insert(tempTable, string.format("%s[%d]", nick, sId))

                    end
                end
            end
        end

        -- Обновляем глобальную таблицу для отрисовки
        hudPlayers = tempTable
    end)
end

--[[function drawHUD()
    -- Координаты HUD на экране
    local startX = config.data[mynick()].users.x_pos
    local startY = config.data[mynick()].users.y_pos
    local lineHeight = config.data[mynick()].users.line

    -- 1. Рисуем главный заголовок в самом верху
    renderFontDrawText(users_font, config.data[mynick()].users.wapka2, startX, startY, 0xFFFFFFFF) -- Зеленый цветFF00FF00

    local nextLineIndex = 1

    -- 2. Рисуем список игроков сразу под заголовком
    for i, playerInfo in ipairs(hudPlayers) do
        local currentY = startY + (i * lineHeight)
       -- renderFontDrawText(users_font, playerInfo, startX, currentY, 0xFFFFFFFF) -- Белый цвет по умолчанию
		if config.data[mynick()] ~= nil and config.data[mynick()].users.int == 0 then
			renderFontDrawText(users_font, playerInfo, startX, currentY, 0xFFFFFFFF)
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 1 then 
			renderFontDrawText(users_font, playerInfo, startX, currentY, argb2abgr(4286070325))
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 2 then
			--("0xFF%s"):format(('%06X'):format(bit.band(sampGetPlayerColor(playerInfo:match("%[(%d+)%]")), 0xFFFFFF)))
			renderFontDrawText(users_font, playerInfo, startX, currentY, ("0xFF%s"):format(('%06X'):format(bit.band(sampGetPlayerColor(playerInfo:match("%[(%d+)%]")), 0xFFFFFF))))
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 3 then
			renderFontDrawText(users_font, playerInfo, startX, currentY, argb2abgr(config.data[mynick()].users.color))
		end
        nextLineIndex = i + 1
	end
	if config.data[mynick()] ~= nil and config.data[mynick()].users.online_status then
    -- 3. Рисуем счетчик "Online: [число]" строго ПОД списком игроков
    local bottomY = startY + (nextLineIndex * lineHeight)
    renderFontDrawText(users_font, (config.data[mynick()].users.language == 0 and string.format("Online: %d", #hudPlayers) or string.format("Онлайн: %d", #hudPlayers)), startX, bottomY, 0xFFFFFFFF) 
	end
end
]]
--[[function UsersFunc()
	while true do wait(0)
		if config.data[mynick()] ~= nil and config.data[mynick()].users.status then
		    drawHUD()
		end  
	end
end]]


--[[function Users2Func()
	while true do wait(0)
	if config.data[mynick()] ~= nil and config.data[mynick()].users.status then
	   local tempTable2 = {}
       for k, v in pairs(table_nick_uc) do
		    local result, sId = getPlayerIdByNickname2(v)
            if result then
                table.insert(tempTable2, string.format("%s[%d]", v, sId))
            end
	   end
	   hudPlayers = tempTable2
	   wait(10000)
	end
    end
end
]]
function users_draw()
--[[	    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображние пользователей скрипта" or "Displaying script users"), status_smu, function()
		config.data[mynick()].users.status = not config.data[mynick()].users.status
		config_save(config.data)
	end, true, function() end)

	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Отображние онлайна пользователей" or "Displaying online users"), status_users_online, function()
		config.data[mynick()].users.online_status = not config.data[mynick()].users.online_status
		config_save(config.data)
	end, true, function() end)

	if config.data[mynick()] ~= nil and config.data[mynick()].users.online_status or status_squad_online[0] then
		local squad_raskladka = (config.data[mynick()].users.language == 0 and (config.data[mynick()].language.number == 1 and "Английский" or "English") or (config.data[mynick()].language.number == 1 and "Русский" or "Russian"))
		if imgui.Button((config.data[mynick()].language.number == 1 and "Текст рендера онлайна: "..squad_raskladka.."##multi.online.squad" or "Online render text: "..squad_raskladka.."##multi.online.squad"), imgui.ImVec2(390,20)) then
			config.data[mynick()].users.language = config.data[mynick()].users.language + 1
			if config.data[mynick()] ~= nil and config.data[mynick()].users.language >= 2 then
				config.data[mynick()].users.language = 0
			end
			config_save(config.data)
		end
	end
     if imgui.Button((config.data[mynick()].language.number == 1 and "Сменить позицию" or "Change position"), imgui.ImVec2(390,20)) then pos_uc = true end

	imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Цвет" or "Color")), int_uc, combo_uc, #combouc)
	--imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Надпись сверху" or "Inscription on top")), int_namesq, squad_combo, #squadcombo)
	--imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Сортировка игроков" or "Sorting players")), int_squad2, combo_squad2, #combosquad2)
	imgui.InputText((config.data[mynick()].language.number == 1 and "Надпись сверху##24" or "Inscription on top##2"), ucwapka_font, sizeof(ucwapka_font))
	imgui.InputText((config.data[mynick()].language.number == 1 and "Название шрифта" or "Font name"), usfont_sfont, sizeof(usfont_sfont))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Размер шрифта" or "Font size"), usfont_ssize, sizeof(usfont_ssize))
    imgui.InputText((config.data[mynick()].language.number == 1 and "Стиль шрифта" or "Font style"), usfont_flag, sizeof(usfont_flag))
	imgui.InputText((config.data[mynick()].language.number == 1 and "Расстояние строк" or "Distance string"), usfont_line, sizeof(usfont_line))
	if config.data[mynick()] ~= nil and config.data[mynick()].users.int == 3 or int_uc[0] == 3 then if imgui.ColorEdit4((config.data[mynick()].language.number == 1 and "Цвет ников" or "Nickname color"), castom_color_squad) then config.data[mynick()].users.color = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(castom_color_squad[0], castom_color_squad[1], castom_color_squad[2], castom_color_squad[3])) config_save(config.data) end end
	if imgui.Button((config.data[mynick()].language.number == 1 and "Сбросить настройки##m2" or "Reset settings##m3"), imgui.ImVec2(390,25)) then
		int_uc[0] = 2
		config.data[mynick()].users.x_pos = PosUcX
		config.data[mynick()].users.y_pos = PosUcY
		config.data[mynick()].users.font = 'Arial'
		config.data[mynick()].users.size = 12
		config.data[mynick()].users.line = 19
        config.data[mynick()].users.flag = 5
		config.data[mynick()].users.int = 2
		config.data[mynick()].users.color = 4294967295
		config.data[mynick()].users.language = 0
		config.data[mynick()].users.wapka2 = "Пользователи онлайн:"
		config_save(config.data)
		usfont_sfont = imgui.new.char[256](u8("Arial"))
        usfont_ssize = imgui.new.char[256](u8(11))
        usfont_flag = imgui.new.char[256](u8(5))
		status_squad_online[0] = false		
		ucwapka_font = imgui.new.char[256](config.data[mynick()].users.wapka2)
		renderReleaseFont(users_font)
		users_font = renderCreateFont(config.data[mynick()].users.font, config.data[mynick()].users.size, config.data[mynick()].users.flag)
    end

	if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить##multi.squad.save3" or "Save##multi.squad.save3"), imgui.ImVec2(390,25)) then
	--	config.data[mynick()].squad.name_squad = int_namesq[0]
		--config.data[mynick()].squad.rank = int_squad2[0]
		config.data[mynick()].users.int = int_uc[0]
		config.data[mynick()].users.font = str(usfont_sfont)
		config.data[mynick()].users.size = tonumber(str(usfont_ssize))
		config.data[mynick()].users.flag = tonumber(str(usfont_flag))
		config.data[mynick()].users.line = tonumber(str(usfont_line))
		config.data[mynick()].users.wapka2 = str(ucwapka_font)
		config_save(config.data)
		renderReleaseFont(users_font)
		users_font = renderCreateFont(config.data[mynick()].users.font, config.data[mynick()].users.size, config.data[mynick()].users.flag)
    end]]
--	    renderFontDrawText(users_font, config.data[mynick()].users.wapka2, startX, startY, 0xFFFFFFFF) -- Зеленый цветFF00FF00
		imgui.Text(config.data[mynick()].users.wapka2)
		for i, playerInfo in ipairs(hudPlayers) do
		imgui.Text(playerInfo)
		end
		imgui.Text(string.format("Online: %d", #hudPlayers))
    -- 2. Рисуем список игроков сразу под заголовком
  --[[  for i, playerInfo in ipairs(hudPlayers) do
        local currentY = startY + (i * lineHeight)
       -- renderFontDrawText(users_font, playerInfo, startX, currentY, 0xFFFFFFFF) -- Белый цвет по умолчанию
		if config.data[mynick()] ~= nil and config.data[mynick()].users.int == 0 then
			renderFontDrawText(users_font, playerInfo, startX, currentY, 0xFFFFFFFF)
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 1 then 
			renderFontDrawText(users_font, playerInfo, startX, currentY, argb2abgr(4286070325))
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 2 then
			--("0xFF%s"):format(('%06X'):format(bit.band(sampGetPlayerColor(playerInfo:match("%[(%d+)%]")), 0xFFFFFF)))
			
		elseif config.data[mynick()] ~= nil and config.data[mynick()].users.int == 3 then
			renderFontDrawText(users_font, playerInfo, startX, currentY, argb2abgr(config.data[mynick()].users.color))
		end
        nextLineIndex = i + 1
	end]]
	--if config.data[mynick()] ~= nil and config.data[mynick()].users.online_status then
    -- 3. Рисуем счетчик "Online: [число]" строго ПОД списком игроков
   -- local bottomY = startY + (nextLineIndex * lineHeight)
 --   renderFontDrawText(users_font, (config.data[mynick()].users.language == 0 and string.format("Online: %d", #hudPlayers) or string.format("Онлайн: %d", #hudPlayers)), startX, bottomY, 0xFFFFFFFF)

end

function ucFunc()
	while true do wait(0)
		if pos_uc then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].users.x_pos = curX
			config.data[mynick()].users.y_pos = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_uc = false
			   config_save(config.data)
			end
		end

		if pos_ptr then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].render_gun.x = curX
			config.data[mynick()].render_gun.y = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_ptr = false
			   config_save(config.data)
			end
		end


		if pos_kvb then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].bikerlines.kv_x = curX
			config.data[mynick()].bikerlines.kv_y = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_kvb = false
			   config_save(config.data)
			end
		end


				if pos_kvm then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].mafialines.kv_x = curX
			config.data[mynick()].mafialines.kv_y = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_kvm = false
			   config_save(config.data)
			end
		end
	end
end
--------------------------------------------------------------------------------
------------------------------------#onShowDialog--------------------------------
--------------------------------------------------------------------------------
dialog_delay = 75
local efcs_event = 0
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	local text2 = text:gsub("%{......%}", "")
	if title:find("Регистрация") and title:find("Приглашение") then
        sampSendDialogResponse(dialogId, 1, 0, "#pale")
		return false
	end
    if load_all then
		if text:find("действительно хотите") and text:find("снять")  and text:find("маску") and unmack2 then
			sampSendDialogResponse(dialogId, 1, 1, _)
			unmack2 = false
		end

	if dialogId == 24700 and fmask then
		if text:find('Надеть') or text:find('Снять') then
			sampSendDialogResponse(dialogId, 1, 1, _)
		else
			sampSendDialogResponse(dialogId, 0, 0, _)
		end
		sampSendClickTextdraw(90)
		fmask = false
		eventThreadCreate(function()                 
			repeat
                wait(0)
             until os.clock() * 1000 - antiflood > 1000
			sampSendChat('/mask') 
		end) 
		if pmask_cancel ~= nil then  sampSendClickTextdraw(pmask_cancel) end
        --sampSendClickTextdraw(pmask_cancel)
		return false
	end


   --[[ if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Приветствуем вас в Автошколе") then  
        sampSendDialogResponse(dialogId, 1, 0, 0)
        return true	
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Какие документы должен иметь при себе водитель?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Что должен сделать водитель при выезде с прилегающей территории?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Как должен действовать водитель при приближении спецтранспорта с маячками?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("В каком случае нужно уступить дорогу?") then
        sampSendDialogResponse(dialogId, 1, 2, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Что запрещено делать водителю во время движения?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("По какой стороне дороги должно осуществляться движение в штате?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Когда запрещено управлять транспортным средством?") then
        sampSendDialogResponse(dialogId, 1, 2, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Где разрешена стоянка транспортных средств в населенных пунктах?") then
        sampSendDialogResponse(dialogId, 1, 4, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Какое действие запрещено водителю в отношении организованных колонн?") then
        sampSendDialogResponse(dialogId, 1, 3, 0)
        return true
	end

    if config.data[mynick()] ~= nil and config.data[mynick()].autoschool.status and dialogId == 32700 and text2:find("Где запрещено движение транспортных средств?") then
        sampSendDialogResponse(dialogId, 1, 4, 0)
        return true
	end]]
    --------------------------СНЯТЬ СО СЧЁТА [0] Баланс: $950000
    if withdraw.process and title:find('{FFFFFF}Меню | {ae433d}Банкомат') then
        local current_ballance = text:match('%[0%] Баланс: %$(%d+)\n')
        if tonumber(current_ballance) >= withdraw.summ then
            lua_thread.create(function()
                wait(dialog_delay)
                n = 0
                for line in string.gmatch(text, "[^\r\n]+") do
                    if line:find('%[1%] Снять со счета') then
                        sampSendDialogResponse(dialogId,1,n,-1)
                        return
                    end
                    n = n+1
                end
            end)
        else
            withdraw.process = false
            withdraw.summ = 0
            sampAddChatMessage('Ошибка! У вас недостаточно денег на банкомате!', 0xABCDEF)
            return
        end
    end

    if withdraw.process and title:find('{FFFFFF}Снять со счета | {ae433d}Банкомат') then

        lua_thread.create(function()
            wait(dialog_delay)
            local sum = 0
            if withdraw.summ <= 100000 then
                sum = withdraw.summ
            elseif withdraw.summ > 100000 then
                sum = 100000
            end
            sampSendDialogResponse(dialogId,1,-1,sum)
            withdraw.summ = withdraw.summ - sum
            if withdraw.summ <= 0 then
                withdraw.process = false
                withdraw.summ = 0
                sampAddChatMessage('Снятие денег завершено!', 0xABCDEF)
            end
        end)

    end
    --------------------------------------------------------------------------
    -----------------------------------Положить на счёт
    if deposit.process and title:find('{FFFFFF}Меню | {ae433d}Банкомат') then
        lua_thread.create(function()
            wait(dialog_delay)
            local n = 0
            for line in string.gmatch(text, "[^\r\n]+") do
                if line:find('%[2%] Положить на счет') then
                    sampSendDialogResponse(dialogId,1,n,-1)
                    return
                end
                n = n+1
            end
        end)
    end

    if deposit.process and title:find('{FFFFFF}Положить на счет | {ae433d}Банкомат') then

        lua_thread.create(function()
            wait(dialog_delay)
            local sum = 0
            if deposit.summ <= 100000 then
                sum = deposit.summ
            elseif deposit.summ > 100000 then
                sum = 100000
            end
            sampSendDialogResponse(dialogId,1,-1,sum)
            deposit.summ = deposit.summ - sum
            if deposit.summ <= 0 then
                deposit.process = false
                deposit.summ = 0
                sampAddChatMessage('Пополнение счёта завершено!', 0xABCDEF)
            end
        end)

    end
    --------------------------------------------------------------------------
    -----------------------------Перевод средств
    if transfer.process and title:find('{FFFFFF}Меню | {ae433d}Банкомат') then
        lua_thread.create(function()
            wait(dialog_delay)
            local n = 0
            for line in string.gmatch(text, "[^\r\n]+") do
                if line:find('%[5%] Перевести игроку с наличных') then
                    sampSendDialogResponse(dialogId,1,n,-1)
                    return
                end
                n = n+1
            end
        end)
    end

    if transfer.process and title:find('{FFFFFF}Перевести игроку с наличных | {ae433d}Банкомат') then
        lua_thread.create(function()
            wait(dialog_delay)
            local sum = 0
            if transfer.summ <= 100000 then
                sum = transfer.summ
            elseif transfer.summ > 100000 then
                sum = 100000
            end
            sampSendDialogResponse(dialogId,1,-1,sum..' '..transfer.nick)
            transfer.summ = transfer.summ - sum
            if transfer.summ <= 0 then
                transfer.summ = 0
                transfer.nick = ''
                transfer.process = false
                sampAddChatMessage('Завершен перевод!', 0xABCDEF)
            end
        end)
    end
    --------------------------------------------------------------------------
	if title:find("Панель ") and fam_check then
        if not text:find("Наименование семьи %- %{......%}PALЕRIDERS") and not text:find("Наименование семьи %- %{......%}RTC") then
           thisScript():unload()
        end
		checkCapture()
		fam_check = false
		lua_thread.create(function() wait(25) sampCloseCurrentDialogWithButton(0) end)
	end

	if title:find("В сети: (%d+) | %{......%}Состав семьи") and (config.data[mynick()].squad.status or config.data[mynick()].pr.family) and not text:find("%{......%}Следующая страница") and text:find("Предыдущая") and netfmem then
		
		if help_squad then help_squad = false else help_pr = {} squad_members = {} squad_onlines = 0 end
        for line in text:gmatch("[^\r\n]+") do
            if line:find("(%w+_%w+)%[(%d+)%].+") then
			    nick_s, id_s, rank_squad_members = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
				if  tonumber(rank_squad_members) >= tonumber(config.data[mynick()].squad.rank + 1) then
					    squad_onlines = squad_onlines + 1
						color_squad[squad_onlines] = ('%06X'):format(bit.band(sampGetPlayerColor(id_s), 0xFFFFFF))
					    squad_members[squad_onlines] = string.format("%s[%s]", line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]"))
						nick_pr, _ = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
						help_pr[squad_onlines] = nick_pr
				end
            end
        end
		netfmem = false
		sampSendDialogResponse(dialogId, 0, 0, "")
		return false 
	end

	if title:find("В сети: (%d+) | %{......%}Состав семьи") and (config.data[mynick()].squad.status or config.data[mynick()].pr.family) and netfmem then
		onl = title:match("В сети: (%d+) | %{......%}Состав семьи")
		if tonumber(onl) <= 16 then
			if help_squad then help_squad = false else help_pr = {} squad_members = {} squad_onlines = 0 end
			for line in text:gmatch("[^\r\n]+") do
				if line:find("(%w+_%w+)%[(%d+)%].+") then
					nick_s, id_s, rank_squad_members = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
					if  tonumber(rank_squad_members) >= tonumber(config.data[mynick()].squad.rank + 1) then
							squad_onlines = squad_onlines + 1
							color_squad[squad_onlines] = ('%06X'):format(bit.band(sampGetPlayerColor(id_s), 0xFFFFFF))
							squad_members[squad_onlines] = string.format("%s[%s]", line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]"))
							nick_pr, _ = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
							help_pr[squad_onlines] = nick_pr
					end
				end
			end
		--	whitelist_names = help_pr
			netfmem = false
			sampSendDialogResponse(dialogId, 0, 0, "")
			return false 
	    end
	end
	if title:find("В сети: (%d+) | %{......%}Состав семьи") and (config.data[mynick()].squad.status or config.data[mynick()].pr.family) and text:find("%{......%}Следующая страница") and text:find("Предыдущая") and netfmem then
        for line in text:gmatch("[^\r\n]+") do
            if line:find("(%w+_%w+)%[(%d+)%].+") then
			    nick_s, id_s, rank_squad_members = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
				if tonumber(rank_squad_members) >= tonumber(config.data[mynick()].squad.rank + 1) then
                    squad_onlines = squad_onlines + 1
					color_squad[squad_onlines] = ('%06X'):format(bit.band(sampGetPlayerColor(id_s), 0xFFFFFF))
					squad_members[squad_onlines] = string.format("%s[%s]", line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]"))
					nick_pr, _ = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
					help_pr[squad_onlines] = nick_pr					
					if squad_onlines == 31 or squad_onlines == 46 then
						squad_onlines = squad_onlines - 1
					end

				end
            end
        end
		sampSendDialogResponse(dialogId, 1, 17, "")
		return false 
    end
	if title:find("В сети: (%d+) | %{......%}Состав семьи") and (config.data[mynick()].squad.status or config.data[mynick()].pr.family) and text:find("%{......%}Следующая страница") and not text:find("Предыдущая") and netfmem then
		squad_members = {}
		squad_onlines = 0
		help_squad = true
	    squad_members = {}
		help_pr = {}
        for line in text:gmatch("[^\r\n]+") do
            if line:find("(%w+_%w+)%[(%d+)%].+") then
			    nick_s, id_s, rank_squad_members = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
				if tonumber(rank_squad_members) >= tonumber(config.data[mynick()].squad.rank + 1) then
                    squad_onlines = squad_onlines + 1
					color_squad[squad_onlines] = ('%06X'):format(bit.band(sampGetPlayerColor(id_s), 0xFFFFFF))
					squad_members[squad_onlines] = string.format("%s[%s]", line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]"))
					nick_pr, _ = line:match("(%w+_%w+)%[(%d+)%].+%[(%d+)%]")
					help_pr[squad_onlines] = nick_pr					
					if squad_onlines == 16 then
						squad_onlines = squad_onlines - 1
					end

				end
            end
        end
		sampSendDialogResponse(dialogId, 1, 16, "")
		return false 
    end


	if title:find("Объявить войну за территорию") and biz_check then--  | %{......%}Семья
        biz_check = false
		lua_thread.create(function() wait(25) sampCloseCurrentDialogWithButton(0) end)
    end

    if dialogId == 10075 and title:find("Дом занят") then
		if text:find("Семья: %{......%}PALЕRIDERS") and config.data[mynick()].small_tweaks.exit then -- MIDGARD
        sampSendDialogResponse(dialogId, 1, 0, "")
        return false
		end
	end

    if title:find("Выход") and efcs_autoexit then
        sampSendDialogResponse(dialogId, 1, 0, "Выйти на улицу")
        return false
    end

	if title:find('Информация') or title:find('Карманы') then
		local nark, mats = false, false
		local arr = split(text, "\n")
		for i = 1, #arr do
			if arr[i]:find('Наркотики\t(%d+)') then
				config.data[mynick()].drugtimer.drugs = arr[i]:match('Наркотики\t(%d+)')
				nark = true
			end
			if arr[i]:find('Материалы\t(%d+)') then
				config.data[mynick()].drugtimer.mats = arr[i]:match('Материалы\t(%d+)')
				mats = true
			end
		end
		if not nark then config.data[mynick()].drugtimer.drugs = 0 end
		if not mats then config.data[mynick()].drugtimer.mats = 0 end
		config_save(config.data)

		if check_inventory == 2 or (check_inventory_time ~= nil and os.time() - check_inventory_time < 5) then
			check_inventory = 0
			check_inventory_time = os.time()
			sampSendDialogResponse(dialogId, 0, 0, "")
			return false
		end
	end

    if os.time() - efcs.start < 5 or efcs.start == 9999 then
        if title:find("Дом") then
            if efcs.start == 9999 then

				lua_thread.create(function() wait(50)
                sampCloseCurrentDialogWithButton(0)
                efcs.start = 0
			     end)
            else
                if config.data[mynick()] ~= nil and config.data[mynick()].fastcarfx.status_exit then
                    efcs_autoexit = true
				else
					efcs_autoexit = false
                end
                sampSendDialogResponse(dialogId,1,7,"")
            end
            --return false
        end

        if title:find("Перечень") then
            if efcs.start == 9999 then
                sampSendDialogResponse(dialogId,0,0,"")
            else
                local arr = split(text, "\n")
                if text:find("На парковке") then
                    local temporary_slot = 0 -- Счетчик реального номера слота в списке
                    for i = 1, #arr do
                        if arr[i]:find("На парковке") then
                            temporary_slot = temporary_slot + 1
                            
                            -- Проверяем, не заблокирован ли этот слот прямо сейчас
                            local block_time = efcs.blocked_slots[temporary_slot]

                            if efcs.blocked_slots[temporary_slot] == nil or (efcs.blocked_slots[temporary_slot] ~= nil and os.time() > block_time) then
                                -- Слот занят другим игроком, пропускаем его и ищем дальше
								sampSendDialogResponse(dialogId,1,i-2,"")
                            end
                        elseif arr[i]:find("Используется") then
                            -- Если строка занята, слот все равно увеличивается
                            temporary_slot = temporary_slot + 1
                        end
                    end
                else
					current_slot = 0
                    for i = 1, #arr do
                        if arr[i]:find("Используется") then
                            current_slot = current_slot + 1
                            
                            -- Проверяем, не заблокирован ли этот слот кем-то секунду назад
                            local block_time = efcs.blocked_slots[current_slot]
                            if not (block_time and os.time() < block_time) then
                                if efcs.list_remove[arr[i]] == nil then
                                    efcs.list_remove[arr[i]] = true
                                    sampSendDialogResponse(dialogId, 1, i-2, "")
                                    car_spawned = true
                                    return true
                                end
                            end
                        elseif arr[i]:find("На парковке") then
                            -- На случай непредвиденных изменений в списке, просто инкрементируем слот
                            current_slot = current_slot + 1
                        end
                    end
                end
            end
            sampCloseCurrentDialogWithButton(0)
           -- return false
        end


        if title:find("Подтверждение") and title:find("Парковка") then
            efcs.start = 9999
            sampSendDialogResponse(dialogId,1,0,"")
           --- return false
        end

        if title:find("Подтверждение") and title:find("Удаление семейного") then
            sampSendDialogResponse(dialogId,1,0,"")
           --- return false
        end
    end

    if gg_evolve.getgun then
        if title:find("Склад") and not title:find("Склад наркотиков") then
            if gg_evolve.getgun_st == 0 then
                gg_evolve.getgun_st = 1
                sampSendDialogResponse(dialogId,1,0,"")
                return true
            end
            if gg_evolve.getgun_st == 2 then
                gg_evolve.getgun_st = 0
                gg_evolve.getgun = false
                sampSendDialogResponse(dialogId,0,0,"")
                return true
            end
        end

        if title:find("Взять оружие со склада") then
            for i = 1, 8 do
                if gg_evolve.getgun_list[i][1] > 0 then
                    sampSendDialogResponse(dialogId,1,gg_evolve.getgun_list[i][2],"")
                    gg_evolve.getgun_list[i][1] = gg_evolve.getgun_list[i][1] - 1
                    return true
                end
            end
            gg_evolve.getgun_st = 2
			if config.data[mynick()] ~= nil and config.data[mynick()].getguns.autoheal then 
				healme = true
			end
            sampCloseCurrentDialogWithButton(0)
            return true
        end
    end

    if title:find("%{......%}Сейф | %{......%}Взять") and fsafes then
		sampSendDialogResponse(dialogId, 1, _, fsTakeAmount)
		fsTakeAmount = false
		nextFsGun = true
		--return false
	end

	if dialogId == 6053 and fslastd then
		fslastd = false
		fsafes = false
		lua_thread.create(function() wait(200) sampCloseCurrentDialogWithButton(0) end)
    end
end
end

function playAnim(name, nameLib, speed, loop, lockX, lockY, lockF)
	if not isCharInAnyCar(PLAYER_PED) then
	   animStatus = true
	   taskPlayAnim(PLAYER_PED, name, nameLib, speed, loop, lockX, lockY, lockF, -1)
	end
end

--------------------------------------------------------------------------------
-----------------------------------onShowTextDraw-------------------------------
--------------------------------------------------------------------------------
fmodels = {19036, 19037, 19038, 18911, 18912, 18913, 18914, 18915, 18916, 18917, 18918, 18919, 18920, 11704}
sampev.onShowTextDraw = function(id, data)
	if data.text:find("Welcome") then
		welcome = true
	end
	if load_all then
	if fmask then
if math.floor(data.position.x) == 430 and math.floor(data.position.y) == 336 then
    pmask_cancel = id
end
		
		for i, v in ipairs(fmodels) do
			if data.modelId == v then
				sampSendClickTextdraw(id)
				find = true
				return true
			end
		end
            if id == 2183 and not find then
                if data.text == '1' then
                    -- Делаем задержку, чтобы убедиться, что 1-я страница полностью проверена
                    if not checking_page then
                        checking_page = true
                        lua_thread.create(function()
                            wait(300) -- Ждем 300 мс для уверенности
                            if not find and fmask then
                                sampSendClickTextdraw(2184) -- Переходим на 2-ю страницу
                            end
                            checking_page = false
                        end)
                    end
                elseif data.text == '2' then
                    -- Делаем задержку, чтобы предметы на 2-й странице успели обновиться
                    if not checking_page then
                        checking_page = true
                        lua_thread.create(function()
                            wait(400) -- Ждем 400 мс, пока сервер пришлет новые модели
                            if not find and fmask then
                                msg('Ошибка, у вас нет маски')
                                sampSendClickTextdraw(90) -- Закрываем инвентарь
                                fmask = false
                            end
                            checking_page = false
                        end)
                    end
                end
            end
		unmack2 = true
		unmack = true
	end
	renderpatron.tdCache[id] = data
    UpdateSafeAmmo(data)
    if data.text:find("~b~Kills:~w~ %d+~n~~r~Deaths:~w~ %d+") and math.floor(data.position.x) == 159 and math.floor(data.position.y) == 363 then
		var_0_9 = id
	end

    if data.text:find("FAMILY") then fhouseExist = true end
	
    if data.text:find("1____2____3") then
        if fsafes and fhouseExist then
            -- 1 + 79, 2 + 80, 0 + 89, ввод + 90
            safeNumbers["1"] = id + 11
            safeNumbers["2"] = id + 12
            safeNumbers["3"] = id + 13
            safeNumbers["4"] = id + 14
            safeNumbers["5"] = id + 15
            safeNumbers["6"] = id + 16
            safeNumbers["7"] = id + 17
            safeNumbers["8"] = id + 18
            safeNumbers["9"] = id + 19
            safeNumbers["0"] = id + 21
            safeNumbers["Enter"] = id + 22
			inputFsafeCode = true
			fhouseExist = false
        end
    end

	if data.modelId == 348 and fsafes then  -- DE, SD, M4, AK, SHOT, MP5, RIFLE
		safeGunsTD["1"] = id
		safeGunsTD["2"] = id + 3
		safeGunsTD["3"] = id + 9
		safeGunsTD["4"] = id + 6
		safeGunsTD["5"] = id + 12
		safeGunsTD["6"] = id + 15
		safeGunsTD["7"] = id + 18
		safeGunsTD["9"] = id + 24
		safeGunsTD["Take"] = id + 40
	end
	 
	if data.text:find("TAKE") and fsafes then --брать ган по иду моделей
		lua_thread.create(function()
			fhouseExist = false
			if helpfordnk then
				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnk_deagle > 0 then
					fsGunStatus["1"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnk_ak > 0 then
					fsGunStatus["3"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnk_m4 > 0 then
					fsGunStatus["4"] = true
				end	

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnk_shotgun > 0 then
					fsGunStatus["5"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnk_rifle > 0 then
					fsGunStatus["7"] = true
				end
				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.dnkdrugs_status and tonumber(config.data[mynick()].fsafe.take_drugs) > tonumber(config.data[mynick()].fsafe.drugs) then
					fsGunStatus["9"] = true
				end
			else
                if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.deagle > 0 then
					fsGunStatus["1"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.ak > 0 then
					fsGunStatus["3"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.m4 > 0 then
					fsGunStatus["4"] = true
				end		

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.shotgun > 0 then
					fsGunStatus["5"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.rifle > 0 then
					fsGunStatus["7"] = true
				end

				if config.data[mynick()] ~= nil and config.data[mynick()].fsafe.drugs_status and tonumber(config.data[mynick()].fsafe.take_drugs) > tonumber(config.data[mynick()].fsafe.drugs) then
					fsGunStatus["9"] = true
				end
		    end

			fsClickExist = true
			if fclick == false and fsafes then
				sampSendClickTextdraw(65535)
				if helpfordnk then
					helpfordnk = false
				end
			
				fsafes = false
				closed_dialog = true
				--lua_thread.create(function() wait(50) sampCloseCurrentDialogWithButton(0) end)
			end
		end)
       -- return false
	end
end
end

--------------------------------------------------------------------------------
-------------------------------------ALLFUNCTIONS-------------------------------
--------------------------------------------------------------------------------
local list_size = { 
	[16] = 24,
	[15] = 23,
	[14] = 22,
	[13] = 21,
	[12] = 20,
	[11] = 18,
	[10] = 16,
	[9] = 14,
	[8] = 12,
	[7] = 10,
	[6] = 8,
	[5] = 6,
	[4] = 4,
	[3] = 2,
	[2] = 0,
	[1] = 0,
	[0] = 0,
}
function SquadFuncTwo()
    while true do 
        wait(0)
        
        -- Вызываем проверку. Если условий нет — сразу пропускаем кадр
        if squad_members and #squad_members > 0 and authorization then
            -- 1. Кэшируем ник и таблицу настроек отряда, чтобы не дергать их постоянно
            local my_name = mynick()
            local squad_cfg = config.data[my_name] and config.data[my_name].squad
            
            if squad_cfg and squad_cfg.status then
                -- 2. Заголовок отряда рисуем ОДИН раз, а не в цикле по игрокам
                local header_text = squadcombo[squad_cfg.name_squad + 1]
                renderFontDrawText(squad_font, header_text, squad_cfg.x_pos, squad_cfg.y_pos, 0xFFFFFFFF)

                -- 3. Вычисляем отступ ОДИН раз перед циклом игроков
                local otstyp = 15 -- дефолтное значение на случай, если не совпадет
                for k, v in pairs(list_size) do
                    if squad_cfg.size == k then
                        otstyp = v
                        break -- Нашли нужный? Сразу выходим из цикла
                    end
                end

                -- Кэшируем тип покраски для быстрого доступа в условиях
                local squad_int = squad_cfg.int

                -- 4. Основной цикл отрисовки игроков
                for i = 1, #squad_members do
                    -- Замену "_" на " " лучше делать при получении списка, а не при рендере!
                    -- Но если нужно тут, то делаем локально, не перезаписывая саму таблицу squad_members каждый кадр
                    local member_name = squad_members[i]:gsub("_", " ")
                    local y_position = squad_cfg.y_pos + (i * otstyp)

                    -- Определяем цвет один раз без лишних перерасчетов в условиях
                    local color = 0xFFFFFFFF
                    if squad_int == 1 then
                        color = argb2abgr(4286070325)
                    elseif squad_int == 2 then
                        -- Тонируем строку в hex-число один раз (предполагаем, что в color_squad[i] лежит "AARRGGBB" или "RGB")
                        color = tonumber("0xFF" .. (color_squad[i] or "FFFFFF")) or 0xFFFFFFFF
                    elseif squad_int == 3 then
                        color = argb2abgr(squad_cfg.color)
                    end

                    -- Отрисовка имени игрока
                    renderFontDrawText(squad_font, member_name, squad_cfg.x_pos, y_position, color)
                end

                -- 5. Отрисовка плашки "Онлайн" ПОСЛЕ цикла игроков (тоже один раз)
                if squad_cfg.online_status and squad_onlines > 0 then
                    local online_word = (squad_cfg.language == 0) and "Online: " or "Онлайн: "
                    local online_text = online_word .. squad_onlines
                    local online_y = squad_cfg.y_pos + (squad_onlines * otstyp) + otstyp
                    
                    renderFontDrawText(squad_font, online_text, squad_cfg.x_pos, online_y, 0xFFFFFFFF)
                end
            end
        end
    end
end


function SquadFuncOne()
	while true do wait(0)
		if pos_squad then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].squad.x_pos = curX
			config.data[mynick()].squad.y_pos = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_squad = false
			   config_save(config.data)
			end
		end
		if check_squad_members and config.data[mynick()].squad.status and authorization then
			wait(500)
			netfmem = true
			sampSendChat("/fmembers")
			check_squad_members = false
		end
    end
end


--------------------------------------------------------------------------------
------------------------------------EBLOCHECKER---------------------------------
--------------------------------------------------------------------------------

function antiafkFunc()
    local applied = nil

    while true do
        wait(100)

        local nick = mynick()
        local profile = nick and config.data[nick]
        local enabled = profile ~= nil and profile.small_tweaks.antiafk == true

        if enabled ~= applied then
            if enabled then
                writeMemory(7634870, 1, 1, 1)
                writeMemory(7635034, 1, 1, 1)
                memory.fill(7623723, 144, 8)
                memory.fill(5499528, 144, 6)
            else
                writeMemory(7634870, 1, 0, 0)
                writeMemory(7635034, 1, 0, 0)
                memory.hex2bin('5051FF1500838500', 7623723, 8)
                memory.hex2bin('0F847B010000', 5499528, 6)
            end
            applied = enabled
        end
    end
end


--------------------------------------------------------------------------------
------------------------------------EBLOCHECKER---------------------------------
--------------------------------------------------------------------------------

get_guns_coord_resp = {
	{2494.29296875, -1681.8502197266, 12.338387489319}, -- grove
	{2183.3081054688, -1807.8851318359, 12.373405456543}, -- rifa
	{287.72546386719, -141.66345214844, 1006.15625}, -- rifa inta
	{1582.6881103516, -1597.0266113281, 27.475524902344}, -- aztec inta
	{1672.9483642578, -2113.423828125, 12.546875}, -- aztec
	{2647.3308105469, -2029.4759521484, 12.546875}, -- ballas
	{607.73522949219, -147.71377563477, 0}, -- ballas inta
	{2780.3444824219, -1615.7406005859, 9.921875}, -- vagos
	{358.85055541992, 34.617668151855, 0} -- vagos inta
}

function AutoGetGunsFunc()
	while true do wait(0)
		if config.data[mynick()] ~= nil and config.data[mynick()].autogetguns.status and get_guns_status and authorization then
			get_guns_status = false
			for k, v in pairs(get_guns_coord_resp) do
				local dist = math.floor(getDistanceBetweenCoords3d(v[1], v[2], v[3], getCharCoordinates(playerPed)))
				if dist <= 70.0 then
					sampSendChat('/get guns')
					break
				end
			end
		end
    end
end


function EbloCheckFunc()
	while true do wait(0)
		local peds = getAllChars()
		local text_gangs = ""
	
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.gang_stream and authorization then
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 then
				text_gangs = "{$CLR}RIFA{FFFFFF}: $CNT [$SCNT]\n{$CLR}GROVE{FFFFFF}: $CNT [$SCNT]\n{$CLR}AZTEC{FFFFFF}: $CNT [$SCNT]\n{$CLR}VAGOS{FFFFFF}: $CNT [$SCNT]\n{$CLR}BALLAS{FFFFFF}: $CNT [$SCNT]"
			else
				text_gangs = "{$CLR}R{FFFFFF}: $CNT [$SCNT] {$CLR}G{FFFFFF}: $CNT [$SCNT] {$CLR}A{FFFFFF}: $CNT [$SCNT] {$CLR}V{FFFFFF}: $CNT [$SCNT] {$CLR}B{FFFFFF}: $CNT [$SCNT]"
			end
		else
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 and authorization then
				text_gangs = "{$CLR}RIFA{FFFFFF}: $CNT\n{$CLR}GROVE{FFFFFF}: $CNT\n{$CLR}AZTEC{FFFFFF}: $CNT\n{$CLR}VAGOS{FFFFFF}: $CNT\n{$CLR}BALLAS{FFFFFF}: $CNT"
			else
				text_gangs = "{$CLR}R{FFFFFF}: $CNT {$CLR}G{FFFFFF}: $CNT {$CLR}A{FFFFFF}: $CNT {$CLR}V{FFFFFF}: $CNT {$CLR}B{FFFFFF}: $CNT"
			end
		end
	
		for i = 1, #clist_gang[1] do
			local online = 0
			for l = 0, sampGetMaxPlayerId(false) do
				if sampGetPlayerColor(l) == clist_gang[1][i] then online = online + 1 end
			end
			cho_gang = cho_gang:gsub('$CLR', ('%06X'):format(bit.band(clist_gang[1][i], 0xFFFFFF)), 1)
			cho_gang = cho_gang:gsub('$CNT', online, 1)
			text_gangs = text_gangs:gsub('$CLR', ('%06X'):format(bit.band(clist_gang[1][i], 0xFFFFFF)), 1)
			text_gangs = text_gangs:gsub('$CNT', online, 1)
		end
	
		for i = 1, #clist_gang[1] do
			local online = 0
			for _, v in pairs(peds) do
				local result, id = sampGetPlayerIdByCharHandle(v)
				if sampGetPlayerColor(id) == clist_gang[1][i] then online = online + 1 end
			end
			text_gangs = text_gangs:gsub('$SCNT', online, 1)
		end
	
		local text_bikers = ""
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.biker_stream and authorization then
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 then
				text_bikers = "{$CLR}MONGOLS{FFFFFF}: $CNT [$SCNT]\n{$CLR}PAGANS{FFFFFF}: $CNT [$SCNT]\n{$CLR}WARLOCKS{FFFFFF}: $CNT [$SCNT]"
			else
				text_bikers = "{$CLR}M{FFFFFF}: $CNT [$SCNT] {$CLR}P{FFFFFF}: $CNT [$SCNT] {$CLR}W{FFFFFF}: $CNT [$SCNT]"
			end
		else
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 and authorization then
				text_bikers = "{$CLR}MONGOLS{FFFFFF}: $CNT\n{$CLR}PAGANS{FFFFFF}: $CNT\n{$CLR}WARLOCKS{FFFFFF}: $CNT"
			else
				text_bikers = "{$CLR}M{FFFFFF}: $CNT {$CLR}P{FFFFFF}: $CNT {$CLR}W{FFFFFF}: $CNT"
			end
		end
	
		for i = 1, #clist_biker[1] do
			local online = 0
			for l = 0, sampGetMaxPlayerId(false) do
				if sampGetPlayerColor(l) == clist_biker[1][i] then online = online + 1 end
			end
			cho_biker = cho_biker:gsub('$CLR', ('%06X'):format(bit.band(clist_biker[1][i], 0xFFFFFF)), 1)
			cho_biker = cho_biker:gsub('$CNT', online, 1)		
			text_bikers = text_bikers:gsub('$CLR', ('%06X'):format(bit.band(clist_biker[1][i], 0xFFFFFF)), 1)
			text_bikers = text_bikers:gsub('$CNT', online, 1)		
		end
	
		for i = 1, #clist_biker[1] do
			local online = 0
			for _, v in pairs(peds) do
				local result, id = sampGetPlayerIdByCharHandle(v)
				if sampGetPlayerColor(id) == clist_biker[1][i] then online = online + 1 end
			end
			text_bikers = text_bikers:gsub('$SCNT', online, 1)
		end
	
		local text_maf = ""
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.maf_stream and authorization then
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 then
				text_maf = "{$CLR}RM{FFFFFF}: $CNT [$SCNT]\n{$CLR}LCN{FFFFFF}: $CNT [$SCNT]\n{$CLR}YAKUZA:{FFFFFF} $CNT [$SCNT]"
			else
				text_maf = "{$CLR}RM{FFFFFF}: $CNT [$SCNT] {$CLR}LCN{FFFFFF}: $CNT [$SCNT] {$CLR}Y:{FFFFFF} $CNT [$SCNT]"
			end
		else
			if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.style == 0 and authorization then
				text_maf = "{$CLR}RM{FFFFFF}: $CNT\n{$CLR}LCN{FFFFFF}: $CNT\n{$CLR}YAKUZA:{FFFFFF} $CNT"
			else
				text_maf = "{$CLR}RM{FFFFFF}: $CNT {$CLR}LCN{FFFFFF}: $CNT {$CLR}Y:{FFFFFF} $CNT"
			end
		end
		
		for i = 1, #clist_maf[1] do
			local online = 0
			for l = 0, sampGetMaxPlayerId(false) do
				if sampGetPlayerColor(l) == clist_maf[1][i] then online = online + 1 end
			end
			cho_maf = cho_maf:gsub('$CLR', ('%06X'):format(bit.band(clist_maf[1][i], 0xFFFFFF)), 1)
			cho_maf = cho_maf:gsub('$CNT', online, 1)
			text_maf = text_maf:gsub('$CLR', ('%06X'):format(bit.band(clist_maf[1][i], 0xFFFFFF)), 1)
			text_maf = text_maf:gsub('$CNT', online, 1)
		end
	
		for i = 1, #clist_maf[1] do
			local online = 0
			for _, v in pairs(peds) do
				local result, id = sampGetPlayerIdByCharHandle(v)
				if sampGetPlayerColor(id) == clist_maf[1][i] then online = online + 1 end
			end
			text_maf = text_maf:gsub('$SCNT', online, 1)
		end
	
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.gang_status and authorization then
			renderFontDrawText(fonts, text_gangs, config.data[mynick()].eblochecker.x_gang, config.data[mynick()].eblochecker.y_gang, 0xFFFFFFFF)
		end
	
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.maf_status and authorization then
			renderFontDrawText(fonts, text_maf, config.data[mynick()].eblochecker.x_maf, config.data[mynick()].eblochecker.y_maf, 0xFFFFFFFF)
		end
	
		if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.biker_status and authorization then
			renderFontDrawText(fonts, text_bikers, config.data[mynick()].eblochecker.x_biker, config.data[mynick()].eblochecker.y_biker, 0xFFFFFFFF)
		end
		if pos_gang then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].eblochecker.x_gang = curX
			config.data[mynick()].eblochecker.y_gang = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_gang = false
			   config_save(config.data)
			end            
		end
	
		if pos_maf then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].eblochecker.x_maf = curX
			config.data[mynick()].eblochecker.y_maf = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_maf = false
			   config_save(config.data)
			end
		end
	
		if pos_biker then
			sampSetCursorMode(3)
			curX, curY = getCursorPos()
			config.data[mynick()].eblochecker.x_biker = curX
			config.data[mynick()].eblochecker.y_biker = curY
			if isKeyJustPressed(1) then
			   sampSetCursorMode(0)
			   pos_biker = false
			   config_save(config.data)
			end
		end
    end
end

function cheatting()
	if window_function_9 == "" then


		imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Кликварп" or "Clickwarp"), status_clickwarp, function()
		config.data[mynick()].clickwarp.status = not config.data[mynick()].clickwarp.status
		config_save(config.data)
	end, true, function() end)
		imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], (config.data[mynick()].language.number == 1 and "Команда для быстрой активации/деактивации скрипта /cw" or '/w inv'))

	    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "АнтиАФК" or "Antiafk"), status_antiafk, function()
        config.data[mynick()].small_tweaks.antiafk = not config.data[mynick()].small_tweaks.antiafk
        config_save(config.data)
    end, true, function() window_function_9 = "afk" end)
    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Автоинвайт" or "Autoinvite"), status_autoinv, function()
        config.data[mynick()].small_tweaks.autoinv = not config.data[mynick()].small_tweaks.autoinv
        config_save(config.data)
    end, true, function() window_function_9 = "autoinv" end)
	imgui.SameLine()
	imgui.TextQuestion(fa["CIRCLE_QUESTION"], (config.data[mynick()].language.number == 1 and "Приняться в фаму /w finv\nПриняться в фраку /w inv или /fc inv id принимающего" or '/w inv'))

	imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Коллизия на игроков" or "Collision for players"), status_collision_all, function()
		config.data[mynick()].small_tweaks.collision_all = not config.data[mynick()].small_tweaks.collision_all
		config_save(config.data)
	end, true, function() window_function_9 = "coll" end)
					imgui.ToggleButtonTextGear("Удаление объектов", object_all_status, function()

                        config.data[mynick()].hidechar.status = object_all_status[0]
						config.data[mynick()].remove_fence.status = object_all_status[0]
						config.data[mynick()].flashlight.status = object_all_status[0]
						fence_status[0] = object_all_status[0]
						flashlight_status[0] = object_all_status[0]
						hidechar[0] = object_all_status[0]
                        config_save(config.data)
                        end, true, function() window_function_9 = "obj" end)	





    imgui.ToggleButtonTextGear((config.data[mynick()].language.number == 1 and "Сбив" or "Sbiv"), SbivStatus, function()
        config.data[mynick()].small_tweaks.sbiv_status = not config.data[mynick()].small_tweaks.sbiv_status
        config_save(config.data)
    end, true, function() window_function_9 = "cbiv" end)	

    						imgui.ToggleButtonTextGear2("Админ чекер", achecker, function()
                        config.data[mynick()].adminchecker.status = not config.data[mynick()].adminchecker.status
                        config_save(config.data)
						 end) 
                        imgui.SameLine()
                        imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Отображение админов по команде /admins, если у вас нет VIP") 

                        imgui.ToggleButtonTextGear("Авторепорт", autoreport_status, function()
                            config.data[mynick()].autoreport.status = not config.data[mynick()].autoreport.status
                            config_save(config.data)
                        end, true, function() window_function_9 = "autoreport" end)     
						imgui.SameLine()
                        imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Отправляет репорт после смерти с рандомной причиной из списка.")
						imgui.ToggleButtonTextGear2("Удаление трупов", hidechar, function()
                        config.data[mynick()].hidechar.status = not config.data[mynick()].hidechar.status
                        config_save(config.data)
						 end) 
						imgui.SameLine()
                        imgui.TextQuestion(fa["CIRCLE_QUESTION"], "Быстро удаляет труп и добавляет коллизию на появляющуюся модельку.") 
else

								 if imgui.Button("Назад##multi.menu_func", imgui.ImVec2(390,20)) then
                                window_function_9 = ""
                            end
							imgui.Spacing()
	if  window_function_9 == "afk" then
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Антиафк" or "Antiafk"), status_antiafk, function()
        config.data[mynick()].small_tweaks.antiafk = not config.data[mynick()].small_tweaks.antiafk
        config_save(config.data)
    end, true, function() end)
			imgui.InputTextWithHint("##Командаже22", (config.data[mynick()].language.number == 1 and "Введите команду" or "Enter the command"), antiafkCom, sizeof(antiafkCom))
		if imgui.Button((config.data[mynick()].language.number == 1 and "Сохранить команду" or "Save command"), imgui.ImVec2(276,20)) then
			sampUnregisterChatCommand(config.data[mynick()].small_tweaks.antiafk_cmd)
			config.data[mynick()].small_tweaks.antiafk_cmd = str(antiafkCom)
			config.data[mynick()].small_tweaks.antiafk_cmd = config.data[mynick()].small_tweaks.antiafk_cmd:gsub("/","")
			config_save(config.data)
			antiafk_cmd_register()
		end
    end


	if window_function_9 == "cbiv" then
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Сбив" or "Sbiv"), SbivStatus, function()
        config.data[mynick()].small_tweaks.sbiv_status = not config.data[mynick()].small_tweaks.sbiv_status
        config_save(config.data)
    end, true, function() window_function_9 = "cbiv" end)	

	if imgui.Combo(u8((config.data[mynick()].language.number == 1 and "Тип сбива" or "Type of Sbiv")), int_sbiv, combo_sbiv, #combosbiv) then
		config.data[mynick()].small_tweaks.sbiv_int = int_sbiv[0]
		config_save(config.data)
	end

    if SbivHotKey:ShowHotKey(imgui.ImVec2(277,20)) then 
        config.data[mynick()].small_tweaks.sbiv_key = SbivHotKey:GetHotKey()
        config_save(config.data)
    end 
	end
	if window_function_9 == "autoreport" then
        autoreport()
	end
	if window_function_9 == "flashlight" then
		flashlight()
	end
	if window_function_9 == "fence" then
		fence()
	end
	if window_function_9 == "obj" then
							imgui.ToggleButtonTextGear("Удалять разрушаемые объекты", fence_status, function()
                        config.data[mynick()].remove_fence.status = not config.data[mynick()].remove_fence.status
                        config_save(config.data)
						object_all_status = imgui.new.bool((config.data[mynick()].remove_fence.status and config.data[mynick()].flashlight.status))
                    end, true, function() window_function_9 = "fence" end)  

	                    imgui.ToggleButtonTextGear("Удалять столбы", flashlight_status, function()
                        config.data[mynick()].flashlight.status = not config.data[mynick()].flashlight.status
                        config_save(config.data)
						object_all_status = imgui.new.bool((config.data[mynick()].remove_fence.status and config.data[mynick()].flashlight.status))
                    end, true, function() window_function_9 = "flashlight" end)


	end

	if window_function_9 == "autoinv" then
		    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автоинвайт" or "Autoinvite"), status_autoinv, function()
        config.data[mynick()].small_tweaks.autoinv = not config.data[mynick()].small_tweaks.autoinv
        config_save(config.data)
    end, true, function() window_function_9 = "autoinv" end)
			    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовыдача ранга при автоинвайте" or "Automatic rank assignment upon auto-invitation"), status_autogiverank, function()
        config.data[mynick()].small_tweaks.autogiverank = not config.data[mynick()].small_tweaks.autogiverank
        config_save(config.data)
    end, true, function() end)
	    imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Автовыдача ранга при обычном инвайте" or "Automatic rank assignment during a regular invite"), status_pautogiverank, function()
        config.data[mynick()].small_tweaks.pautogiverank = not config.data[mynick()].small_tweaks.pautogiverank
        config_save(config.data)
    end, true, function() end)
	end

		if window_function_9 == "coll" then
			imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Коллизия на игроков в доме" or "Collision for players in the house"), status_collision, function()
		config.data[mynick()].small_tweaks.collision = not config.data[mynick()].small_tweaks.collision
		config_save(config.data)
	end, true, function() end)	
	imgui.ToggleButtonTextGear2((config.data[mynick()].language.number == 1 and "Коллизия на игроков везде" or "Collision for players"), status_collision_all, function()
		config.data[mynick()].small_tweaks.collision_all = not config.data[mynick()].small_tweaks.collision_all
		config_save(config.data)
	end, true, function() end)
end
	
end
end
--------------------------------------------------------------------------------
-------------------------------------DRUGTIMER----------------------------------
--------------------------------------------------------------------------------

function drugstimer()
	while true do wait(0)
		if isPlayerDead(PLAYER_HANDLE) or sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 1206 or sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 1205 then


			if config.data[mynick()] ~= nil and config.data[mynick()].drugtimer.status and config.data[mynick()].drugtimer.death and authorization and not check_mafia() then
				wait(200)
				sampSendChat(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, 16))
				wait(5000)
			end
		end
	
		if config.data[mynick()] ~= nil and config.data[mynick()].drugtimer.status and not sampIsScoreboardOpen() and sampIsChatVisible() and not isKeyDown(116) and not isKeyDown(121) and authorization then
			second_timer = os.difftime(os.time(), drugs_timer)
			render_table = ((second_timer <= config.data[mynick()].drugtimer.seconds and second_timer > 0) and renderText[4] or renderText[3])
			local Y, Height = config.data[mynick()].render.y, (renderGetFontDrawHeight(font) - (renderGetFontDrawHeight(font) / config.data[mynick()].render.height)  )
			for i = 1, #render_table do
				if render_table[i] ~= nil then
					string_gsub = render_table[i]:gsub("!a", config.data[mynick()].drugtimer.drugs)
					string_gsub = string_gsub:gsub("!s", tostring(math.ceil(config.data[mynick()].drugtimer.seconds - second_timer)))
					string_gsub = string_gsub:gsub("!m", tostring(config.data[mynick()].drugtimer.mats))
					if config.data[mynick()] ~= nil and config.data[mynick()].render.align == 1 then X = config.data[mynick()].render.x end
					if config.data[mynick()] ~= nil and config.data[mynick()].render.align == 2 then X = config.data[mynick()].render.x - (renderGetFontDrawTextLength(font, string_gsub) / 2) end
					if config.data[mynick()] ~= nil and config.data[mynick()].render.align == 3 then X = config.data[mynick()].render.x - renderGetFontDrawTextLength(font, string_gsub) end
					renderFontDrawText(font, string_gsub, X, Y, 0xFFFFFFFF)
					Y = Y + Height
				end
			end
		
			if isKeysPressed(config.data[mynick()].drugtimer.key) and config.data[mynick()].drugtimer.status and isKeyCanBePressed()  then
				local gramm = math.ceil(((config.data[mynick()].drugtimer.hp + 1) - getCharHealth(playerPed)) / config.data[mynick()].drugtimer.hp_one_gram)
				if gramm > config.data[mynick()].drugtimer.max_use_gram then gramm = config.data[mynick()].drugtimer.max_use_gram end
				sampSendChat(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, gramm))
			end

			if isKeyDown(16) and isKeysPressed(config.data[mynick()].drugtimer.key) and config.data[mynick()].drugtimer.status  and isKeyCanBePressed()   then 
				local gramm = math.ceil(((config.data[mynick()].drugtimer.hp + 1) - getCharHealth(playerPed)) / config.data[mynick()].drugtimer.hp_one_gram)
				if gramm > config.data[mynick()].drugtimer.max_use_gram then gramm = config.data[mynick()].drugtimer.max_use_gram end
				sampSendChat(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, gramm))
			end
		
			if isKeyDown(32) and isKeysPressed(config.data[mynick()].drugtimer.key) and config.data[mynick()].drugtimer.status and isKeyCanBePressed()   then 
				local gramm = math.ceil(((config.data[mynick()].drugtimer.hp + 1) - getCharHealth(playerPed)) / config.data[mynick()].drugtimer.hp_one_gram)
				if gramm > config.data[mynick()].drugtimer.max_use_gram then gramm = config.data[mynick()].drugtimer.max_use_gram end
				sampSendChat(string.format('/%s %d', config.data[mynick()].drugtimer.server_cmd, gramm))
			end
		
			if pos then
				sampSetCursorMode(3)
				curX, curY = getCursorPos()
				config.data[mynick()].render.x = curX
				config.data[mynick()].render.y = curY
				if isKeyJustPressed(1) then
				   sampSetCursorMode(0)
				   pos = false
				   config_save(config.data)
				end
			end
		end
    end
end



--------------------------------------------------------------------------------
-------------------------------------MAFIALINES---------------------------------
--------------------------------------------------------------------------------

function MafiaLinesFunc()
	while true do wait(0)
		if should_render() then--lines_status[0] and
		if config.data[mynick()] ~= nil and config.data[mynick()].mafialines.activated then
			if id1_status[0] and (not time_capt[0] or ev6 == 1) then
				render_zone(zone_one)
			end
	
			if id2_status[0] and (not time_capt[0] or ev6 == 2) then
				render_zone(zone_two)
			end
	
			if id3_status[0] and (not time_capt[0] or ev6 == 3) then
				render_zone(zone_three)
			end
	
			if id4_status[0] and (not time_capt[0] or ev6 == 4) then
				render_zone(zone_fo)
			end
	
			if id5_status[0] and (not time_capt[0] or ev6 == 5) then
				render_zone(zone_five)
			end

            if id6_status[0] and (not time_capt[0] or ev6 == 6) then
				render_zone(zone_six)
			end
            if id7_status[0] and (not time_capt[0] or ev6 == 7) then
				render_zone(zone_seven)
			end
		end
if config.data[mynick()] ~= nil and config.data[mynick()].bikerlines.activated then
if zone_blueberry[0] then
	render_zone2(zone_blueberry2)
end

if zone_montgomery[0] then
	render_zone2(zone_montgomery2)
end

if zone_palomino_creek[0] then
	render_zone2(zone_palomino_creek2)
end

if zone_dillimore[0] then
	render_zone2(zone_dillimore2)
end

if zone_fort_carson[0] then
	render_zone2(zone_fort_carson2)
end

if zone_las_barrancas[0] then
	render_zone2(zone_las_barrancas2)
end

if zone_el_quebrados[0] then
	render_zone2(zone_el_quebrados2)
end

if zone_angel_pine[0] then
	render_zone2(zone_angel_pine2)
end
end
		end
    end
end





function should_render()
	if getActiveInterior() == 0 and isGameWindowForeground() and not var_0_9 and not var_0_8 and not isPauseMenuActive() then
		return true
	else
		return false
	end
end


function mafia_zone(arg_9_0)
	if not ev4[arg_9_0] then
		return false
	end

	if math.abs(ev4[arg_9_0].squareStart.x - var_0_46.id1.squareStart.x) < 0.1 and math.abs(ev4[arg_9_0].squareStart.y - var_0_46.id1.squareStart.y) < 0.1 then
		return 1
	elseif math.abs(ev4[arg_9_0].squareStart.x - var_0_46.id2.squareStart.x) < 0.1 and math.abs(ev4[arg_9_0].squareStart.y - var_0_46.id2.squareStart.y) < 0.1 then
		return 2
	elseif math.abs(ev4[arg_9_0].squareStart.x - var_0_46.id3.squareStart.x) < 0.1 and math.abs(ev4[arg_9_0].squareStart.y - var_0_46.id3.squareStart.y) < 0.1 then
		return 3
	elseif math.abs(ev4[arg_9_0].squareStart.x - var_0_46.id4.squareStart.x) < 0.1 and math.abs(ev4[arg_9_0].squareStart.y - var_0_46.id4.squareStart.y) < 0.1 then
		return 4
	elseif math.abs(ev4[arg_9_0].squareStart.x - var_0_46.id5.squareStart.x) < 0.1 and math.abs(ev4[arg_9_0].squareStart.y - var_0_46.id5.squareStart.y) < 0.1 then
		return 5
	else
		return false
	end
end


function IsPointInsideRadar(arg_10_0, arg_10_1)
	return ev9(ffi.new("struct CVector2D", {
		arg_10_0,
		arg_10_1
	}))
end


function TransformRealWorldPointToRadarSpace(arg_11_0, arg_11_1)
	local var_11_0 = ffi.new("struct CVector2D", {
		0,
		0
	})

	ev7(var_11_0, ffi.new("struct CVector2D", {
		arg_11_0,
		arg_11_1
	}))

	return var_11_0.x, var_11_0.y
end


function TransformRadarPointToScreenSpace(arg_12_0, arg_12_1)
	local var_12_0 = ffi.new("struct CVector2D", {
		0,
		0
	})

	ev8(var_12_0, ffi.new("struct CVector2D", {
		arg_12_0,
		arg_12_1
	}))

	return var_12_0.x, var_12_0.y
end


function sampev.onCreateGangZone(arg_18_0, arg_18_1, arg_18_2, arg_18_3)
	ev4[arg_18_0] = {
		squareStart = arg_18_1,
		squareEnd = arg_18_2,
		color = arg_18_3
	}
end


function sampev.onGangZoneFlash(arg_19_0, arg_19_1)
	local var_19_0 = mafia_zone(arg_19_0)

	if var_19_0 then
		ev5 = arg_19_0
		ev6 = var_19_0
	end
end


function sampev.onGangZoneStopFlash(arg_20_0)
	if ev5 == arg_20_0 then
		ev5 = nil
		ev6 = nil
	end
end


function sampev.onSpectatePlayer(arg_21_0, arg_21_1)
	if sampGetPlayerColor(arg_21_0) == var_0_47 or sampGetPlayerColor(arg_21_0) == var_0_48 or sampGetPlayerColor(arg_21_0) == var_0_49 then
		var_0_8 = true
	else
		var_0_8 = false
	end
end


function sampev.onTogglePlayerSpectating(arg_22_0)
	if not arg_22_0 then
		var_0_8 = false
	end
end


function sampev.onTextDrawHide(arg_24_0)
	if var_0_9 == arg_24_0 then
		var_0_9 = nil
	end
end

function sampev.onSendChat(message)
    antiflood = os.clock() * 1000
end

function sampev.onSendSpawn()
    delete_cue_spawn_status = os.time()
end

function render_zone(arg_25_0)
	for iter_25_0 = 1, #arg_25_0 do
		if arg_25_0[iter_25_0] ~= nil and arg_25_0[iter_25_0 + 1] ~= nil then
			local var_25_0, var_25_1, var_25_2 = getCharCoordinates(PLAYER_PED)
			local var_25_3 = getDistanceBetweenCoords2d(var_25_0, var_25_1, arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y)

			if var_25_3 < var_0_28[0] then
				local var_25_4, var_25_5, var_25_6, var_25_7, var_25_8, var_25_9 = convert3DCoordsToScreenEx(arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y, arg_25_0[iter_25_0].z + var_0_30[0] / 10, false, false)
				local var_25_10, var_25_11, var_25_12, var_25_13, var_25_14, var_25_15 = convert3DCoordsToScreenEx(arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y, arg_25_0[iter_25_0 + 1].z + var_0_30[0] / 10, false, false)
				var_25_16 = var_0_14 

				if var_0_29[0] == 1 then
					local var_25_17

					if iter_25_0 > #arg_25_0 / 2 then
						var_25_17 = #arg_25_0 - iter_25_0
					else
						var_25_17 = iter_25_0
					end

					local var_25_18, var_25_19, var_25_20, var_25_21 = rainbow(ev1[0], 255, var_25_17 / -50)
					local var_25_22 = ev0[0] == 256 and iter_25_0 * (255 / (#arg_25_0 > 255 and 255 or #arg_25_0)) or ev0[0]

					var_25_16 = join_argb(var_25_22 > 255 and 255 or var_25_22, var_25_18, var_25_19, var_25_20)
				end
				if lines_status[0] then
					if var_25_7 > 0 and var_25_13 > 0 then
						renderDrawLine(var_25_5, var_25_6, var_25_11, var_25_12, var_0_27[0], var_25_16)
					elseif var_25_7 <= 0 and var_25_13 > 0 then
						local var_25_23 = getFixScreenPos(arg_25_0[iter_25_0 + 1], arg_25_0[iter_25_0], var_25_13)
						local var_25_24, var_25_25, var_25_26
	
						var_25_24, var_25_5, var_25_6, var_25_7, var_25_25, var_25_26 = convert3DCoordsToScreenEx(var_25_23.x, var_25_23.y, var_25_23.z, false, false)
	
						renderDrawLine(var_25_5, var_25_6, var_25_11, var_25_12, var_0_27[0], var_25_16)
					elseif var_25_7 > 0 and var_25_13 <= 0 then
						local var_25_27 = getFixScreenPos(arg_25_0[iter_25_0], arg_25_0[iter_25_0 + 1], var_25_7)
						local var_25_28, var_25_29, var_25_30, var_25_31, var_25_32, var_25_33 = convert3DCoordsToScreenEx(var_25_27.x, var_25_27.y, var_25_27.z, false, false)
	
						renderDrawLine(var_25_5, var_25_6, var_25_29, var_25_30, var_0_27[0], var_25_16)
					end
			    end

				if radar_lines[0] then
					local var_25_34, var_25_35 = TransformRealWorldPointToRadarSpace(arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y)
					local var_25_36, var_25_37 = TransformRealWorldPointToRadarSpace(arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y)

					if type_radar[0] == 0 then
						local var_25_38 = getDistanceBetweenCoords2d(var_25_0, var_25_1, arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y)

						if IsPointInsideRadar(var_25_34, var_25_35) and IsPointInsideRadar(var_25_36, var_25_37) and var_25_3 < 180 and var_25_38 < 180 then
							local var_25_39, var_25_40 = TransformRadarPointToScreenSpace(var_25_34, var_25_35)
							local var_25_41, var_25_42 = TransformRadarPointToScreenSpace(var_25_36, var_25_37)

							renderDrawLine(var_25_39, var_25_40, var_25_41, var_25_42, 3, var_25_16)
						end
					elseif IsPointInsideRadar(var_25_34, var_25_35) and IsPointInsideRadar(var_25_36, var_25_37) then
						local var_25_43, var_25_44 = TransformRadarPointToScreenSpace(var_25_34, var_25_35)
						local var_25_45, var_25_46 = TransformRadarPointToScreenSpace(var_25_36, var_25_37)

						renderDrawLine(var_25_43, var_25_44, var_25_45, var_25_46, 3, var_25_16)
					end
				end
			end
		end
	end
end
function render_zone2(arg_25_0)
	for iter_25_0 = 1, #arg_25_0 do
		if arg_25_0[iter_25_0] ~= nil and arg_25_0[iter_25_0 + 1] ~= nil then
			local var_25_0, var_25_1, var_25_2 = getCharCoordinates(PLAYER_PED)
			local var_25_3 = getDistanceBetweenCoords2d(var_25_0, var_25_1, arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y)

			if var_25_3 < b_var_0_28[0] then
				local var_25_4, var_25_5, var_25_6, var_25_7, var_25_8, var_25_9 = convert3DCoordsToScreenEx(arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y, arg_25_0[iter_25_0].z + var_0_30[0] / 10, false, false)
				local var_25_10, var_25_11, var_25_12, var_25_13, var_25_14, var_25_15 = convert3DCoordsToScreenEx(arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y, arg_25_0[iter_25_0 + 1].z + var_0_30[0] / 10, false, false)
				local var_25_16 = var_0_142

				if b_var_0_29[0] == 1 then
					local var_25_17

					if iter_25_0 > #arg_25_0 / 2 then
						var_25_17 = #arg_25_0 - iter_25_0
					else
						var_25_17 = iter_25_0
					end

					local var_25_18, var_25_19, var_25_20, var_25_21 = rainbow(ev1[0], 255, var_25_17 / -50)
					local var_25_22 = ev0[0] == 256 and iter_25_0 * (255 / (#arg_25_0 > 255 and 255 or #arg_25_0)) or ev0[0]

					var_25_16 = join_argb(var_25_22 > 255 and 255 or var_25_22, var_25_18, var_25_19, var_25_20)
				end
				if b_lines_status[0] then
					if var_25_7 > 0 and var_25_13 > 0 then
						renderDrawLine(var_25_5, var_25_6, var_25_11, var_25_12, b_var_0_27[0], var_25_16)
					elseif var_25_7 <= 0 and var_25_13 > 0 then
						local var_25_23 = getFixScreenPos(arg_25_0[iter_25_0 + 1], arg_25_0[iter_25_0], var_25_13)
						local var_25_24, var_25_25, var_25_26
	
						var_25_24, var_25_5, var_25_6, var_25_7, var_25_25, var_25_26 = convert3DCoordsToScreenEx(var_25_23.x, var_25_23.y, var_25_23.z, false, false)
	
						renderDrawLine(var_25_5, var_25_6, var_25_11, var_25_12, b_var_0_27[0], var_25_16)
					elseif var_25_7 > 0 and var_25_13 <= 0 then
						local var_25_27 = getFixScreenPos(arg_25_0[iter_25_0], arg_25_0[iter_25_0 + 1], var_25_7)
						local var_25_28, var_25_29, var_25_30, var_25_31, var_25_32, var_25_33 = convert3DCoordsToScreenEx(var_25_27.x, var_25_27.y, var_25_27.z, false, false)
	
						renderDrawLine(var_25_5, var_25_6, var_25_29, var_25_30, b_var_0_27[0], var_25_16)
					end
			    end

				if b_radar_lines[0] then
					local var_25_34, var_25_35 = TransformRealWorldPointToRadarSpace(arg_25_0[iter_25_0].x, arg_25_0[iter_25_0].y)
					local var_25_36, var_25_37 = TransformRealWorldPointToRadarSpace(arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y)

					if type_radar[0] == 0 then
						local var_25_38 = getDistanceBetweenCoords2d(var_25_0, var_25_1, arg_25_0[iter_25_0 + 1].x, arg_25_0[iter_25_0 + 1].y)

						if IsPointInsideRadar(var_25_34, var_25_35) and IsPointInsideRadar(var_25_36, var_25_37) and var_25_3 < 180 and var_25_38 < 180 then
							local var_25_39, var_25_40 = TransformRadarPointToScreenSpace(var_25_34, var_25_35)
							local var_25_41, var_25_42 = TransformRadarPointToScreenSpace(var_25_36, var_25_37)

							renderDrawLine(var_25_39, var_25_40, var_25_41, var_25_42, 3, var_25_16)
						end
					elseif IsPointInsideRadar(var_25_34, var_25_35) and IsPointInsideRadar(var_25_36, var_25_37) then
						local var_25_43, var_25_44 = TransformRadarPointToScreenSpace(var_25_34, var_25_35)
						local var_25_45, var_25_46 = TransformRadarPointToScreenSpace(var_25_36, var_25_37)

						renderDrawLine(var_25_43, var_25_44, var_25_45, var_25_46, 3, var_25_16)
					end
				end
			end
		end
	end
end

function getFixScreenPos(arg_26_0, arg_26_1, arg_26_2)
	arg_26_2 = math.abs(arg_26_2)

	if arg_26_2 >= 1 then
		arg_26_2 = math.floor(arg_26_2)
	end

	local var_26_0 = {
		x = arg_26_1.x - arg_26_0.x,
		y = arg_26_1.y - arg_26_0.y,
		z = arg_26_1.z - arg_26_0.z
	}
	local var_26_1 = math.sqrt(var_26_0.x * var_26_0.x + var_26_0.y * var_26_0.y + var_26_0.z * var_26_0.z)
	local var_26_2 = {
		x = var_26_0.x / var_26_1,
		y = var_26_0.y / var_26_1,
		z = var_26_0.z / var_26_1
	}

	return {
		x = arg_26_0.x + var_26_2.x * arg_26_2,
		y = arg_26_0.y + var_26_2.y * arg_26_2,
		z = arg_26_0.z + var_0_30[0] / 10 + var_26_2.z * arg_26_2
	}
end


function join_argb(arg_27_0, arg_27_1, arg_27_2, arg_27_3)
	local var_27_0 = arg_27_3
	local var_27_1 = bit.bor(var_27_0, bit.lshift(arg_27_2, 8))
	local var_27_2 = bit.bor(var_27_1, bit.lshift(arg_27_1, 16))

	return (bit.bor(var_27_2, bit.lshift(arg_27_0, 24)))
end


function rainbow(arg_28_0, arg_28_1, arg_28_2)
	local var_28_0 = os.clock() + arg_28_2
	local var_28_1 = math.floor(math.sin(var_28_0 * arg_28_0) * 127 + 128)
	local var_28_2 = math.floor(math.sin(var_28_0 * arg_28_0 + 2) * 127 + 128)
	local var_28_3 = math.floor(math.sin(var_28_0 * arg_28_0 + 4) * 127 + 128)

	return var_28_1, var_28_2, var_28_3, arg_28_1
end


function saveINI() -- для mafialines
    config.data[mynick()].mafialines.activated = lines_status[0]
    config.data[mynick()].mafialines.onlyServer = only_evolv[0]
    config.data[mynick()].mafialines.onlyCapture = time_capt[0]
    config.data[mynick()].mafialines.radarRender = radar_lines[0]
    config.data[mynick()].mafialines.radarMode = type_radar[0]
	config.data[mynick()].mafialines.render_height = var_0_30[0]
    config.data[mynick()].mafialines.width = var_0_27[0]
    config.data[mynick()].mafialines.distancedraw = var_0_28[0]
    config.data[mynick()].mafialines.color = encodeJson({
        ev2[0],
        ev2[1],
        ev2[2],
        ev2[3]
    })
    config.data[mynick()].mafialines.rainbowc = var_0_26[0]
    config.data[mynick()].mafialines.mode = var_0_29[0]
    config.data[mynick()].mafialines.trailalpha = ev0[0]
    config.data[mynick()].mafialines.trailspeed = ev1[0]
    config.data[mynick()].mafialines.quarryed = id1_status[0]
    config.data[mynick()].mafialines.villaged = id2_status[0]
    config.data[mynick()].mafialines.airported = id3_status[0]
    config.data[mynick()].mafialines.mined = id4_status[0]
    config.data[mynick()].mafialines.buildinged = id5_status[0]
    config.data[mynick()].mafialines.piligrim = id6_status[0]
    config.data[mynick()].mafialines.rokwor = id7_status[0]
    config_save(config.data)
end

function bsaveINI() -- для mafialines
    config.data[mynick()].bikerlines.activated = b_lines_status[0]
    config.data[mynick()].bikerlines.radarRender = b_radar_lines[0]
	config.data[mynick()].bikerlines.render_height = b_var_0_30[0]
    config.data[mynick()].bikerlines.width = b_var_0_27[0]
    config.data[mynick()].bikerlines.distancedraw = b_var_0_28[0]
    config.data[mynick()].bikerlines.color = encodeJson({
			b_ev2[0],
			b_ev2[1],
			b_ev2[2],
			b_ev2[3]
    })
    config.data[mynick()].bikerlines.rainbowc = b_var_0_26[0]
    config.data[mynick()].bikerlines.mode = b_var_0_29[0]
    config.data[mynick()].bikerlines.trailalpha = b_ev0[0]
    config.data[mynick()].bikerlines.trailspeed = b_ev1[0]
        config.data[mynick()].bikerlines.zone_blueberry = zone_blueberry[0]
		config.data[mynick()].bikerlines.zone_montgomery = zone_montgomery[0]
		config.data[mynick()].bikerlines.zone_palomino_creek = zone_palomino_creek[0]
		config.data[mynick()].bikerlines.zone_dillimore = zone_dillimore[0]
		config.data[mynick()].bikerlines.zone_fort_carson = zone_fort_carson[0]
		config.data[mynick()].bikerlines.zone_las_barrancas = zone_las_barrancas[0]
		config.data[mynick()].bikerlines.zone_el_quebrados = zone_el_quebrados[0]
		config.data[mynick()].bikerlines.zone_angel_pine = zone_angel_pine[0]
    config_save(config.data)
end
--[[
		radarRender = b_radar_lines[0],
		width = b_var_0_27[0],
		distancedraw = b_var_0_28[0],
		color = encodeJson({
			b_ev2[0],
			b_ev2[1],
			b_ev2[2],
			b_ev2[3]
		}),
		rainbowc = b_var_0_26[0],
		mode = b_var_0_29[0],
		trailalpha = b_ev0[0],
		trailspeed = b_ev1[0],
		activated = b_lines_status[0],
        zone_blueberry = zone_blueberry[0],
		zone_montgomery = zone_montgomery[0],
		zone_palomino_creek = zone_palomino_creek[0],
		zone_dillimore = zone_dillimore[0],
		zone_fort_carson = zone_fort_carson[0],
		zone_las_barrancas = zone_las_barrancas[0],
		zone_el_quebrados = zone_el_quebrados[0],
		zone_angel_pine = zone_angel_pine[0],
		render_height = b_var_0_30[0]
		]]

function download_resource(url, path)
	    if xyi_pizda == nil then
        msg("Скачиваю недостающие ресурсы. Ожидайте...")
        xyi_pizda = true
    end
    local dlstatus = require("moonloader").download_status
	downloadUrlToFile(
		url,
		getWorkingDirectory() .. "\\Palenation Tool Extended\\resource\\"..path,
		function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if check_resource2() then
                    msg("Загрузка завершена. Выполняется перезапуск скрипта")
                    thisScript():reload()
                end
			end
		end
	)
end



------------------------------------------------------------------
---------------------------onPlayerChatBubble---------------------
------------------------------------------------------------------

function sampev.onPlayerChatBubble(id, col, dist, dur, msg)
    if ch_flymode == 1 and config.data[mynick()].camhack.bubble then
        return { id, col, 1488, dur, msg }
    end
end

------------------------------------------------------------------
-----------------------------onSendAimSync------------------------
------------------------------------------------------------------

function sampev.onSendAimSync()
    if ch_flymode == 1 and config.data[mynick()].camhack.antiwarning then
        return false
    end
end


--------------------------------------------------------------------------------
-------------------------------------FASTCAR------------------------------------
--------------------------------------------------------------------------------

function FastCarFunc()
	while true do wait(0)
	if config.data[mynick()] ~= nil then
		if isKeysPressed(config.data[mynick()].fastcarfx.key) and config.data[mynick()].fastcarfx.status and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() and authorization then
			if os.time() - parking_time > 4 then
				efcs.start = os.time()
				efcs.list_remove = {}
				efcs.list_create = {}
				setGameKeyState(21, 255)
			else
				if config.data[mynick()] ~= nil and config.data[mynick()].fastcarfx.status_exit then
				    efcs_autoexit = true
				end
				msg("Машина уже заспавнена")
			end
		end
	
		if efcs_autoexit and authorization then
			wait(250)
			setGameKeyState(15, 32767)
		end
	end
    end
end


--------------------------------------------------------------------------------
-------------------------------------AUTOCAPT-----------------------------------
--------------------------------------------------------------------------------

function AutoCaptFunc()
	while true do wait(0)
		if isKeyJustPressed(autocapterkey) and not sampIsChatInputActive() and config.data[mynick()].AutoCapt.status and authorization then
			AutoCapterstart = not AutoCapterstart
			printStringNow(AutoCapterstart and "~G~CAPTURE ACTIVATED" or "~R~CAPTURE STOP", 1000) 
		end		
	
		if biz_check then
			wait(1000)
			sampSendChat("/capture")
			wait(1000)
			biz_check = false
			check_squad_members = true
		end
    end
end

function AutoCaptFuncTwo()
	while true do wait(0)
		if AutoCapterstart and not sampIsChatInputActive() and config.data[mynick()].AutoCapt.status and authorization then
			sampSendChat("/capture")
			if capture_on_command and capture_biz ~= nil then
				sampSendDialogResponse(32700, 1, capture_biz - 1, -1)
			else
			    sampSendDialogResponse(32700, 1, config.data[mynick()].AutoCapt.biz - 1, -1)
			end
			wait(config.data[mynick()].AutoCapt.wait)
		end
	end
end
--------------------------------------------------------------------------------
-------------------------------------FSAFE--------------------------------------
--------------------------------------------------------------------------------

function FsafeFunc()
    local fsafeBusy = false

    while true do
        wait(0)

        local nick = mynick()
        local profile = nick and config.data[nick]
        local fsafe = profile and profile.fsafe

        if fsafe and not fsafeBusy
            and isKeysPressed(fsafe.key)
            and fsafe.status
            and not sampIsDialogActive()
            and not sampIsChatInputActive()
            and not sampIsCursorActive()
            and authorization then

            fsafeBusy = true

            repeat
                wait(25)
            until os.clock() * 1000 - antiflood > 1000

            sampSendChat('/fsafe')
            fclick = true
            nextFsGun = false
            fsGunStatus = {['1']=false,['2']=false,['3']=false,['4']=false,['5']=false,['6']=false,['7']=false,['8']=false,['9']=false}
            fsGunAmount = {
                ['1'] = tonumber(fsafe.deagle) or 0,
                ['2'] = 0,
                ['3'] = tonumber(fsafe.ak) or 0,
                ['4'] = tonumber(fsafe.m4) or 0,
                ['5'] = tonumber(fsafe.shotgun) or 0,
                ['6'] = 0,
                ['7'] = tonumber(fsafe.rifle) or 0,
                ['9'] = (tonumber(fsafe.take_drugs) or 0) - (tonumber(fsafe.drugs) or 0)
            }
            fsafes = true
            fsafeBusy = false
        end

        local td_pos = {
            ['1']={251,200}, ['2']={275,200}, ['3']={300,200},
            ['4']={251,228}, ['5']={275,228}, ['6']={300,228},
            ['7']={251,257}, ['8']={275,257}, ['9']={300,257},
            ['0']={275,285}, ['enter']={300,285}
        }

        if fsafes and inputFsafeCode and profile and authorization then
            local pin = tostring(helpfordnk and fsafe.dnk_pin or fsafe.pin or '')
            local pinLength = math.min(#pin, 16)

            for i = 1, pinLength do
                local key = pin:sub(i, i)
                local pos = td_pos[key]
                if pos then
                    local res, id = getTextdrawByPos(pos[1], pos[2])
                    if res and id then
                        sampSendClickTextdraw(id)
                        wait(250)
                    end
                end
            end

            if safeNumbers and safeNumbers['Enter'] then
                sampSendClickTextdraw(safeNumbers['Enter'])
            end
            inputFsafeCode = false
        end

        if fsClickExist and authorization and fsGunStatus and fsGunAmount and safeGunsTD then
            for i = 1, 9 do
                local idx = tostring(i)
                if fsGunStatus[idx] and fclick then
                    nextFsGun = false
                    fsTakeAmount = fsGunAmount[idx] or 0
                    fsGunStatus[idx] = false

                    if safeGunsTD[idx] then
                        sampSendClickTextdraw(safeGunsTD[idx])
                        wait(math.max(0, tonumber(fsafe and fsafe.wait) or 75))
                    end
                    if safeGunsTD['Take'] then
                        sampSendClickTextdraw(safeGunsTD['Take'])
                    end

                    -- Never wait forever: a missing textdraw/server response must not leak a worker.
                    local deadline = os.clock() + 5
                    while not nextFsGun and os.clock() < deadline do
                        wait(25)
                    end
                    nextFsGun = true
                end
            end
            fclick = false
            fsClickExist = false
        end
    end
end

--------------------------------------------------------------------------------
-------------------------------------SBIV---------------------------------------
--------------------------------------------------------------------------------

function SbivFunc()
	while true do wait(0)
		if isKeysPressed(config.data[mynick()].small_tweaks.sbiv_key) and config.data[mynick()].small_tweaks.sbiv_status and isCharOnFoot(PLAYER_PED) and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() and authorization then
			sampSetSpecialAction(config.data[mynick()].small_tweaks.sbiv_int == 0 and 68 or 7)
		elseif wasReleased(config.data[mynick()].small_tweaks.sbiv_key) and authorization then
			sampSetSpecialAction(0)
		end
	end
end


--------------------------------------------------------------------------------
------------------------------------GETGUN--------------------------------------
--------------------------------------------------------------------------------

function GetGunFunc()
	while true do wait(0)
		if isKeysPressed(config.data[mynick()].getguns.key) and config.data[mynick()].getguns.status and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() and authorization then
			gg_evolve.getgun = true
			gg_evolve.getgun_st = 0
			gg_evolve.getgun_list = {
				{config.data[mynick()].getguns.deagle, 0},
				{config.data[mynick()].getguns.shotgun, 1},
				{config.data[mynick()].getguns.rifle, 2},
				{config.data[mynick()].getguns.ak, 4},
				{config.data[mynick()].getguns.m4, 3},
				{0, 5},
				{0, 6},
				{config.data[mynick()].getguns.armor and 1 or 0, 7}
			}
			
			repeat
				wait(0)
			until os.clock() * 1000 - antiflood > 1000
			sampSendChat("/getgun")
		end
	
	
		if getServerName() == "Saint" and not sampIsDialogActive() and not sampIsChatInputActive() and not sampIsCursorActive() then
			if gg_evolve.func ~= nil then
				gg_evolve.func()
				gg_evolve.func = nil
			end
		end

		if config.data[mynick()] ~= nil and config.data[mynick()].getguns.status and authorization and healme then
			if getCharHealth(PLAYER_PED) < 100 and check_mafia() then  --getCharModel(PLAYER_PED) == 1
				repeat
                    wait(0)
                until os.clock() * 1000 - antiflood > 1000
				sampSendChat("/healme")
				wait(600)
			else
				healme = false
			end
		end
    end
end

function check_mafia()
	list_mafia_skin = { 111, 112, 113, 117, 118, 120, 123, 124, 125, 126, 127, 186, 223 }
	for k, v in pairs(list_mafia_skin) do
		if getCharModel(PLAYER_PED) == v then
			return true
		end
	end
	return false
end

function pr_marker_Func()
    while true do 
        wait(200)
        if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then
            local myPed = playerPed
            
            for _, ped in ipairs(getAllChars()) do
                if ped ~= myPed and doesCharExist(ped) then
                    local result, id = sampGetPlayerIdByCharHandle(ped)
                    if result and target_players[id] then
                        setCharVisible(ped, false) 
                        setCharIsTargetPriority(ped, 0)
                    end
                end
            end
        end
    end
end

function is_whitelisted(playerId)
    if sampIsPlayerConnected(playerId) then
        local name = sampGetPlayerNickname(playerId)
		if help_pr ~= nil then
			whitelist_names = help_pr
		end
		if whitelist_names ~= nil then

        for _, whitelisted_name in pairs(whitelist_names) do
            if whitelisted_name == sampGetPlayerNickname(playerId) then
                return true
            end
        end
	    end
    end
    return false
end
-- Перехватываем появление игрока, чтобы узнать его цвет
function sampev.onPlayerStreamIn(playerId, team, color33, position, rotation, view, state)
	if load_all then
    if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then
        local result, myId = sampGetPlayerIdByCharHandle(playerPed)
		local color33 = sampGetPlayerColor(playerId)

        if result and playerId ~= myId then
            -- Если игрок в белом списке, принудительно оставляем его видимым (false)
            if is_whitelisted(playerId) and config.data[mynick()].pr.family then
                target_players[playerId] = false
            -- Проверяем, есть ли цвет игрока в нашем массиве и равен ли он true
            elseif color_filter[color33] == true then
                target_players[playerId] = true -- Заносим в список на удаление
            else
                target_players[playerId] = false -- Оставляем видимым
            end
        end
    end
end
    return true
end

-- Сдвигаем координаты вниз только для тех, кто попал под фильтр удаления
function sampev.onPlayerSync(playerId, data)
	if load_all then
    if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then
        local result, myId = sampGetPlayerIdByCharHandle(playerPed)
        if result and playerId ~= myId then
            if target_players[playerId] == true then
                data.position.z = data.position.z - 50.0 -- Ники лаунчера уйдут под землю
                return {playerId, data}
            end
        end
    end
end
end
vehs = {
	478,
	535,
	422,
	543,
	600,
	554
}
function isInVeh(arg_15_0)
	if arg_15_0 ~= 0 then
		for iter_15_0, iter_15_1 in pairs(vehs) do
			if iter_15_1 == arg_15_0 then
				return true
			end
		end
	end

	return false
end


-- Блокируем аксессуары только для удаляемых игроков
function sampev.onSetPlayerAttachedObject(playerId, index, create, model, bone, offset, rotation, scale, color1, color2)
	if load_all then
    if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then
        local result, myId = sampGetPlayerIdByCharHandle(playerPed)
        if result and playerId ~= myId then
            if target_players[playerId] == true then
                return false 
            end
        end
    end
end
end

-- Блокируем 3D тексты только для удаляемых игроков
function sampev.onCreate3DTextLabel(id, color, position, distance, loseLOS, playerId, vehicleId, text)
	if load_all then
    if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then 
        if playerId ~= 65535 and playerId ~= nil then
            local result, myId = sampGetPlayerIdByCharHandle(playerPed)
            if result and playerId ~= myId then
                if target_players[playerId] == true then
                    return false 
                end
            end
        end
    end
end
end

-- Очищаем локальную историю игрока при выходе из зоны стрима
function sampev.onPlayerStreamOut(playerId)
	if load_all then
    if config.data[mynick()] ~= nil and config.data[mynick()].pr.marker and config.data[mynick()].pr.status then
        target_players[playerId] = nil
    end
end
end



function autoreport()
    imgui.ToggleButtonTextGear2("Авторепорт", autoreport_status, function()
        config.data[mynick()].autoreport.status = not config.data[mynick()].autoreport.status
        config_save(config.data)
    end)  

	    imgui.ToggleButtonTextGear2("Только во время капта", autoreport_capt_status, function()
        config.data[mynick()].autoreport.capture = not config.data[mynick()].autoreport.capture
        config_save(config.data)
    end) 
    
    imgui.Spacing()
    if imgui.Button("Добавить##add_report", imgui.ImVec2(390,20)) then
        config.data[mynick()].autoreport.list_prichin[#config.data[mynick()].autoreport.list_prichin + 1] = ""
        config_save(config.data)
    end
    for i = 1, #config.data[mynick()].autoreport.list_prichin do
        autoreptext[i] = imgui.new.char[256](config.data[mynick()].autoreport.list_prichin[i])
        imgui.PushItemWidth(357)
        if imgui.InputText("##report"..i, autoreptext[i], sizeof(autoreptext[i])) then
            config.data[mynick()].autoreport.list_prichin[i] = str(autoreptext[i])
            config_save(config.data)
        end
        imgui.SameLine()
        if imgui.Button(fa.TRASH.."##trash_report"..i, imgui.ImVec2(25,20)) then
                    table.remove(config.data[mynick()].autoreport.list_prichin, i)
                    config_save(config.data)
                    break
        end
        imgui.Question("Удалить")
    end
    if imgui.Button("Сбросить##reset_report", imgui.ImVec2(390,25)) then
        config.data[mynick()].autoreport.list_prichin = {
            "aim",
            "aimbot",
            "salo",
            "fast anim",
            "bpl",
            "fast deagle",
			"cheat", 
        }
        config_save(config.data)
    end

    imgui.Spacing()

    if imgui.Button("+##wait_autoreport", imgui.ImVec2(20,20)) then
        config.data[mynick()].autoreport.wait = config.data[mynick()].autoreport.wait + 500
        config_save(config.data)
    end
    imgui.SameLine()
    if imgui.Button("-##wait_ar", imgui.ImVec2(20,20)) then
        config.data[mynick()].autoreport.wait = config.data[mynick()].autoreport.wait - 250
        if config.data[mynick()] ~= nil and config.data[mynick()].autoreport.wait < 0 then
            config.data[mynick()].autoreport.wait = 0
        end
        config_save(config.data)
    end
    imgui.SameLine()
    imgui.Text("Wait: "..config.data[mynick()].autoreport.wait .. " ms")
	
end



function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
    if playerId ~= 65535 and damage > 1 and sampGetPlayerColor(playerId) ~= sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
        killerId = playerId
	end
end
function check_clist(id) 
    if not sampIsPlayerConnected(id) then
        return false
    end

    if sampGetPlayerColor(id) == sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) then
        return false
    end

    for k, v in pairs(bikerlist_organization) do
        if sampGetPlayerColor(id) == k then
            return true
        end
    end
    
    return false
end



---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
----------------------------------------ADDITIONAL FUNCTIONS---------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function update(php)
    local dlstatus = require("moonloader").download_status
    local json = getWorkingDirectory() .. "\\Palenation Tool Extended.json"
  
    if doesFileExist(json) then os.remove(json) end

    local ffi = require "ffi"
    ffi.cdef [[
        int __stdcall GetVolumeInformationA(
                const char* lpRootPathName,
                char* lpVolumeNameBuffer,
                uint32_t nVolumeNameSize,
                uint32_t* lpVolumeSerialNumber,
                uint32_t* lpMaximumComponentLength,
                uint32_t* lpFileSystemFlags,
                char* lpFileSystemNameBuffer,
                uint32_t nFileSystemNameSize
        );
        ]]
    local serial = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    serial = serial[0]
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local nickname = sampGetPlayerNickname(myid)
    if thisScript().name == "ADBLOCK" then
      if mode == nil then
        mode = "unsupported"
      end
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&m=" .. mode .. "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    elseif thisScript().name == "pisser" then
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&m=" ..
      tostring(data.options.stats) ..
      "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    else
      php =
      php ..
      "?id=" ..
      serial ..
      "&n=" ..
      nickname ..
      "&i=" ..
      sampGetCurrentServerAddress() ..
      "&v=" .. getMoonloaderVersion() .. "&sv=" .. thisScript().version
    end
    downloadUrlToFile(
      php,
      json,
      function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
          if doesFileExist(json) then
            local f = io.open(json, "r")
            if f then
              local info = decodeJson(f:read("*a"))
              if info.stats ~= nil then
                stats = info.stats
              end
              updatelink = info.updateurl
              updateversion = info.version
              f:close()
              os.remove(json)
              if updateversion ~= thisScript().version then
                eventThreadCreate(
                  function(prefix, komanda)
                    local dlstatus = require("moonloader").download_status
                    local color = -1
                    sampAddChatMessage(
                      ("{C0C0C0}[Palenation Tool Extended]{FFFFFF} Обнаружено обновление. Пытаюсь обновиться c версии " ..
                      thisScript().version .. " на версию " .. updateversion),
                      color
                    )
                    wait(250)
                    downloadUrlToFile(
                      updatelink,
                      thisScript().path,
                      function(id3, status1, p13, p23)
                        if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                          print(string.format("Загружено %d из %d.", p13, p23))
                        elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                          print("Загрузка обновления завершена.")
                            sampAddChatMessage(
                              ("{C0C0C0}[Palenation Tool Extended]{FFFFFF} Обновление завершено!"),
                              color
                        )
                          lua_thread.create(
                            function()
                              wait(500)
                              thisScript():reload()
                            end
                          )
                        end
                      end
                    )
                  end,
                  prefix
                )
              else
                update = false
                print("v" .. thisScript().version .. ": Обновление не требуется.")
              end
            end
          else
            print(
              "v" ..
              thisScript().version ..
              ": Не могу проверить обновление."
            )
            update = false
          end
        end
      end
    )
end

function GetMats()
	while true do wait(0)
		if not check_get_mats then return end
		check_get_mats = false
		repeat wait(0) until os.clock() * 1000 - sleep > 1200 and sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) >= 1 and not sampIsDialogActive() and not sampIsChatInputActive()
		if config.data[mynick()] ~= nil and config.data[mynick()].drugtimer.boostinfo and check_boostinfo_status == nil and config.data[mynick()].drugtimer.status and authorization then
			check_boostinfo_status = os.time()
			check_boostinfo = 2
		end
    end
end


function split(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end


function findTextdrawByPos(x, y)
    for a = 0, 2304 do
        if sampTextdrawIsExists(a) then
            local x1, y1 = sampTextdrawGetPos(a)
            if math.ceil(x1) == x and math.ceil(y1) == y then
                return true
            end
        end
    end
    return false
end


function getServerName()
    local result = ""
    local server = sampGetCurrentServerName():gsub("|", "")
    local server_find = { "Saint" }
    for i = 1, #server_find do
        if server:find(server_find[i]) then
            result = server_find[i]
        end
    end
    return result
end


function text_to_table()
	while true do wait(0)
		renderText[3] = {}
		renderText[4] = {}
	
		for str in string.gmatch(config.data[mynick()].lines.one:gsub("!n", "\n"), '[^\n]+') do
			renderText[3][#renderText[3] + 1] = str
		end
	
		for str in string.gmatch(config.data[mynick()].lines.two:gsub("!n", "\n"), '[^\n]+') do
			renderText[4][#renderText[4] + 1] = str
		end
    end
end


weapon_sync = {}
function getAmmoByGunId(id)
    return (weapon_sync[id] == nil and 0 or weapon_sync[id])
end

function sampGetPlayerIdByNickname(nick)
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
        return i
      end
    end
    return 0
end

imgui.PageButton = function(bool, icon, name, but_wide)
    but_wide = but_wide or 190
    local duration = 0.25
    local DL = imgui.GetWindowDrawList()
    local p1 = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
      
    if not AI_PAGE[name] then
        AI_PAGE[name] = { clock = nil }
    end
    local pool = AI_PAGE[name]

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 35))
    if result and not bool then
        pool.clock = os.clock()
    end
    local pressed = imgui.IsItemActive()
    imgui.PopStyleColor(3)
    if bool then
        if pool.clock and (os.clock() - pool.clock) < duration then
            local wide = (os.clock() - pool.clock) * (but_wide / duration)
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2((p1.x + 190) - wide, p1.y + 35), 0x10FFFFFF, 15, 10)
               DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 35), ToU32(col))
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
        else
            DL:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y + 3 or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 32 or p1.y + 35)), ToU32(col))
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
        end
    else
        if imgui.IsItemHovered() then
            DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), 0x10FFFFFF, 15, 10)
        end
    end
    imgui.SameLine(10); imgui.SetCursorPosY(p2.y + 8)
    if bool then
        imgui.Text((' '):rep(3) .. icon)
        imgui.SameLine(45)
        imgui.Text(name)
    else
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3) .. icon)
        imgui.SameLine(45)
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), name)
    end
    imgui.SetCursorPosY(p2.y + 40)
    return result
end


function sampev.onSetPlayerName(playerId, name)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if playerId ~= myId then
        return
    end

    -- При смене ника создаем только новый профиль из выбранного главного.
    -- Существующий профиль никогда не перезаписываем.
    local normalizedName = normalizeProfileNick(name)
    if normalizedName and normalizedName ~= "" and config.data[normalizedName] == nil then
        ensureProfile(normalizedName)
    end
end

function imgui.PageButton2(active, icon, text, width, height)
    width = width or imgui.GetContentRegionAvail().x
    height = height or 25

    local dl = imgui.GetWindowDrawList()
    local pos = imgui.GetCursorScreenPos()

    if not AI_PAGE[text] then
        AI_PAGE[text] = { clock = nil }
    end

    local pool = AI_PAGE[text]
    local duration = 0.25

    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0,0,0,0))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0,0,0,0))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0,0,0,0))

    local pressed = imgui.InvisibleButton("##"..text, imgui.ImVec2(width, height))

    imgui.PopStyleColor(3)

    if pressed and not active then
        pool.clock = os.clock()
    end

    local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]

    if active then
        if pool.clock and (os.clock() - pool.clock) < duration then
            local wide = (os.clock() - pool.clock) * (width / duration)

            dl:AddRectFilled(
                imgui.ImVec2(pos.x, pos.y),
                imgui.ImVec2(pos.x + wide, pos.y + height),
                ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)),
                0
            )
        else
            dl:AddRectFilled(
                imgui.ImVec2(pos.x, pos.y),
                imgui.ImVec2(pos.x + width, pos.y + height),
                ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)),
                0
            )
        end
    elseif imgui.IsItemHovered() then
        dl:AddRectFilled(
            imgui.ImVec2(pos.x, pos.y),
            imgui.ImVec2(pos.x + width, pos.y + height),
            0x10FFFFFF,
            0
        )
    end

    local txtColor = active
        and ToU32(imgui.ImVec4(1,1,1,1))
        or ToU32(imgui.ImVec4(0.75,0.75,0.75,1))

    local txtSize = imgui.CalcTextSize(text)

    dl:AddText(
        imgui.ImVec2(
            pos.x + (width - txtSize.x) / 2,
            pos.y + (height - txtSize.y) / 2
        ),
        txtColor,
        text
    )

    return pressed
end

local font_bold = nil

imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
	if status_fa then fa.Init() end

    -- Загружаем жирный шрифт ПОСЛЕ FontAwesome, чтобы иконки не пропадали.
    local bold_font_path = getFolderPath(0x14) .. "\\arialbd.ttf"
    if doesFileExist(bold_font_path) then
        local ok, loaded_font = pcall(function()
            return imgui.GetIO().Fonts:AddFontFromFileTTF(
                bold_font_path,
                14.1,
                nil,
                imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
            )
        end)
        if ok and loaded_font then
            font_bold = loaded_font
        end
    end

    -- Делаем текст всех Combo жирным.
    if font_bold then
        local originalCombo = imgui.Combo
        imgui.Combo = function(...)
            imgui.PushFont(font_bold)
            local result = originalCombo(...)
            imgui.PopFont()
            return result
        end
    end
    mimguiStyle()
	local var_3_033 = imgui.ColorConvertU32ToFloat4(config.data[mynick()].squad.color)
	local var_3_034 = imgui.ColorConvertU32ToFloat4(config.data[mynick()].render_gun.color)
	castom_color_squad = new.float[4](var_3_033.x, var_3_033.y, var_3_033.z, var_3_033.w)
	color_ld = new.float[4](var_3_034.x, var_3_034.y, var_3_034.z, var_3_034.w)
    if doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\Russia.png') and doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\English.png') and doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\discord.png') and doesFileExist(getWorkingDirectory()..'\\Palenation Tool Extended\\resource\\vk.png') then -- находим необходимую картинку с названием example.png в папке moonloader/resource/
		Russian_Flag = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Palenation Tool Extended\\resource\\Russia.png') -- если найдена, то записываем в переменную хендл картинки
		English_Flag = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Palenation Tool Extended\\resource\\English.png') -- если найдена, то записываем в переменную хендл картинки
		DS = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Palenation Tool Extended\\resource\\discord.png')
		VK = imgui.CreateTextureFromFile(getWorkingDirectory() .. '\\Palenation Tool Extended\\resource\\vk.png')
    end

    -- Background/watermark for the main PALERIDERS window.
    local paleridersBgPath = getWorkingDirectory() .. '\\Palenation Tool Extended\\resource\\paleriders.png'
    if doesFileExist(paleridersBgPath) then
        PaleridersBackground = imgui.CreateTextureFromFile(paleridersBgPath)
    end
end)

function getLocalPlayerNickname()
    return sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
end

imgui.ToggleButtonTextGear = function(text, bool, is_toggle, is_render_gear, is_click_gear)
    if imgui.ToggleButton(text, bool) then
        is_toggle()
    end

    if is_render_gear then
        imgui.SameLine()
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
        imgui.Text(fa["GEAR"])
        if imgui.IsItemClicked() then
            is_click_gear()
        end
        imgui.SameLine()

        if font_bold then imgui.PushFont(font_bold) end
        imgui.TextColoredRGB((not bool[0] and "{525252}" or "") .. text)
        if font_bold then imgui.PopFont() end

        if imgui.IsItemClicked() then
            is_click_gear()
        end
    else
        imgui.SameLine()
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
        imgui.TextColoredRGB("{525252}" .. fa["GEAR"])
        imgui.SameLine()

        if font_bold then imgui.PushFont(font_bold) end
        imgui.TextColoredRGB((not bool[0] and "{525252}" or "") .. text)
        if font_bold then imgui.PopFont() end
    end
end

imgui.ToggleButtonTextGear2 = function(text, bool, is_toggle, is_render_gear, is_click_gear)
    -- Рисуем сам тогл. Чтобы он не уезжал, перед этой функцией не должно быть лишних SameLine
    if imgui.ToggleButton(text, bool) then
        is_toggle()
    end

    imgui.SameLine()

    if is_render_gear then
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)

        if imgui.IsItemClicked() then
            is_click_gear()
        end

        if font_bold then imgui.PushFont(font_bold) end
        imgui.TextColoredRGB((not bool[0] and "{525252}" or "") .. text)
        if font_bold then imgui.PopFont() end

        if imgui.IsItemClicked() then
            is_click_gear()
        end
    else
        imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)

        if font_bold then imgui.PushFont(font_bold) end
        imgui.TextColoredRGB((not bool[0] and "{525252}" or "") .. text)
        if font_bold then imgui.PopFont() end
    end
end

function capture_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].AutoCapt.com) then
        sampUnregisterChatCommand(config.data[mynick()].AutoCapt.com)
    end

    sampRegisterChatCommand(config.data[mynick()].AutoCapt.com,function()
        AutoCapterstart = not AutoCapterstart
        printStringNow(AutoCapterstart and "~G~CAPTURE ACTIVATED" or "~R~CAPTURE STOP", 1000)
    end)
end

function antiafk_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].small_tweaks.antiafk_cmd) then
        sampUnregisterChatCommand(config.data[mynick()].small_tweaks.antiafk_cmd)
    end

    sampRegisterChatCommand(config.data[mynick()].small_tweaks.antiafk_cmd,function()
        config.data[mynick()].small_tweaks.antiafk = not config.data[mynick()].small_tweaks.antiafk
		msg(config.data[mynick()].small_tweaks.antiafk and "Antiafk activated" or "Antiafk deactivated")
		status_antiafk[0] = not status_antiafk[0]
        config_save(config.data)
    end)
end

function gd_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].good_drive.cmd) then
        sampUnregisterChatCommand(config.data[mynick()].good_drive.cmd)
    end

    sampRegisterChatCommand(config.data[mynick()].good_drive.cmd,function()
        config.data[mynick()].good_drive.status = not config.data[mynick()].good_drive.status
		msg(config.data[mynick()].good_drive.status and "Нормальная езда без колес активирована" or "Нормальная езда без колес деактивирована")
		gd_status[0] = not gd_status[0]
        config_save(config.data)

		if config.data[mynick()] ~= nil and config.data[mynick()].good_drive.status then gd_activated[0] = 1 else gd_activated[0] = 0 end
    end)
end

function truck_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].small_tweaks.truck_command) then
        sampUnregisterChatCommand(config.data[mynick()].small_tweaks.truck_command)
    end

    sampRegisterChatCommand(config.data[mynick()].small_tweaks.truck_command,function()
		truck_flooder = not truck_flooder
		msg(truck_flooder and "Флуд /materials get и /bput запущен." or "Флуд /materials get и /bput остановлен.")
    end)
end

function flooder_cmd_register()
    if sampIsChatCommandDefined(config.data[mynick()].AutoCapt.flooder_com) then
        sampUnregisterChatCommand(config.data[mynick()].AutoCapt.flooder_com)
    end

	sampRegisterChatCommand(config.data[mynick()].AutoCapt.flooder_com, function(arg)
		if config.data[mynick()] ~= nil and config.data[mynick()].AutoCapt.flooder_status then
		if not flood then msg((config.data[mynick()].language.number == 1 and 'Флудер запущен.' or "The flooder is running.")) end
		if flood then flood = false msg((config.data[mynick()].language.number == 1 and 'Флудер остановлен.' or 'Flooder has stopped.')) return end
		if #arg == 0 or not arg:find('^(.-) (.+)') then return msg((config.data[mynick()].language.number == 1 and 'Ошибка, используйте: /flood [sec] [text]' or 'Error, use: /flood [sec] [text]')) end
		local sec, text = arg:match('^(.-) (.+)')
		if #text == 0 or not tonumber(sec) then return msg((config.data[mynick()].language.number == 1 and 'Ошибка, используйте: /flood [sec] [text]' or 'Error, use: /flood [sec] [text]')) end
		flooder(tonumber(sec), text)
		end
	end)
end

imgui.ToggleButtonText = function(text, bool, is_toggle)
    if imgui.ToggleButton(text, bool) then
        is_toggle()
    end
    imgui.SameLine()
    imgui.SetCursorPosY(imgui.GetCursorPosY()+1)
    imgui.TextColoredRGB((not bool[0] and "{525252}" or "")..text)
end


function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end

    render_text(text)
end


function getTextdrawByPos(x,y)
    for a = 0, 2304 do
        if sampTextdrawIsExists(a) then
            local x1, y1 = sampTextdrawGetPos(a)
            if math.ceil(x1) == x and math.ceil(y1) == y then
                return true, a
            end
        end
    end
    return false, -1
end


function mimguiStyle()
    local style = imgui.GetStyle();
    local colors = style.Colors;
    style.Alpha = 1;
    style.WindowPadding = imgui.ImVec2(8.00, 8.00);
    style.WindowRounding = 7;
    style.WindowBorderSize = 1;
    style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildRounding = 0;
    style.ChildBorderSize = 1;
    style.PopupRounding = 0;
    style.PopupBorderSize = 1;
    style.FramePadding = imgui.ImVec2(4.00, 3.00);
    style.FrameRounding = 0;
    style.FrameBorderSize = 0;
    style.ItemSpacing = imgui.ImVec2(8.00, 4.00);
    style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
    style.IndentSpacing = 21;
    style.ScrollbarSize = 14;
    style.ScrollbarRounding = 9;
    style.GrabMinSize = 10;
    style.GrabRounding = 0;
    style.TabRounding = 4;
    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
    style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
    colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, 0.94);
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.PopupBg] = imgui.ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
--	imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.00)
    colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.35, 0.37, 0.39, 0.54);
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.34, 0.35, 0.35, 0.40);
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.45, 0.45, 0.45, 0.67);
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1.00);
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.27, 0.27, 0.27, 1.00);
    colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.53);
    colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
    colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.Button] = imgui.ImVec4(0.53, 0.53, 0.53, 0.40);
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.19, 0.19, 0.19, 1.00);
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
    colors[imgui.Col.Header] = imgui.ImVec4(0.56, 0.56, 0.56, 0.31);
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.39, 0.39, 0.39, 0.80);
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.43, 0.43, 0.43, 1.00);
    colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
    colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.48, 0.48, 0.48, 0.78);
    colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.26, 0.26, 0.26, 1.00);
    colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.40, 0.40, 0.40, 0.25);
    colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.51, 0.51, 0.51, 0.67);
    colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.50, 0.50, 0.50, 0.95);
    colors[imgui.Col.Tab] = imgui.ImVec4(0.36, 0.36, 0.36, 0.86);
    colors[imgui.Col.TabHovered] = imgui.ImVec4(0.45, 0.45, 0.45, 0.80);
    colors[imgui.Col.TabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
    colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
    colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
    colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
    colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
    colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
    colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
    colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end



function imgui.CenterText(text)
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
	imgui.Text(text)
end

function msg(text)
    sampAddChatMessage("{C0C0C0}[Palenation Tool Extended]{FFFFFF} "..text, -1)
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if wparam == keys.VK_ESCAPE and Menu[0] then
            consumeWindowMessage(true, false)
            if msg == 0x101 then Menu[0] = false end
		end

		if wparam == keys.VK_ESCAPE and BikerlistMenu[0] then
            consumeWindowMessage(true, false)
            if msg == 0x101 then BikerlistMenu[0] = false end
		end
    end
end

function argb2abgr(arg_23_0)
	return (bit.bor(bit.lshift(bit.band(bit.rshift(arg_23_0, 24), 255), 24), bit.lshift(bit.band(arg_23_0, 255), 16), bit.lshift(bit.band(bit.rshift(arg_23_0, 8), 255), 8), bit.band(bit.rshift(arg_23_0, 16), 255)))
end


function flooder(sec, text)
	flood = not flood
	lua_thread.create(function()
		while flood do
			sampSendChat(text)
			wait(sec*1000)
		end
	end)
end
function hextoargb(hex)
    local hex = hex:gsub("#","")
    r = tonumber("0x"..hex:sub(1,2))
    g = tonumber("0x"..hex:sub(3,4))
    b = tonumber("0x"..hex:sub(5,6))
    a = tonumber("0x"..hex:sub(7,8))
    
    if a == nil then a = 255 end
    return a,r,g,b
end

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.IconButton(label, size)
    imgui.Image(label, size)
    if imgui.IsItemClicked() then
		return true
    end
end

function check_table(table, value)
    for k, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function index_number(table, value)
    for k, v in pairs(table) do
        if v == value then
            return k
        end
    end
    return -1
end





function sampGetPlayerIdByNickname(nick) -- https://blast.hk/threads/13380/page-2#post-164090
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end

function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end



-- Отправитель: Контрабандист -65366
-- Контрабандист -858993409
-- Текст принимает как есть, для кирилицы используйте библиотеку encoding
-- Время можно указывать с милисекундами, например 5.543
-- Стили:
-- 1 - Черный, простые сообщения
-- 2 - Синий/голубой - Информационные сообщения
-- 3 - Красный - Ошибки
-- В качестве параметра принимается таблица пользовательского стиля, к примеру:

------------>> SCRIPT UTF-8
------------>> utf8(table path, incoming variables encoding, outcoming variables encoding)
------------>> table path example { "sampev", "onShowDialog" }
------------>> encoding options nil | AnsiToUtf8 | Utf8ToAnsi
function imgui.TextColoredRGBwithShadow(text, shadow)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end

    local render_shadow = function(text_, shadow_)
        local shadow_offset = imgui.ImVec2(1, 1)
        local shadow_color = imgui.ImVec4(0, 0, 0, 1)

        local cursor_pos = imgui.GetCursorPos()

        for i = -shadow_, shadow_ do
            for j = -shadow_, shadow_ do
                if i ~= 0 or j ~= 0 then
                    local offset = imgui.ImVec2(i * shadow_offset.x, j * shadow_offset.y)
                    imgui.SetCursorPos(cursor_pos + offset)
                    imgui.TextColored(shadow_color, text_:gsub("{......}", ""))
                end
            end
        end
        imgui.SetCursorPos(cursor_pos)
    end


    local render_text = function(text_, shadow_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    if shadow_ then render_shadow(text[i], shadow_) end
                    imgui.TextColored(colors_[i] or colors[1], (text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else if shadow_ then render_shadow(w, shadow_) imgui.Text((w)) end end
        end
    end

    render_text(text, shadow)
end

-- @render menu

-- @render lists
--[[imgui.OnFrame(function() return statuses.render[0] or families.render[0] or config.data[mynick()].eblochecker.fam_status end, function(self)
    self.HideCursor = true
    if not script_enabled[0] or (statuses.text:len() < 1 and families.text:len() < 1) or isPauseMenuActive() then return end
imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.00)

    local res_x, res_y = getScreenResolution()
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.07, 0.07, 0.07, 0.00)
    if statuses.render[0] and statuses.text:len() > 1 then
        imgui.SetNextWindowPos(imgui.ImVec2(statuses.pos.x - statuses.text:len() / 1.5, statuses.pos.y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.1))
        imgui.SetNextWindowSize(imgui.ImVec2(350, 350), imgui.Cond.Always)
        imgui.Begin('##statuses', statuses.render, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus)
     if config.data[mynick()] ~= nil and config.data[mynick()].eblochecker.fam_status and config.data[mynick()].eblochecker.statuses then    imgui.TextColoredRGBwithShadow(u82(statuses.text), 1) end
    end
    if families.render[0] and families.text:len() > 1  then
        imgui.SetNextWindowPos(imgui.ImVec2(families.pos.x, families.pos.y), imgui.Cond.Always, imgui.ImVec2(0.5, 0.1))
        imgui.SetNextWindowSize(imgui.ImVec2(350, 350), imgui.Cond.Always)
        imgui.Begin('##families', families.render, imgui.WindowFlags.NoDecoration + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus)
         imgui.TextColoredRGBwithShadow(config.data[mynick()].eblochecker.fam_status and config.data[mynick()].eblochecker.families and u82(families.text) or "", 1) 
	--	msg(families.text)
    end
    imgui.End()
end)]]


function update_render_position(entity)
    showCursor(true, true)--xxyi
    local res_x, res_y = getScreenResolution()
    local x, y = getCursorPos()
    entity.pos.x = x
    entity.pos.y =  y
    if isKeyJustPressed(keys.VK_SPACE) then
        entity.pos.is_changing[0] = false
        showCursor(false, false)

        if entity == statuses then
            msg("Позиция онлайна статусов применена!")
            config.data[mynick()].statuses = {x = entity.pos.x, y = entity.pos.y}
            config_save(config.data)
        elseif entity == families then
            msg("Позиция онлайна семей применена!")
            config.data[mynick()].families = {x = entity.pos.x, y = entity.pos.y}
            config_save(config.data)
        end

    end
end

function showCursor2(toggle)
  if toggle and all_load then
    sampSetCursorMode(CMODE_LOCKCAM)
  elseif not toggle then
    sampToggleCursor(false)
  end
  cursorEnabled = toggle
end

function isKeyCanBePressed()
    if sampIsDialogActive() or sampIsChatInputActive() or isSampfuncsConsoleActive() then
        return false
    end
    return true
end


function GetWheelStatus(this, wheel)
    if gd_activated[0] == 1 then
        return 0
    end

    -- Native hook is optional now; never call a nil FFI function.
    if OrigGetWheelStatus then
        return OrigGetWheelStatus(this, wheel)
    end

    return 0
end
function emul_rpc(arg_1_0, arg_1_1)
	local var_1_0 = require("samp.events.bitstream_io")
	local var_1_1 = require("samp.events.handlers")
	local var_1_2 = require("samp.events.extra_types")
	local var_1_3 = {
		onInitGame = {
			139,
		},
		onPlayerJoin = {
			"int16",
			"int32",
			"bool8",
			"string8",
			137,
		},
		onPlayerQuit = {
			"int16",
			"int8",
			138,
		},
		onRequestClassResponse = {
			"bool8",
			"int8",
			"int32",
			"int8",
			"vector3d",
			"float",
			"Int32Array3",
			"Int32Array3",
			128,
		},
		onRequestSpawnResponse = {
			"bool8",
			129,
		},
		onSetPlayerName = {
			"int16",
			"string8",
			"bool8",
			11,
		},
		onSetPlayerPos = {
			"vector3d",
			12,
		},
		onSetPlayerPosFindZ = {
			"vector3d",
			13,
		},
		onSetPlayerHealth = {
			"float",
			14,
		},
		onTogglePlayerControllable = {
			"bool8",
			15,
		},
		onPlaySound = {
			"int32",
			"vector3d",
			16,
		},
		onSetWorldBounds = {
			"float",
			"float",
			"float",
			"float",
			17,
		},
		onGivePlayerMoney = {
			"int32",
			18,
		},
		onSetPlayerFacingAngle = {
			"float",
			19,
		},
		onGivePlayerWeapon = {
			"int32",
			"int32",
			22,
		},
		onSetPlayerTime = {
			"int8",
			"int8",
			29,
		},
		onSetToggleClock = {
			"bool8",
			30,
		},
		onPlayerStreamIn = {
			"int16",
			"int8",
			"int32",
			"vector3d",
			"float",
			"int32",
			"int8",
			32,
		},
		onSetShopName = {
			"string256",
			33,
		},
		onSetPlayerSkillLevel = {
			"int16",
			"int32",
			"int16",
			34,
		},
		onSetPlayerDrunk = {
			"int32",
			35,
		},
		onCreate3DText = {
			"int16",
			"int32",
			"vector3d",
			"float",
			"bool8",
			"int16",
			"int16",
			"encodedString4096",
			36,
		},
		onSetRaceCheckpoint = {
			"int8",
			"vector3d",
			"vector3d",
			"float",
			38,
		},
		onPlayAudioStream = {
			"string8",
			"vector3d",
			"float",
			"bool8",
			41,
		},
		onRemoveBuilding = {
			"int32",
			"vector3d",
			"float",
			43,
		},
		onCreateObject = {
			44,
		},
		onSetObjectPosition = {
			"int16",
			"vector3d",
			45,
		},
		onSetObjectRotation = {
			"int16",
			"vector3d",
			46,
		},
		onDestroyObject = {
			"int16",
			47,
		},
		onPlayerDeathNotification = {
			"int16",
			"int16",
			"int8",
			55,
		},
		onSetMapIcon = {
			"int8",
			"vector3d",
			"int8",
			"int32",
			"int8",
			56,
		},
		onRemoveVehicleComponent = {
			"int16",
			"int16",
			57,
		},
		onRemove3DTextLabel = {
			"int16",
			58,
		},
		onPlayerChatBubble = {
			"int16",
			"int32",
			"float",
			"int32",
			"string8",
			59,
		},
		onUpdateGlobalTimer = {
			"int32",
			60,
		},
		onShowDialog = {
			"int16",
			"int8",
			"string8",
			"string8",
			"string8",
			"encodedString4096",
			61,
		},
		onDestroyPickup = {
			"int32",
			63,
		},
		onLinkVehicleToInterior = {
			"int16",
			"int8",
			65,
		},
		onSetPlayerArmour = {
			"float",
			66,
		},
		onSetPlayerArmedWeapon = {
			"int32",
			67,
		},
		onSetSpawnInfo = {
			"int8",
			"int32",
			"int8",
			"vector3d",
			"float",
			"Int32Array3",
			"Int32Array3",
			68,
		},
		onSetPlayerTeam = {
			"int16",
			"int8",
			69,
		},
		onPutPlayerInVehicle = {
			"int16",
			"int8",
			70,
		},
		onSetPlayerColor = {
			"int16",
			"int32",
			72,
		},
		onDisplayGameText = {
			"int32",
			"int32",
			"string32",
			73,
		},
		onAttachObjectToPlayer = {
			"int16",
			"int16",
			"vector3d",
			"vector3d",
			75,
		},
		onInitMenu = {
			76,
		},
		onShowMenu = {
			"int8",
			77,
		},
		onHideMenu = {
			"int8",
			78,
		},
		onCreateExplosion = {
			"vector3d",
			"int32",
			"float",
			79,
		},
		onShowPlayerNameTag = {
			"int16",
			"bool8",
			80,
		},
		onAttachCameraToObject = {
			"int16",
			81,
		},
		onInterpolateCamera = {
			"bool",
			"vector3d",
			"vector3d",
			"int32",
			"int8",
			82,
		},
		onGangZoneStopFlash = {
			"int16",
			85,
		},
		onApplyPlayerAnimation = {
			"int16",
			"string8",
			"string8",
			"bool",
			"bool",
			"bool",
			"bool",
			"int32",
			86,
		},
		onClearPlayerAnimation = {
			"int16",
			87,
		},
		onSetPlayerSpecialAction = {
			"int8",
			88,
		},
		onSetPlayerFightingStyle = {
			"int16",
			"int8",
			89,
		},
		onSetPlayerVelocity = {
			"vector3d",
			90,
		},
		onSetVehicleVelocity = {
			"bool8",
			"vector3d",
			91,
		},
		onServerMessage = {
			"int32",
			"string32",
			93,
		},
		onSetWorldTime = {
			"int8",
			94,
		},
		onCreatePickup = {
			"int32",
			"int32",
			"int32",
			"vector3d",
			95,
		},
		onMoveObject = {
			"int16",
			"vector3d",
			"vector3d",
			"float",
			"vector3d",
			99,
		},
		onEnableStuntBonus = {
			"bool",
			104,
		},
		onTextDrawSetString = {
			"int16",
			"string16",
			105,
		},
		onSetCheckpoint = {
			"vector3d",
			"float",
			107,
		},
		onCreateGangZone = {
			"int16",
			"vector2d",
			"vector2d",
			"int32",
			108,
		},
		onPlayCrimeReport = {
			"int16",
			"int32",
			"int32",
			"int32",
			"int32",
			"vector3d",
			112,
		},
		onGangZoneDestroy = {
			"int16",
			120,
		},
		onGangZoneFlash = {
			"int16",
			"int32",
			121,
		},
		onStopObject = {
			"int16",
			122,
		},
		onSetVehicleNumberPlate = {
			"int16",
			"string8",
			123,
		},
		onTogglePlayerSpectating = {
			"bool32",
			124,
		},
		onSpectatePlayer = {
			"int16",
			"int8",
			126,
		},
		onSpectateVehicle = {
			"int16",
			"int8",
			127,
		},
		onShowTextDraw = {
			134,
		},
		onSetPlayerWantedLevel = {
			"int8",
			133,
		},
		onTextDrawHide = {
			"int16",
			135,
		},
		onRemoveMapIcon = {
			"int8",
			144,
		},
		onSetWeaponAmmo = {
			"int8",
			"int16",
			145,
		},
		onSetGravity = {
			"float",
			146,
		},
		onSetVehicleHealth = {
			"int16",
			"float",
			147,
		},
		onAttachTrailerToVehicle = {
			"int16",
			"int16",
			148,
		},
		onDetachTrailerFromVehicle = {
			"int16",
			149,
		},
		onSetWeather = {
			"int8",
			152,
		},
		onSetPlayerSkin = {
			"int32",
			"int32",
			153,
		},
		onSetInterior = {
			"int8",
			156,
		},
		onSetCameraPosition = {
			"vector3d",
			157,
		},
		onSetCameraLookAt = {
			"vector3d",
			"int8",
			158,
		},
		onSetVehiclePosition = {
			"int16",
			"vector3d",
			159,
		},
		onSetVehicleAngle = {
			"int16",
			"float",
			160,
		},
		onSetVehicleParams = {
			"int16",
			"int16",
			"bool8",
			161,
		},
		onChatMessage = {
			"int16",
			"string8",
			101,
		},
		onConnectionRejected = {
			"int8",
			130,
		},
		onPlayerStreamOut = {
			"int16",
			163,
		},
		onVehicleStreamIn = {
			164,
		},
		onVehicleStreamOut = {
			"int16",
			165,
		},
		onPlayerDeath = {
			"int16",
			166,
		},
		onPlayerEnterVehicle = {
			"int16",
			"int16",
			"bool8",
			26,
		},
		onUpdateScoresAndPings = {
			"PlayerScorePingMap",
			155,
		},
		onSetObjectMaterial = {
			84,
		},
		onSetObjectMaterialText = {
			84,
		},
		onSetVehicleParamsEx = {
			"int16",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			"int8",
			24,
		},
		onSetPlayerAttachedObject = {
			"int16",
			"int32",
			"bool",
			"int32",
			"int32",
			"vector3d",
			"vector3d",
			"vector3d",
			"int32",
			"int32",
			113,
		},
	}
	local var_1_4 = {
		onCreateObject = true,
		onInitGame = true,
		onInitMenu = true,
		onSetObjectMaterial = true,
		onSetObjectMaterialText = true,
		onShowTextDraw = true,
		onVehicleStreamIn = true,
	}
	local var_1_5 = {
		Int32Array3 = true,
		PlayerScorePingMap = true,
	}
	local var_1_6 = var_1_3[arg_1_0]

	if var_1_6 then
		local var_1_7 = raknetNewBitStream()

		if not var_1_4[arg_1_0] then
			local var_1_8 = #var_1_6 - 1

			if var_1_8 > 0 then
				for iter_1_0 = 1, var_1_8 do
					local var_1_9 = var_1_6[iter_1_0]

					if var_1_5[var_1_9] then
						var_1_2[var_1_9].write(var_1_7, arg_1_1[iter_1_0])
					else
						var_1_0[var_1_9].write(var_1_7, arg_1_1[iter_1_0])
					end
				end
			end
		elseif arg_1_0 == "onInitGame" then
			var_1_1.on_init_game_writer(var_1_7, arg_1_1)
		elseif arg_1_0 == "onCreateObject" then
			var_1_1.on_create_object_writer(var_1_7, arg_1_1)
		elseif arg_1_0 == "onInitMenu" then
			var_1_1.on_init_menu_writer(var_1_7, arg_1_1)
		elseif arg_1_0 == "onShowTextDraw" then
			var_1_1.on_show_textdraw_writer(var_1_7, arg_1_1)
		elseif arg_1_0 == "onVehicleStreamIn" then
			var_1_1.on_vehicle_stream_in_writer(var_1_7, arg_1_1)
		elseif arg_1_0 == "onSetObjectMaterial" then
			var_1_1.on_set_object_material_writer(var_1_7, arg_1_1, 1)
		elseif arg_1_0 == "onSetObjectMaterialText" then
			var_1_1.on_set_object_material_writer(var_1_7, arg_1_1, 2)
		end

		raknetEmulRpcReceiveBitStream(var_1_6[#var_1_6], var_1_7)
		raknetDeleteBitStream(var_1_7)
	end
end


function installCallHook(hookType, installAddr, castedHookFunc)
    assert(ENABLE_UNSAFE_NATIVE_HOOKS, 'native hooks are disabled by safety setting')
    assert(ffi and ffi.C and ffi.C.VirtualProtect, 'FFI/VirtualProtect unavailable')

    local hookAddr = ffi.cast('void*', installAddr)
    local original = ffi.new('uint8_t[5]')
    ffi.copy(original, hookAddr, 5)

    local hookArray = ffi.new('uint8_t[?]', 5, 0x90)
    hookArray[0] = 0xE8

    local rel = ffi.cast('intptr_t', ffi.cast('void*', castedHookFunc)) - installAddr - 5
    assert(rel >= -0x80000000 and rel <= 0x7fffffff, 'hook target is out of 32-bit CALL range')
    ffi.cast('int32_t*', hookArray + 1)[0] = rel

    local oldProtect = ffi.new('unsigned long[1]')
    assert(ffi.C.VirtualProtect(hookAddr, 5, 0x40, oldProtect) ~= 0, 'VirtualProtect failed')

    local ok, err = pcall(function()
        ffi.copy(hookAddr, hookArray, 5)
    end)

    if not ok then
        pcall(function()
            ffi.C.VirtualProtect(hookAddr, 5, oldProtect[0], oldProtect)
            ffi.copy(hookAddr, original, 5)
        end)
        error(err)
    end

    assert(ffi.C.VirtualProtect(hookAddr, 5, oldProtect[0], oldProtect) ~= 0, 'VirtualProtect restore failed')
    nativeHookOriginalBytes[installAddr] = original
    return { addr = installAddr }
end


function modifyAlpha(color, deltaAlpha)
    -- Извлекаем значения каналов
    local alpha = bit.band(bit.rshift(color, 24), 0xFF)
    local red = bit.band(bit.rshift(color, 16), 0xFF)
    local green = bit.band(bit.rshift(color, 8), 0xFF)
    local blue = bit.band(color, 0xFF)

    -- Прибавляем или убавляем значение альфа-канала
    alpha = math.min(255, math.max(0, alpha + deltaAlpha))

    -- Собираем цвет обратно
    return bit.bor(bit.lshift(alpha, 24), bit.lshift(red, 16), bit.lshift(green, 8), blue)
end


function isKeyCanBePressed()
    if sampIsDialogActive() or sampIsChatInputActive() or isSampfuncsConsoleActive() then
        return false
    end
    return true
end

function delChar(arg_16_0)
	local var_16_0 = raknetNewBitStream()

	raknetBitStreamWriteInt16(var_16_0, arg_16_0)
	raknetEmulRpcReceiveBitStream(163, var_16_0)
	raknetDeleteBitStream(var_16_0)
end


function isKeysPressed(arr)
    if arr ~= nil then
        if #arr == 0 then
            return
        end
        local result = 0
     --   msg(arr)
        for i = 1, #arr do
            if i == #arr then
                if wasKeyPressed(arr[i]) then
                    result = result + 1
                end
            else
                if isKeyDown(arr[i]) then
                    result = result + 1
                end
            end
        end
        if result == #arr then
            return true
        end
    end
end

function wasReleased(arr)
    if arr ~= nil then
        if #arr == 0 then
            return
        end
        local result = 0
     --   msg(arr)
        for i = 1, #arr do
            if i == #arr then
                if wasKeyReleased(arr[i]) then
                    result = result + 1
                end
            else
                if wasKeyReleased(arr[i]) then
                    result = result + 1
                end
            end
        end
        if result == #arr then
            return true
        end
    end
end

function isKeysDown(arr)
    local result = 0
    for i = 1, #arr do
        if i == #arr then
            if isKeyDown(arr[i]) then
                result = result + 1
            end
        else
            if isKeyDown(arr[i]) then
                result = result + 1
            end
        end
    end
    if result == #arr then
        return true
    end
end
function imgui.Question(text)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

_utf8 = load([=[return function(utf8_func, in_encoding, out_encoding); if encoding == nil then; encoding = require("encoding"); encoding.default = "CP1251"; u8 = encoding.UTF8; end; if type(utf8_func) ~= "table" then; return false; end; if AnsiToUtf8 == nil or Utf8ToAnsi == nil then; AnsiToUtf8 = function(text); return u8(text); end; Utf8ToAnsi = function(text); return u8:decode(text); end; end; if _UTF8_FUNCTION_SAVE == nil then; _UTF8_FUNCTION_SAVE = {}; end; local change_var = "_G"; for s = 1, #utf8_func do; change_var = string.format('%s["%s"]', change_var, utf8_func[s]); end; if _UTF8_FUNCTION_SAVE[change_var] == nil then; _UTF8_FUNCTION = function(...); local pack = table.pack(...); readTable = function(t, enc); for k, v in next, t do; if type(v) == 'table' then; readTable(v, enc); else; if enc ~= nil and (enc == "AnsiToUtf8" or enc == "Utf8ToAnsi") then; if type(k) == "string" then; k = _G[enc](k); end; if type(v) == "string" then; t[k] = _G[enc](v); end; end; end; end; return t; end; return table.unpack(readTable({_UTF8_FUNCTION_SAVE[change_var](table.unpack(readTable(pack, in_encoding)))}, out_encoding)); end; local text = string.format("_UTF8_FUNCTION_SAVE['%s'] = %s; %s = _UTF8_FUNCTION;", change_var, change_var, change_var); load(text)(); _UTF8_FUNCTION = nil; end; return true; end]=])
function utf8(...)
    pcall(_utf8(), ...)
end
utf8({ "sampShowDialog" }, "Utf8ToAnsi")
utf8({ "sampSendChat" }, "Utf8ToAnsi")
utf8({ "renderFontDrawText" }, "Utf8ToAnsi")
utf8({ "sampAddChatMessage" }, "Utf8ToAnsi")
utf8({ "sampAddChatMessage" }, "Utf8ToAnsi")
utf8({ "print" }, "Utf8ToAnsi")
utf8({ "renderGetFontDrawTextLength" }, "Utf8ToAnsi")
utf8({ "sampSetCurrentDialogEditboxText" }, "Utf8ToAnsi")
utf8({ "sampHasDialogRespond" }, nil, "AnsiToUtf8")
utf8({ "sampGetDialogCaption" }, nil, "AnsiToUtf8")
utf8({ "sampev", "onServerMessage" }, "AnsiToUtf8", "Utf8ToAnsi")
utf8({ "sampev", "onShowTextDraw" }, "AnsiToUtf8", "Utf8ToAnsi")
utf8({ "sampev", "onShowDialog" }, "AnsiToUtf8", "Utf8ToAnsi")