extends Node3D

func _ready():
	pass # Replace with function body.

func set_region_color(color):
	# color is a vector3
	var mat = %GameBoard.get_surface_override_material(1)
	#mat.set_shader_parameter('region_color', color)

func set_mouse(mouse_pos):
	var mat = %GameBoard.get_surface_override_material(1)
	#mat.set_shader_parameter('mouse_pos', mouse_pos)

func set_region_owners(owners: ImageTexture):
	var mat = %GameBoard.get_surface_override_material(1)
	#mat.set_shader_parameter('map_owners', owners)

func set_road_texture(road_image: ImageTexture):
	var mat = %GameBoard.get_surface_override_material(1)
	#mat.set_shader_parameter('road_map', road_image)
