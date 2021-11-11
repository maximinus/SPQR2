extends Spatial

var id: int = -1

func _ready():
	pass

func update_display() -> void:
	# get the city data and act on it
	pass

func set_id(new_id: int) -> void:
	id = new_id
	update_display()
