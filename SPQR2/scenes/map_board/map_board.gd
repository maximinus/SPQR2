extends Spatial

func _ready():
	pass # Replace with function body.

func set_region_color(color):
	# color is a vector3
	var mat = $GameBoard.get_surface_material(1)
	mat.set_shader_param('region_color', color)

func set_mouse(mouse_pos):
	var mat = $GameBoard.get_surface_material(1)
	mat.set_shader_param('mouse_pos', mouse_pos)

func set_region_owners(owners: ImageTexture):
	var mat = $GameBoard.get_surface_material(1)
	mat.set_shader_param('map_owners', owners)
