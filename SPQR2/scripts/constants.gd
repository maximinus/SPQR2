extends Node

const MAP_PIXEL_SIZE = Vector2(6000.0, 4000.0)
const MAP_REAL_SIZE = Vector2(25.0, 16.68)
const ROME_PROVINCE_COORDS = Vector2(1800.0, 1600.0)

const ROME_DEFAULT_COLOR = Color(0.91, 0.0664, 0.0664, 1.0)
const CELT_COLOR = Color('246bce')

enum RegionDisplay {
	OWNERS,
	MONEY,
	ARMY
}
