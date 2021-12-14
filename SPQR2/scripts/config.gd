extends Node

const AUDIO_SECTION_NAME = 'audio'
const MUSIC_VOL_NAME = 'music_volume'
const SFX_VOL_NAME = 'sfx_volume'
const MUSIC_ON_NAME = 'music_on'

var music_volume: float
var sfx_volume: float
var music_on: bool


func set_default_config() -> void:
	music_volume = cn.MUSIC_VOLUME_DEFAULT
	sfx_volume = cn.SFX_VOLUME_DEFAULT
	music_on = cn.MUSIC_PLAYING_DEFAULT

func load_config_file() -> void:
	set_default_config()
	var config = ConfigFile.new()	
	var err = config.load(cn.CONFIG_FILE)
	if err != OK:
		helpers.log('Warn: Could not load config file')
		return
	# load what we can
	music_volume = config.get_value(AUDIO_SECTION_NAME, MUSIC_VOL_NAME, cn.MUSIC_VOLUME_DEFAULT)
	sfx_volume = config.get_value(AUDIO_SECTION_NAME, SFX_VOL_NAME, cn.SFX_VOLUME_DEFAULT)
	music_on = config.get_value(AUDIO_SECTION_NAME, MUSIC_ON_NAME, cn.MUSIC_PLAYING_DEFAULT)
	helpers.log('Config file loaded')

func apply_options() -> void:
	# apply the options that we can
	helpers.set_music_volume(music_volume)
	helpers.set_sfx_volume(sfx_volume)

func save_config_file() -> void:
	# Only do this at the end of the game
	var config = ConfigFile.new()
	# values may have been modified, so clamp them
	var m_vol = clamp(music_volume, cn.AUDIO_MIN_VOLUME, cn.AUDIO_MAX_VOLUME)
	var s_vol = clamp(sfx_volume, cn.AUDIO_MIN_VOLUME, cn.AUDIO_MAX_VOLUME)
	config.set_value(AUDIO_SECTION_NAME, MUSIC_VOL_NAME, m_vol)
	config.set_value(AUDIO_SECTION_NAME, SFX_VOL_NAME, s_vol)
	config.set_value(AUDIO_SECTION_NAME, MUSIC_ON_NAME, music_on)
	# overwrites if already exists
	config.save(cn.CONFIG_FILE)
