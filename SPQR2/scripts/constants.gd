extends Node

const MAP_PIXEL_SIZE: Vector2 = Vector2(6000.0, 4000.0)
const MAP_REAL_SIZE: Vector2 = Vector2(25.0, 16.68)
const ROME_PROVINCE_COORDS: Vector2 = Vector2(1800.0, 1600.0)
const MAP_TO_PIXEL_SCALE: float = 240.0

const UNIT_RADIUS_MAP_COORDS: float = 0.14

const ROME_DEFAULT_COLOR: Color = Color(0.91, 0.0664, 0.0664, 1.0)
const CELT_COLOR: Color = Color('246bce')

const ROAD_IMAGE_BORDER: Vector2 = Vector2(16.0, 16.0)

# sounds
const AUDIO_MIN_VOLUME: float = -60.0
const AUDIO_MAX_VOLUME: float = 0.0
const SFX_BUS_NAME: String = 'SFX'
const MUSIC_BUS_NAME: String = 'Music'

# paths
const CONFIG_FILE: String = 'user://spqr.cfg'

# defaults from config file
const MUSIC_VOLUME_DEFAULT: float = -2.0
const SFX_VOLUME_DEFAULT: float = 0.0
const MUSIC_PLAYING_DEFAULT: bool = true


class RoadMoveDisplay:
	# helper function to store details for displaying movements
	var image: ImageTexture
	var red_image: ImageTexture
	var move_to: int
	var pos: Vector2
	var points: Array
	
	func _init(img, red_img, road, to, pts):
		# arrow images
		image = img
		red_image = red_img
		# road is the id of the ROAD
		move_to = road
		# the position of the image
		pos = to
		# the points of the line
		points = pts

enum RegionDisplay {
	OWNERS,
	MONEY,
	ARMY
}

enum TerrainTypes {
	MOUNTAIN = 0,
	HILLS = 1,
	PLAIN = 2,
	DESERT = 3,
	FOREST = 4
}

enum CropGrowth {
	EXCELLENT = 0,
	GOOD = 1,
	BAD = 2,
	TERRIBLE = 3
}

enum ClimateTypes {
	MARITIME = 0,
	MEDITERRANEAN = 1,
	DESERT = 2,
	HUMID = 3
}

enum NodeIcons {
	FISH = 0
	WINE = 1
	COLOSSEUM = 2
	AQUEDUCT = 3
	PORT = 4
	HISTORY = 5
	MUSIC = 6
	ENGINEERING = 7
	TEMPLE = 8
	MATHS = 9
	WRITING = 10
	GRAIN = 11
	CLOTH = 12
	GOLD = 13
	SILVER = 14
	IRON = 15
}

# collections of strings that are related
const NodeIconText = ['NODE_ICON_FISH', 'NODE_ICON_WINE', 'NODE_ICON_COLOSSEUM',
					  'NODE_ICON_AQUEDUCT', 'NODE_ICON_PORT', 'NODE_ICON_HISTORY',
					  'NODE_ICON_MUSIC', 'NODE_ICON_ENGINEERING', 'NODE_ICON_TEMPLE',
					  'NODE_ICON_MATHS', 'NODE_ICON_WRITING', 'NODE_ICON_GRAINS',
					  'NODE_ICON_CLOTH', 'NODE_ICON_GOLD', 'NODE_ICON_SILVER', 'NODE_ICON_IRON']

const NodePopulationText = ['NODE_POP_VERY_HIGH', 'NODE_POP_HIGH', 'NODE_POP_AVERAGE',
							'NODE_POP_LOW', 'NODE_POP_VERY_LOW', 'NODE_POP_NONE']
							
const NodeRomanisationText = ['NODE_ROMANISATION_VERY_HIGH', 'NODE_ROMANISATION_HIGH',
							  'NODE_ROMANISATION_AVERAGE', 'NODE_ROMANISATION_LOW',
							  'NODE_ROMANISATION_VERY_LOW', 'NODE_ROMANISATION_NONE']

const NodeWealthText = ['NODE_WEALTH_VERY_HIGH', 'NODE_WEALTH_HIGH', 'NODE_WEALTH_AVERAGE',
						'NODE_WEALTH_LOW', 'NODE_WEALTH_VERY_LOW', 'NODE_WEALTH_NEGATIVE']
						
const NodeHappyText = ['NODE_HAPPINESS_VERY_HIGH', 'NODE_HAPPINESS_HIGH', 'NODE_HAPPINESS_AVERAGE',
					   'NODE_HAPPINESS_LOW', 'NODE_HAPPINESS_VERY_LOW']

const NodeChristianText = ['NODE_CHRISTIAN_ZEALOT', 'NODE_CHRISTIAN_VERY_HIGH',
						   'NODE_CHRISTIAN_HIGH', 'NODE_CHRISTIAN_AVERAGE', 'NODE_CHRISTIAN_LOW',
						   'NODE_CHRISTIAN_VERY_LOW', 'NODE_CHRISTIAN_NONE']
