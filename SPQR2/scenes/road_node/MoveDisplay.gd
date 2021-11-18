extends Spatial

const DISPLAY_HEIGHT = 0.01

var path_lookups: Array = []

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
		m_material.set_emission(Color(1.0, 1.0, 1.0, 1.0))
		m_material.set_feature(SpatialMaterial.FEATURE_EMISSION, false)
		mesh.set_material(m_material)
		# position is in pixels, translate and offset with node position
		var map_p = helpers.pixel_to_map(i.pos) - pos
		# we also need to offset the image by half it's size, otherwise it is drawn centered
		map_p += mesh_size / 2.0
		mesh.translation.y = DISPLAY_HEIGHT
		mesh.translation = Vector3(map_p.x, DISPLAY_HEIGHT, map_p.y)
		
		# convert the points to a Vector2 array
		var vec_points: Array = []
		for j in i.points:
			vec_points.append(Vector2(j[0], j[1]))
		
		path_lookups.append([vec_points, m_material])
		$Moves.add_child(mesh)

func show_line_highlight(mat: SpatialMaterial):
	mat.set_feature(SpatialMaterial.FEATURE_EMISSION, true)

func hide_line_highlight(mat: SpatialMaterial):
	mat.set_feature(SpatialMaterial.FEATURE_EMISSION, false)

func _process(delta):
	check_closest_line()

func check_closest_line():
	var current_coords = data.get_mouse_coords()
	var closest: float = 10000.0
	var path_chosen = null
	for i in path_lookups:
		for point in i[0]:
			var distance = current_coords.distance_to(point)
			if distance < closest:
				closest = distance
				path_chosen = i[1]
	# highlight the new line and not the others
	for i in path_lookups:
		if i[1] == path_chosen:
			show_line_highlight(i[1])
		else:
			hide_line_highlight(i[1])
