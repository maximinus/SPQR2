extends Control

signal mini_map(pos)

func _ready():
	pass

func updateRegionInfo(region: MapRegion):
	$Overlays/RegionGUI.updateInfo(region)

func _on_MiniMap_map_clicked(pos):
	emit_signal('mini_map', pos)

func update_map_pin(pin_postion: Vector2):
	$MiniMap.set_map_cursor(pin_postion)
