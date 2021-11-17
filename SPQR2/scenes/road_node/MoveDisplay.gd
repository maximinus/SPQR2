extends Spatial

func _ready():
	pass

func setup(image_data: Array):
	# add each image as a new mesh with a single texture
	# the array is of form [Image, id_of_destination_node]
	for i in image_data:
		var tex = i[0]
		var destination = i[1]
		# work out size after scaling
		var mesh_size = Vector2(tex.get_width() / cn.MAP_TO_PIXEL_SCALE,
								tex.get_height() / cn.MAP_TO_PIXEL_SCALE)
		# create the new mesh
		var quad: PlaneMesh = PlaneMesh.new()
		quad.set_size(mesh_size)
		var mesh: CSGMesh = CSGMesh.new()
		mesh.set_mesh(quad)
		# add texture, make see-through
		var m_material = SpatialMaterial.new()
		m_material.set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
		m_material.set_texture(SpatialMaterial.TEXTURE_ALBEDO, tex)
		mesh.set_material(m_material)
		mesh.translation.y = 0.01
		$Moves.add_child(mesh)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
