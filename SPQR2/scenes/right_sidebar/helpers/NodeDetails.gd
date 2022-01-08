extends Control

# this is usually the size of the this scene +2
const TOOLTIP_OFFSET: Vector2 = Vector2(4.0, 26.0)

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/NodeDetailsTooltip.tscn')
var tooltip = null

func _ready():
	tooltip = null

func set_data(node_data) -> void:
	$Mrg/HBox/Population.set_icon_text(str(node_data.population))
	$Mrg/HBox/Roman.set_icon_text(str(node_data.romanisation))
	$Mrg/HBox/Money.set_icon_text(str(node_data.wealth))
	$Mrg/HBox/Happy.set_icon_text(str(node_data.happiness))
	$Mrg/HBox/Christian.set_icon_text(str(node_data.christianty))

func _on_NodeDetails_mouse_entered() -> void:
	if tooltip != null:
		tooltip.hide()
		tooltip.queue_free()
	tooltip = tooltip_resource.instance()
	tooltip.hide()
	tooltip.setup()
	# place it
	tooltip.rect_position = rect_global_position + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func _on_NodeDetails_mouse_exited() -> void:
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
