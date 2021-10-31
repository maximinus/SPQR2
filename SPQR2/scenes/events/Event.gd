extends Control

var answer_scene = preload('res://scenes/events/EventButton.tscn')
const CLICK_CALLBACKS = ['a1_click', 'a2_click', 'a3_click', 'a4_click']

signal answer_given

func _ready():
	hide()
	clear_answers()

func clear_answers() -> void:
	for i in $Center/Bck/Mrg/Inner/Answers.get_children():
		i.queue_free()	

func ask(question: String, answers: Array) -> void:
	# this will block all other input (except the pause screen)
	if len(answers) == 0:
		helpers.log('Error: Event with no answers')
		return
	if len(answers) > 4:
		helpers.log('Error: Too many possible answers')
		return
	$Center/Bck/Mrg/Inner/Mrg3/Question.text = question
	clear_answers()
	var click_index = 1
	for i in answers:
		var new_answer = answer_scene.instance()
		new_answer.text = i
		# add callback
		new_answer.connect('pressed', self, CLICK_CALLBACKS[click_index])
		click_index += 1
		$Center/Bck/Mrg/Inner/Answers.add_child(new_answer)
	show()

func hide_dialog(answer: int) -> void:
	emit_signal('answer_given', answer)
	hide()

func a1_click() -> void:
	# hide and raise signal with data
	hide_dialog(1)

func a2_click() -> void:
	hide_dialog(2)
	
func a3_click() -> void:
	hide_dialog(3)
	
func a4_click() -> void:
	hide_dialog(4)
