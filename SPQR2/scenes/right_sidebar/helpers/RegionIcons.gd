extends Control

var tooltip_resource = preload('res://scenes/right_sidebar/tooltips/RegionIconTooltip.tscn')

const ICON_SIZE = 36
const TOOLTIP_OFFSET = Vector2(0.0, 40.0)

var tooltip = null
var crops: int = 3
var climate: int = 3
var terrain: int = 3

var messages = {'crops':['This region has high production and produces an excess of food.',
						 'Region produces surplus food.',
						 "This region just about produces enough for it's population.",
						 'This region has poor food production. It cannot keep a large population.'],
				'climate':['The climate in this region is generally cool and wet, with cold winters.',
						   'This regions climate is warm with cooler winters. It can be wet in summer.',
						   'This region is very hot, both in winter and summer.',
						   'The climate here is quite extreme, with hot summers and very cold winters.'],
				'terrain':['This region is very mountainous and hilly, and hard to traverse.',
						   'This region is very hilly, with many valleys',
						   'The terrain in this region is generally very flat.',
						   'This region mainly consists of hot, dry desert.',
						   'This region is mainly forests and woods']}

func _ready():
	tooltip = null
	
func setIcons(cr: int, c: int, t: int) -> void:
	$Icons/HBox2/Crops.texture.region.x = cr * ICON_SIZE
	$Icons/HBox2/Climate.texture.region.x = c * ICON_SIZE
	$Icons/HBox2/Terrain.texture.region.x = t * ICON_SIZE
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
