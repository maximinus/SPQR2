extends Spatial

const DISPLAY_HEIGHT = 0.01

func _ready():
	pass

func setup(image_data: Array, pos: Vector2):
	# add each image as a new mesh with a single texture
	# the array is an aray of cn.RoadMoveDisplay instances
	for i in image_data:
		# work out world size after scaling
		var mesh_size = Vector2(i.image.get_width() / cn.MAP_TO_PIXEL_SCALE,
								i.image.get_height() / cn.MAP_TO_PIXEL_SCALE)
		# create the new mesh
		var quad: PlaneMesh = PlaneMesh.new()
		quad.set_size(mesh_size)
		var mesh: CSGMesh = CSGMesh.new()
		mesh.set_mesh(quad)
		# add texture, make see-through
		var m_material = SpatialMaterial.new()
		m_material.set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
		m_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, i.image)
		mesh.set_material(m_material)
		# position is in pixels, translate and offset with node position
		var map_p = helpers.pixel_to_map(i.pos) - pos
		# we also need to offset the image by half it's size, otherwise it is drawn centered
		map_p += mesh_size / 2.0
		mesh.translation.y = DISPLAY_HEIGHT
		mesh.translation = Vector3(map_p.x, DISPLAY_HEIGHT, map_p.y)
		$Moves.add_child(mesh)

func _process(delta):
	# here we need check for the closest line the mouse is near
	pass
