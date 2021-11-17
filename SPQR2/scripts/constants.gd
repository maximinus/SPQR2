extends Node

const MAP_PIXEL_SIZE: Vector2 = Vector2(6000.0, 4000.0)
const MAP_REAL_SIZE: Vector2 = Vector2(25.0, 16.68)
const ROME_PROVINCE_COORDS: Vector2 = Vector2(1800.0, 1600.0)
const MAP_TO_PIXEL_SCALE: float = 240.0

const ROME_DEFAULT_COLOR: Color = Color(0.91, 0.0664, 0.0664, 1.0)
const CELT_COLOR: Color = Color('246bce')

const ROAD_IMAGE_BORDER: Vector2 = Vector2(12.0, 12.0)

enum RegionDisplay {
	OWNERS,
	MONEY,
	ARMY
}
