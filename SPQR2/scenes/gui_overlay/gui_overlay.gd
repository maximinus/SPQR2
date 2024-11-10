extends Control

signal mini_map(pos)
signal change_view(index)

func _ready():
	pass

func set_gold_silver(gold: int, silver: int):
	%YearInfo.set_gold_silver(gold, silver)

func update_region_info(region) -> void:
	%RegionSidebar.update(region)

func _on_MiniMap_map_clicked(pos) -> void:
	mini_map.emit(pos)

func update_map_pin(pin_postion: Vector2) -> void:
	%MiniMap.set_map_cursor(pin_postion)

func _on_mini_map_map_clicked(pos: Variant) -> void:
	mini_map.emit(pos)

func _on_mini_map_view_clicked(tab: Variant) -> void:
	change_view.emit(tab)
