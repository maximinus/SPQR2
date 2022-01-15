extends Resource

class_name SPQR_EditorUnit

export(bool) var exists
export(int) var foot
export(int) var mounted
export(int) var quality
export(int) var morale

func _init(p_foot=0, p_mounted=0, p_quality=0, p_morale=0):
	foot = p_foot
	mounted = p_mounted
	quality = p_quality
	morale = p_morale
