extends Node2D

const ARROW_SIZE = 100
const NEW_ANGLE = 35

# Called when the node enters the scene tree for the first time.
func _ready():
	var all_points = $Line2D.points
	# calculate final angle
	var p2 = all_points[-2]
	var p1 = all_points[-1]
	var last_angle = rad2deg((p2 - p1).angle())
	# make the 2 new angles
	var angle1 = last_angle - NEW_ANGLE
	var angle2 = last_angle + NEW_ANGLE
	# we need to move from this point to a new point on the same angle
	var new_pos1 = Vector2(ARROW_SIZE * cos(deg2rad(angle1)), ARROW_SIZE * sin(deg2rad(angle1))) + p1
	var new_pos2 = Vector2(ARROW_SIZE * cos(deg2rad(angle2)), ARROW_SIZE * sin(deg2rad(angle2))) + p1
	# create the 2 new lines
	var line1 = Line2D.new()
	line1.add_point(p1)
	line1.add_point(new_pos1)
	line1.antialiased = true
	line1.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line1.end_cap_mode = Line2D.LINE_CAP_ROUND
	var line2 = Line2D.new()
	line2.add_point(p1)
	line2.add_point(new_pos2)
	line2.antialiased = true
	line2.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line2.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(line1)
	add_child(line2)
	# and the original
	var oline = Line2D.new()
	for i in all_points:
		oline.add_point(i)
	oline.antialiased = true
	oline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	oline.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(oline)
