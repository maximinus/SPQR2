extends Control

export(Texture) var statue
export(Texture) var alternate_statue

const CHANCE_OF_ALTERNATE_STATUE = 0.25

var can_escape_out = false

func _ready():
	$Rollover.stop()
	$MouseClick.stop()

func display():
	can_escape_out = false
	choose_statue()
	show()

func exit_menu():
	# hide myself and stop pausing
	hide()
	get_tree().paused = false

func _process(delta):
	# done this way to catch a seperate pressed event other
	# than the first one that opened this window
	if Input.is_action_just_released('menu'):
		# escape button pressed, so we can exit next time
		can_escape_out = true
		return
	if can_escape_out == true:
		if Input.is_action_just_pressed('menu'):
			exit_menu()

func choose_statue():
	if randf() > CHANCE_OF_ALTERNATE_STATUE:
		$Panel/VBox/Info/Statue.texture = statue
	else:
		$Panel/VBox/Info/Statue.texture = alternate_statue

func _on_OptionsButton_pressed():
	helpers.log('Option button pressed')

func _on_QuitButton_pressed():
	$MouseClick.play()	
	exit_menu()

func _on_OkButton_mouse_entered():
	if $Rollover.playing == true:
		$Rollover.stop()
	$Rollover.play()
