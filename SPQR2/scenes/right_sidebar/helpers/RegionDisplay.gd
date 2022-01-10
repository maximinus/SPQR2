extends MarginContainer

func _ready():
	pass

func set_region_data(rdata):
	$VBox/RegionIcons.set_icons(rdata.crops, rdata.climate, rdata.terrain)
	$VBox/RegionTotals.update_data(rdata)
