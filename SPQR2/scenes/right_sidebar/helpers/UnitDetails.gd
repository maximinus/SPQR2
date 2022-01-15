extends Control

const TOOLTIP_OFFSET: Vector2 = Vector2(4.0, 26.0)

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/NodeUnitsTooltip.tscn')
var tooltip = null
var total_units: int
var show_tooltip: bool

func _ready():
	tooltip = null
	# we don't show the tooltip if there are no units
	show_tooltip = true

func set_data(node_data):
	set_total_units(len(node_data.units))
	var update_nodes = [$MarginContainer/HBox/Unit1,
						$MarginContainer/HBox/Unit2,
						$MarginContainer/HBox/Unit3,
						$MarginContainer/HBox/Unit4]
	for i in range(len(node_data.units)):
		var total = node_data.units[0].foot + node_data.units[0].mounted
		total = total / 1000.0
		var fraction = int((total - floor(total)) * 10)
		var units = int(floor(total))
		var str_value = ''
		if fraction == 0:
			str_value = str(units)
		else:
			str_value = str(units) + '.' + str(fraction)
		update_nodes[i].set_icon_text(str_value)

func set_total_units(new_total: int) -> void:
	if new_total == 0:
		show_tooltip = false
	total_units = new_total
	var index: int = 0
	for i in $MarginContainer/HBox.get_children():
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
	tooltip.rect_position = rect_global_position + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func _on_UnitDetails_mouse_exited():
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
