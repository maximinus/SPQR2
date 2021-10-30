extends Button

func _ready():
	$Rollover.stop()
	$MouseClick.stop()

func _on_EventButton_mouse_entered():
	if $Rollover.playing == true:
		$Rollover.stop()
	$Rollover.play()

func _on_EventButton_pressed():
	$MouseClick.play()
