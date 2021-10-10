extends Node

enum LogType {
	INFO,
	WARN,
	ERROR
}

func log(text: String):
	# probably want a better logger eventually
	print(text)

func get_index_from_region_color(col) -> int:
	# col is an array, first 3 values are RGB in range 0.0 -> 1.0
	# shader code is: float index = (round(region_i.b * 8.0) + round(region_i.r * 64.0));
	return int(round(col[2] * 8.0) + round(col[0] * 64.0))
