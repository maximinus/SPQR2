extends Node2D

const DOTTED_LENGTH: float = 6.0
const BORDER_COLOR = Color(0.7, 0.6, 0.5, 1.0)
const ROAD_COLOR = Color(0.8, 0.8, 0.8, 1.0)

var complete: bool = false

func _ready() -> void:
	pass

func _process(_delta) -> void:
	if complete == true:
		return
	#build_dotted_line()
	#build_curved_dotted()
	build_road_line()
	complete = true

func build_road_line():
	# much much easier
	var border_line: Line2D = Line2D.new()
	var center_line: Line2D = Line2D.new()
	for i in $RoadLine.points:
		border_line.add_point(i)
		center_line.add_point(i)
	border_line.width = 3.0
	center_line.width = 1.0
	border_line.antialiased = true
	center_line.antialiased = true
	border_line.default_color = BORDER_COLOR
	center_line.default_color = ROAD_COLOR
	$RoadTest.add_child(border_line)
	$RoadTest.add_child(center_line)

func build_curved_dotted():
	# calculate the length of the line
	var all_points = $CurvedLine.points
	var full_length = 0.0
	for i in range(len(all_points) - 1):
		full_length += all_points[i].distance_to(all_points[i + 1])
	
	# now we do essentially the same thing. We loop over all the lines
	var index: int = 0
	var start: Vector2 = all_points[index]
	var end: Vector2 = all_points[index + 1]

	var short_length = all_points[index].distance_to(all_points[index + 1])

	var angle: float = atan2(end.y - start.y, end.x - start.x)
	var offset: Vector2 = Vector2(DOTTED_LENGTH * cos(angle), DOTTED_LENGTH * sin(angle))
	var start_point: Vector2 = start - Vector2(0.0, -1.0)
	
	var dots: float = full_length / DOTTED_LENGTH
	var frac_dots: float = dots - floor(dots)
	var start_length: float = frac_dots / 2.0
	
	start_point += offset * start_length
	var end_point = start_point + offset
	full_length -= start_length
	short_length -= start_length
	
	var draw = true
	while(true):
		# keep calculating until length is exceeded, just as before
		if draw == true:
			var new_line: Line2D = Line2D.new()
			new_line.add_point(start_point)
			
			if short_length < DOTTED_LENGTH:
				end_point = start_point + (offset * (short_length / DOTTED_LENGTH))
			
			new_line.add_point(end_point)
			new_line.width = 2.0
			new_line.antialiased = true
			$CurveTest.add_child(new_line)
			draw = false
		else:
			draw = true
		start_point += offset
		end_point += offset
		short_length -= DOTTED_LENGTH
		
		if short_length < 0:
			# we have moved onto the next point
			# invert the negative value we have
			short_length *= -1
			# move onto next points
			index += 1
			# have we moved too far?
			if index >= (len(all_points) - 1):
				return
			# calculate the new offset
			start = all_points[index]
			end = all_points[index + 1]
			angle = atan2(end.y - start.y, end.x - start.x)
			offset = Vector2(DOTTED_LENGTH * cos(angle), DOTTED_LENGTH * sin(angle))				
			start_point = start
			# just need a small line to draw
			end_point = start + (offset * (short_length / DOTTED_LENGTH))
			# calculate new short length
			short_length = all_points[index].distance_to(all_points[index + 1]) - short_length
			# do we need to draw this? (logic has swapped due to loop above)
			if draw == false:
				var corner_line = Line2D.new()
				corner_line.add_point(start_point)
				corner_line.add_point(end_point)
				corner_line.width = 2.0
				corner_line.antialiased = true
				$CurveTest.add_child(corner_line)
			start_point = end_point
			end_point += offset

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
