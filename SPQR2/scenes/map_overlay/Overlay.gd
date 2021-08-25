extends Control

func _ready():
	pass

func updateRegionInfo(region: MapRegion):
	$Overlays/RegionGUI.updateInfo(region)
