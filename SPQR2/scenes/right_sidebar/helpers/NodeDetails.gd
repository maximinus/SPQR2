extends Control

# this is usually the size of the this scene +2
const TOOLTIP_OFFSET: Vector2 = Vector2(12.0, 26.0)

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/NodeDetailsTooltip.tscn')
var tooltip = null

func _ready():
	tooltip = null

func _on_NodeDetails_mouse_entered():
	if tooltip != null:
		tooltip.hide()
		tooltip.queue_free()
	tooltip = tooltip_resource.instance()
	tooltip.hide()
	tooltip.setup()
	# place it
	tooltip.rect_position = rect_position + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func _on_NodeDetails_mouse_exited():
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
