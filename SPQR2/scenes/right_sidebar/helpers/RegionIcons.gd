extends Control

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/RegionIconTooltip.tscn')

const ICON_SIZE = 36
const TOOLTIP_OFFSET = Vector2(0.0, 40.0)

var tooltip = null
var crops: int = 3
var climate: int = 3
var terrain: int = 3

var messages = {'crops':[tr('CROPS_EXCELLENT'),
						 tr('CROPS_GOOD'),
						 tr('CROPS_BAD'),
						 tr('CROPS_TERRIBLE')],
				'climate':[tr('CLIMATE_MARITIME'),
						   tr('CLIMATE_MED'),
						   tr('CLIMATE_DESERT'),
						   tr('CLIMATE_HUMID')],
				'terrain':[tr('TERRAIN_MOUNTAINS'),
						   tr('TERRAIN_HILLS'),
						   tr('TERRAIN_FLAT'),
						   tr('TERRAIN_DESERT'),
						   tr('TERRAIN_FOREST')]}

func _ready():
	tooltip = null
	
func set_icons(cr: int, c: int, t: int) -> void:
	$Icons/HBox2/Crops.texture.region.position.x = cr * ICON_SIZE
	$Icons/HBox2/Climate.texture.region.position.x = c * ICON_SIZE
	$Icons/HBox2/Terrain.texture.region.position.x = t * ICON_SIZE
	crops = cr
	climate = c
	terrain = t

func show_tooltip(pos, tex, title, message):
	if tooltip != null:
		tooltip.hide()
		tooltip.queue_free()
	tooltip = tooltip_resource.instance()
	tooltip.hide()
	tooltip.setup(tex, title, message)
	# place it
	tooltip.rect_position = pos + TOOLTIP_OFFSET
	# populate the data
	add_child(tooltip)
	tooltip.fade_in()

func hide_tooltip():
	if tooltip == null:
		return
	# hide the tooltip
	tooltip.fade_out()
	tooltip = null

func _on_Crops_mouse_entered():
	# set up the data
	var tex = $Icons/HBox2/Crops.texture
	var title = 'Food Production'
	var message = messages['crops'][crops]
	show_tooltip($Icons/HBox2/Crops.rect_global_position, tex, title, message)

func _on_Crops_mouse_exited():
	hide_tooltip()

func _on_Climate_mouse_entered():
	var tex = $Icons/HBox2/Climate.texture
	var title = 'Regional Climate'
	var message = messages['climate'][climate]
	show_tooltip($Icons/HBox2/Climate.rect_global_position, tex, title, message)

func _on_Climate_mouse_exited():
	hide_tooltip()

func _on_Terrain_mouse_entered():
	var tex = $Icons/HBox2/Terrain.texture
	var title = 'Regional Topography'
	var message = messages['terrain'][terrain]
	show_tooltip($Icons/HBox2/Terrain.rect_global_position, tex, title, message)

func _on_Terrain_mouse_exited():
	hide_tooltip()
