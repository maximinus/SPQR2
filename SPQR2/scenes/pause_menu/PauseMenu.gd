extends Control

export(Texture) var statue
export(Texture) var alternate_statue

const CHANCE_OF_ALTERNATE_STATUE = 0.25

func _ready():
	pass

func choose_statue():
	if randf() > CHANCE_OF_ALTERNATE_STATUE:
		$Panel/VBox/Info/Statue.texture = statue
	else:
		$Panel/VBox/Info/Statue.texture = alternate_statue

func _on_OptionsButton_pressed():
	helpers.log('Option button pressed')

func _on_QuitButton_pressed():
	# hide myself and stop pausing
	hide()
	get_tree().paused = false
