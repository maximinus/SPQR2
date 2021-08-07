extends Node2D

var regions: Array

func _ready():
	self.regions = MapRegion.getRegions()
