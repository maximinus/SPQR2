extends Control

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
	$VBox/Map/Pin.rect_position = delta - Vector2(3.0, 3.0)

func _on_MapButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = true
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = false
	emit_signal('view_clicked', cn.RegionDisplay.OWNERS)

func _on_ArmyButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = true
	$VBox/HBox/CoinButton.pressed = false
	emit_signal('view_clicked', cn.RegionDisplay.ARMY)

func _on_CoinButton_pressed() -> void:
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = true
	emit_signal('view_clicked', cn.RegionDisplay.MONEY)

func _on_Map_gui_input(event) -> void:
	# left mouse click?
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		# reduce to UV co-ords and signal
		var pos = event.position / MAP_SIZE
		emit_signal('map_clicked', pos)
