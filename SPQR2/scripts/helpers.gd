extends Node

enum LogType {
	INFO,
	WARN,
	ERROR
}

func log(text: String):
	# probably want a better logger eventually
	print(text)

func get_index_from_region_color(col) -> int:
	# col is an array, first 3 values are RGB in range 0.0 -> 1.0
	# shader code is: float index = (round(region_i.b * 8.0) + round(region_i.r * 64.0));
	return int(round(col[2] * 8.0) + round(col[0] * 64.0))

func pixel_on_map(pos: Vector2) -> bool:
	if pos.x < cn.MAP_PIXEL_SIZE.x:
		return false
	if pos.x > cn.MAP_PIXEL_SIZE.x:
		return false
	if pos.y < cn.MAP_PIXEL_SIZE.y:
		return false
	if pos.y > cn.MAP_PIXEL_SIZE.y:
		return false
	return true

func pixel_to_map(pos: Vector2):
	# given the pixel co-ords, return the map co-ords
	# on this and the following function, we do not check for range
	return Vector2(((pos.x / cn.MAP_PIXEL_SIZE.x) * 25.0) - 12.5,
				   ((pos.y / cn.MAP_PIXEL_SIZE.y) * 16.68) - 8.34)
	
func map_to_pixel(pos: Vector2) -> Vector2:
	# given the map co-ords, return the pixel co-ords
	# plane of (-12.5, -8.34) is (0,0) in pixels
	# Since map is (12.5, 8.34) * 2 = (25.0, 16.68) in size,
	# divide the pixel size by those values
	return Vector2(round((pos.x + 12.5) * (cn.MAP_PIXEL_SIZE.x / 25.0)),
				   round((pos.y + 8.34) * (cn.MAP_PIXEL_SIZE.y / 16.68)))
