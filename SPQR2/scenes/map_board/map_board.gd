extends Spatial

func _ready():
	pass # Replace with function body.

func set_region_color(color):
	var mat = $GameBoard.get_surface_material(1)
	print(mat)
