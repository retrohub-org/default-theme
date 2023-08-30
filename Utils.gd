extends Node

static func is_low_res_system(data: RetroHubSystemData):
	match data.name:
		"amiga", "amiga600", "amiga1200", "amstradcpc", "apple2", \
		"atari800", "atarist", "bbcmicro", "c64", "coco", "dos", \
		"dragon32", "macintosh", "moto", "msx", "msx2", "msxturbor", \
		"oric", "palm", "pc88", "pc98", "samcoupe", "spectravideo", \
		"tanodragon", "ti99", "to8", "trs-80", "vic20", "x1", "x68000", \
		"zmachine", "xz81", "zxspectrum", "cavestory", "doom", "openbor", \
		"pico8", "scummvm", "tic80", "astrocade", "atari2600", "atari5200", \
		"atari7800", "atarilynx", "atarixe", "channelf", "colecivision", \
		"famicom", "fds", "gameandwatch", "gamegear", "gb", "gbc", "gba", \
		"genesis", "megadrive", "sega32x", "gx4000", "intellivision", \
		"mastersystem", "multivision", "neogeocd", "nes", "ngp", "ngpc", \
		"videopac", "tg16", "tg-cd", "pcengine", "pcenginecd", "pokemini", "psx", \
		"saturn", "snes", "sfc", "sattelaview", "sufami", "sg-1000", "supergrafx", \
		"uzebox", "vectrex", "virtualboy", "wonderswan", "wonderswancolor", \
		"arcade", "daphne", "neogeo":
			return true
		_:
			return false
		
