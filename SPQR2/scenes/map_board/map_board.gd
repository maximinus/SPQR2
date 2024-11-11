extends Node3D

func _ready():
	pass # Replace with function body.

func set_region(region):
	%MapRender.material.set_shader_parameter('selected_region', region)

func set_region_owners(owners: ImageTexture):
	%MapRender.material.set_shader_parameter('map_owners', owners)

func set_road_texture(road_image: ImageTexture):
	%MapRender.material.set_shader_parameter('road_map', road_image)
