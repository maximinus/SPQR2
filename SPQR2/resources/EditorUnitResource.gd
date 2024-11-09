extends Resource

class_name SPQR_EditorUnit

@export var foot: int
@export var mounted: int
@export var quality: int
@export var morale: int

func _init(p_foot=0, p_mounted=0, p_quality=0, p_morale=0):
	foot = p_foot
	mounted = p_mounted
	quality = p_quality
	morale = p_morale
