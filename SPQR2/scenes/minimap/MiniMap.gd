extends VBoxContainer

signal map_clicked(pos)
signal view_clicked(tab)

const MAP_SIZE: Vector2 = Vector2(180.0, 120.0)

var start_size: Vector2

func _ready() -> void:
	pass

func set_map_cursor(pos: Vector2) -> void:
	# this is the value in UV format, i.e. 0-1 both axis
	var delta = MAP_SIZE * pos
	# TODO: Why do we need the extra offset? Should only be a pixel off
	# Maybe need to account for the border
	%Pin.position = delta - Vector2(3.0, 3.0)

func _on_MapButton_pressed() -> void:
	%MapButton.button_pressed = true
	%ArmyButton.button_pressed = false
	%CoinButton.button_pressed = false#
	play_mouse_click()
	view_clicked.emit(cn.RegionDisplay.OWNERS)

func _on_ArmyButton_pressed() -> void:
	%MapButton.button_pressed = false
	%ArmyButton.button_pressed = true
	%CoinButton.button_pressed = false
	play_mouse_click()
	view_clicked.emit(cn.RegionDisplay.ARMY)

func _on_CoinButton_pressed() -> void:
	%MapButton.button_pressed = false
	%ArmyButton.button_pressed = false
	%CoinButton.button_pressed = true
	play_mouse_click()
	view_clicked.emit(cn.RegionDisplay.MONEY)

func play_mouse_click():
	if %MouseClick.playing == true:
		%MouseClick.stop()
	%MouseClick.play()

func _on_map_gui_input(event: InputEvent) -> void:
	# left mouse click?
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play_mouse_click()
			# reduce to UV co-ords and signal
			var pos = event.position / MAP_SIZE
			map_clicked.emit(pos)
