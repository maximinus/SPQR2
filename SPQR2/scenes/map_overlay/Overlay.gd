extends Control

signal mini_map(pos)
signal change_view(index)

func _ready():
	pass

func set_gold_silver(gold: int, silver: int):
	$YearInfo.set_gold_silver(gold, silver)

func update_region_info(region: MapRegion) -> void:
	$RegionGUI.update_info(region)

func _on_MiniMap_map_clicked(pos) -> void:
	emit_signal('mini_map', pos)

func update_map_pin(pin_postion: Vector2) -> void:
	$MiniMap.set_map_cursor(pin_postion)

func _on_MiniMap_view_clicked(tab) -> void:
	emit_signal('change_view', tab)
