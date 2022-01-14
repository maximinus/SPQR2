extends Control

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/RegionNodeSpecificTooltip.tscn')
var tooltip = null

const TOOLTIP_OFFSET = Vector2(0.0, 32.0)
const ICON_SIZE: int = 22
const MAX_ICONS = 4

var current_icons: Array = []
var icon_messages = ["This region is known for it's excellent wine production.",
					 'Fishing is very productive in this region.']

func _ready():
	tooltip = null

func get_icon_details() -> Array:
	var new_array: Array = []
	# the array holds the offset of the texture and the highlight text
	for i in $Mrg/HBox/Icons.get_children():
		if i.visible:
			var offset = i.texture.region.position.x
			new_array.append([offset, cn.NodeIconText[offset / ICON_SIZE]])
	return new_array

func set_data(node_data) -> void:
	$Mrg/HBox/Mrg/Title.text = node_data.name
	set_icons(node_data.icons)

func set_icons(all_icons) -> void:
	var icons = [$Mrg/HBox/Icons/Icon4, $Mrg/HBox/Icons/Icon3,
				 $Mrg/HBox/Icons/Icon2, $Mrg/HBox/Icons/Icon1]
	for i in icons:
		i.hide()
	var index = 0
	for i in all_icons:
		icons[index].texture.region.position.x = i * ICON_SIZE
		icons[index].show()
		index += 1
		if index > 3:
			helpers.log('* Error: Exceeded max icons for region display')
			return

func _on_NodeHeader_mouse_entered() -> void:
	if tooltip != null:
		tooltip.hide()
		tooltip.queue_free()
	tooltip = tooltip_resource.instance()
	tooltip.hide()
	var title_string = $Mrg/HBox/Mrg/Title.text + ' Details'
	tooltip.setup(title_string, get_icon_details())
	# place it
	tooltip.rect_position = rect_global_position + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func _on_NodeHeader_mouse_exited() -> void:
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null
