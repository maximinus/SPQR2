extends Control

signal map_clicked(pos)

const MAP_SIZE: Vector2 = Vector2(180.0, 120.0)

func _ready() -> void:
	pass

func set_map_cursor(pos: Vector2) -> void:
	# this is the value in UV format, i.e. 0-1 both axis
	var offset = MAP_SIZE * pos
	# TODO: Why do we need the extra offset? Should only be a pixel off
	offset += $VBox/Map.rect_global_position + Vector2(6.0, 6.0)
	$Pin.rect_position = offset

func _on_MapButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = true
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = false

func _on_ArmyButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = true
	$VBox/HBox/CoinButton.pressed = false

func _on_CoinButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = true

func _on_Map_gui_input(event) -> void:
	# left mouse click?
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		# reduce to UV co-ords and signal
		var pos = event.position / MAP_SIZE
		emit_signal('map_clicked', pos)
