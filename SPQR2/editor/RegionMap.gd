@tool
extends Sprite2D

@export var region_tex: Texture2D: set = set_region_owners
var region_image: Image

class RegHighlightSorter:
	# helper class to sort regions
	var id: int
	var color: Color

	func _init(new_id: int, new_color: Color):
		id = new_id
		color = new_color

	static func sort(a, b) -> bool:
		if a.id < b.id:
			return true
		return false

func _ready():
	pass

func _process(_delta):
	# have an regions been updated?
	for i in $Regions.get_children():
		if i.needs_update == true:
			update_shader_map()
			return

func set_region_owners(new_tex:Texture2D) -> void:
	region_tex = new_tex
	region_image = region_tex.get_data()
	false # region_image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed

func update_shader_map():
	# grab the various images, put in some order and then draw
	print('Updating map')
	var all_regions = []
	for i in $Regions.get_children():
		i.needs_update = false
		var reg_id = get_region_color(i.position)
		all_regions.append(RegHighlightSorter.new(reg_id, i.current_color))
	all_regions.sort_custom(Callable(RegHighlightSorter, 'sort'))
	var img = get_region_for_shader(all_regions)
	material.set_shader_parameter('region_cols', img)

func get_region_color(reg_pos:Vector2):
	var col = region_image.get_pixel(reg_pos.x, reg_pos.y)
	# col is an array, first 3 values are RGB in range 0.0 -> 1.0
	# shader code is: float index = (round(region_i.b * 8.0) + round(region_i.r * 64.0));
	return int(round(col[2] * 8.0) + round(col[0] * 64.0))

func get_region_for_shader(all_regions) -> Image:
	var base_image = Image.new()
	base_image.create(1, len(all_regions), false, Image.FORMAT_RGB8)
	false # base_image.lock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	var ypos: int = 0
	for i in all_regions:
		base_image.set_pixel(0, ypos, i.color)
		ypos += 1		
	false # base_image.unlock() # TODOConverter3To4, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	var img = ImageTexture.new()
	img.create_from_image(base_image)
	return img
