extends Node2D

const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)

var region_map: Image

func _ready():
	var image = load('res://gfx/map/map_regions_uncompressed.png')
	region_map = image.get_data()
	region_map.lock()

func get_region_color(pos: Vector2):
	if pos.x >= 0.0 and pos.x < MAP_PIXEL_SIZE.x:
		if pos.y >= 0.0 and pos.y < MAP_PIXEL_SIZE.y:
			# yes, we need to set a color
			return region_map.get_pixel(pos.x, pos.y)
	# error
	helpers.log('Error: Got position outside of map: ' + str(pos))
	get_tree().quit()
