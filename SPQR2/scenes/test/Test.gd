extends Spatial

var started: bool = false

func _ready():
	pass

func _process(_delta):
	if started == false:
		start_animation()
	started = true
	print($CSGMesh.rotation_degrees.y)

func start_animation() -> void:
	# now we build up the animations. Remove the old one if it exists
	$MoveUnit.remove_animation('move')
	var anim = Animation.new()
	var index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(index, @'CSGMesh:rotation_degrees:y')
	anim.track_insert_key(index, 0.0, rotation_degrees.y)

	var rotate_end = 60.0
	var total_time = 0.0
	for i in range(10):
		total_time += 2.0
		anim.track_insert_key(index, total_time, rotate_end)
		rotate_end += 40.0 + total_time

	# now all the tracks have been added, set length of animation
	anim.length = total_time
	# add to animation player
	$MoveUnit.add_animation('move', anim)
	$MoveUnit.play('move')
	print('Playing')
