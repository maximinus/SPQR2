@tool
extends Sprite2D

class EditorUnit:
	var foot: float
	var mounted: float
	var quality: int
	var morale: int

@export var node_name: String
@export var population: String

@export var things: Array

func _ready():
	pass
