extends Button

func _ready():
	pass

func _on_EventButton_mouse_entered():
	if $Rollover.playing == true:
		$Rollover.stop()
	$Rollover.play()
