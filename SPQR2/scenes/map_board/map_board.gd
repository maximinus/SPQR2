extends Node3D

func _ready():
	pass # Replace with function body.

func set_region_color(color):
	# color is a vector3
	%MapRender.material.set_shader_parameter('region_color', color)

func set_mouse(mouse_pos):
	%MapRender.material.set_shader_parameter('mouse_pos', mouse_pos)

func set_region_owners(owners: ImageTexture):
	%MapRender.material.set_shader_parameter('map_owners', owners)

func set_road_texture(road_image: ImageTexture):
	%MapRender.material.set_shader_parameter('road_map', road_image)
