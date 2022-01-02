extends Control

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/RegionNodeSpecificTooltip.tscn')
var tooltip = null

const TOOLTIP_OFFSET = Vector2(0.0, 32.0)

var icon_messages = ["This region is known for it's excellent wine production.",
					 'Fishing is very productive in this region.']

func _ready():
	tooltip = null

func get_icon_details() -> Array:
	var new_array: Array = []
	new_array.append([$Mrg/HBox/Icons/Icon1.texture, icon_messages[0]])
	new_array.append([$Mrg/HBox/Icons/Icon2.texture, icon_messages[1]])
	return new_array

func _on_NodeHeader_mouse_entered():
	if tooltip != null:
		tooltip.hide()
		tooltip.queue_free()
	tooltip = tooltip_resource.instance()
	tooltip.hide()
	var title_string = $Mrg/HBox/Mrg/Title.text + ' Details'
	tooltip.setup(title_string, get_icon_details())
	# place it
	tooltip.rect_position = rect_global_position + TOOLTIP_OFFSET
	#rect_position + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func _on_NodeHeader_mouse_exited():
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
