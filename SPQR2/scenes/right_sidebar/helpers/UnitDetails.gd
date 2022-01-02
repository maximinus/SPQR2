extends Control

const TOOLTIP_OFFSET: Vector2 = Vector2(8.0, 30.0)

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/NodeUnitsTooltip.tscn')
var tooltip = null
var total_units: int

func _ready():
	tooltip = null

func set_total_units(new_total: int) -> void:
	total_units = new_total
	var index: int = 0
	for i in $HBox.get_children():
		if index < total_units:
			i.show()
		else:
			i.hide()
		index += 1

func _on_UnitDetails_mouse_entered():
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

func _on_UnitDetails_mouse_exited():
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
