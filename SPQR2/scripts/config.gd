extends Node

const AUDIO_SECTION_NAME = 'audio'
const MUSIC_VOL_NAME = 'music_volume'
const SFX_VOL_NAME = 'sfx_volume'
const MUSIC_ON_NAME = 'music_on'

var music_volume: float
var sfx_volume: float
var music_on: bool


func set_default_config():
	music_volume = 100.0
	sfx_volume = 100.0
	music_on = true

func load_config_file():
	set_default_config()
	var config = ConfigFile.new()
	var err = config.load(cn.CONFIG_FILE)
	# File loaded?
	if err != OK:
		helpers.log('Warn: Could not load config file')
		return
	if not config.has_section_key(AUDIO_SECTION_NAME):
		return
	# load what we can
	music_volume = config.get_value(AUDIO_SECTION_NAME, MUSIC_VOL_NAME)
	sfx_volume = config.get_value(AUDIO_SECTION_NAME, SFX_VOL_NAME)
	music_on = config.get_value(AUDIO_SECTION_NAME, MUSIC_ON_NAME)

func save_config_file(config_data):
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	config.set_value(AUDIO_SECTION_NAME, MUSIC_VOL_NAME, config_data.music_volume)
	config.set_value(AUDIO_SECTION_NAME, SFX_VOL_NAME, config_data.sfx_volume)
	config.set_value(AUDIO_SECTION_NAME, MUSIC_ON_NAME, config_data.music_on)
	# overwrites if already exists
	config.save(cn.CONFIG_FILE)
