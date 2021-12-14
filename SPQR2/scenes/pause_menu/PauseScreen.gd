extends CenterContainer

# TODO:
# scraping sound when the sliders move
# click sound on button and checkbox
# highlight sound on all objects
# closes and clears up on OK click
# stores values in game data
# create some music in the world and play under a different bus from the sfx
# sound changes as selection made, by changing the volume of the bus
# show and hide come with fast fade in / out, also animates up / down very slightly

var player: AudioStreamPlayer
var music_position: float
var sfx_position: float

func _ready():
	music_position = 0.0
	sfx_position = 0.0

func display(new_player: AudioStreamPlayer):
	# passed in is the current music player
	# set data from config
	$Tex/Mrg/VBox/MusicVolume/MusicSlider.value = db2linear(config.music_volume) * 100.0
	$Tex/Mrg/VBox/SfxVolume/SfxSlider.value = db2linear(config.sfx_volume) * 100.0
	$Tex/Mrg/VBox/Music/CheckBox.pressed = config.music_on
	show()
	player = new_player

func _on_CheckBox_toggled(button_pressed):
	if $Click.playing == true:
		$Click.stop()
	$Click.play()
	config.music_on = button_pressed
	if button_pressed == true:
		start_music()
	else:
		stop_music()

func _on_MusicSlider_value_changed(value):
	var volume = convert_to_db(value)
	config.music_volume = volume
	helpers.set_music_volume(volume)

func _on_Button_pressed():
	if $Click.playing == true:
		$Click.stop()
	$Click.play()
	$TestSfx.stop()
	hide()
	get_tree().paused = false

func _on_SfxSlider_value_changed(value):
	var volume = convert_to_db(value)
	config.sfx_volume = volume
	helpers.set_sfx_volume(volume)

func _on_SfxSlider_mouse_entered():
		$TestSfx.play(sfx_position)

func _on_SfxSlider_mouse_exited():
	sfx_position = $TestSfx.get_playback_position()
	$TestSfx.stop()

func _on_Button_mouse_entered():
	if $Rollover.playing == true:
		$Rollover.stop()
	$Rollover.play()

func convert_to_db(value: float) -> float:
	# we have a value 0 - 100, convert 0 -> 1
	return linear2db(value / 100.0)

func stop_music():
	if player.playing == false:
		return
	music_position = player.get_playback_position()
	player.stop()
	# disable the slider
	$Tex/Mrg/VBox/MusicVolume/MusicSlider.editable = false

func start_music():
	if player.playing == true:
		return
	player.play(music_position)
	$Tex/Mrg/VBox/MusicVolume/MusicSlider.editable = true
