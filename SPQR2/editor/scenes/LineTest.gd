extends Node2D

const DOTTED_LENGTH: float = 6.0

var complete: bool = false

func _ready() -> void:
	pass

func _process(_delta) -> void:
	if complete == true:
		return
	build_dotted_line()
	build_curved_dotted()
	complete = true

func build_curved_dotted():
	# calculate the length of the line
	var all_points = $CurvedLine.points
	var length = 0.0
	for i in range(len(all_points) - 1):
		length += all_points[i].distance_to(all_points[i + 1])
	print(length)

func build_dotted_line() -> void:
	var start = $SampleLine.points[0]
	var end = $SampleLine.points[-1]
	
	# calculate length of line
	var length: float = start.distance_to(end)
	var angle: float = atan2(end.y - start.y, end.x - start.x)
	var offset = Vector2(DOTTED_LENGTH * cos(angle), DOTTED_LENGTH * sin(angle))
	var start_point = start - Vector2(0.0, -1.0)
	
	var dots: float = length / DOTTED_LENGTH
	var frac_dots: float = dots - floor(dots)
	var start_length: float = frac_dots / 2.0
		
	# first dot is just a small fraction, as defined above
	# we start with a blank, so only adjust the line
	start_point += (offset * start_length)
	var end_point = start_point + offset
	length -= start_length
		
	var draw = true
	while(true):
		# now create a new line
		if draw == true:
			var new_line: Line2D = Line2D.new()
			new_line.add_point(start_point)
			
			if length < DOTTED_LENGTH:
				end_point = start_point + (offset * start_length)

			new_line.add_point(end_point)
			new_line.width = 2.0
			new_line.antialiased = true
			$DottedLine.add_child(new_line)
			draw = false
		else:
			draw = true
		start_point += offset
		end_point += offset
		length -= DOTTED_LENGTH
		if length < 0:
			return
