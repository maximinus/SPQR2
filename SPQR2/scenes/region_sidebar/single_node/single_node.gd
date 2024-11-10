extends VBoxContainer

var boxes: Array

func _ready() -> void:
	boxes.append([%Army1Img, %Army1Lbl])
	boxes.append([%Army2Img, %Army2Lbl])
	boxes.append([%Army3Img, %Army3Lbl])
	boxes.append([%Army4Img, %Army4Lbl])
	boxes.append([%Army5Img, %Army5Lbl])
	boxes.reverse()

func setup(values: Array):
	# hide the elements we don't know
	var hide_total = 5 - len(values)
	for i in range(hide_total):
		boxes[i][0].hide()
		boxes[i][1].hide()
	var index = 4
	for i in values:
		boxes[index][0].show()
		boxes[index][1].show()
		boxes[index][1].text = i
		index += 1
