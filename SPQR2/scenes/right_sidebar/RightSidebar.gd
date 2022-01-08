extends Control

# this should be passed a region of some kind

func _ready():
	var data = get_data()
	updateSidebar(data)

func get_units(total):
	var units = [{'foot': 9000, 'mounted': 2000, 'quality': 8, 'morale': 7},
				 {'foot': 6000, 'mounted': 1000, 'quality': 8, 'morale': 7},
				{'foot': 10000, 'mounted': 2000, 'quality': 8, 'morale': 7},
				{'foot': 8500, 'mounted': 3000, 'quality': 8, 'morale': 7}]
	var funits = []
	for i in range(total):
		funits.append(data.NewUnit.new(units[i]))
	return funits

func get_nodes():
	var nodes = [{'name': 'Londinium', 'population':5, 'romanisation':7, 'wealth':5, 'happiness':7, 'christianity':0},
				 {'name': 'Minerva', 'population':5, 'romanisation':7, 'wealth':5, 'happiness':7, 'christianity':0},
				 {'name': 'Glevum', 'population':5, 'romanisation':7, 'wealth':5, 'happiness':7, 'christianity':0},
				 {'name': 'York', 'population':5, 'romanisation':7, 'wealth':5, 'happiness':7, 'christianity':0}]
	var fnodes = []	
	for i in nodes:
		var new_node = data.NewNode.new(i)
		# now add some units 1 - 4
		var total = int(rand_range(0.51, 4.0))
		new_node.units = get_units(total)
		fnodes.append(new_node)
	return fnodes
	
func get_data() -> data.NewMapRegion:
	var map_data = {'name': 'Germania',
					'climate': cn.ClimateTypes.MARITIME,
					'terrain': cn.TerrainTypes.FOREST,
					'crops': cn.CropGrowth.BAD}
	var region = data.NewMapRegion.new(map_data)
	for i in get_nodes():
		region.nodes.append(i)
	return region

func updateSidebar(region: data.NewMapRegion) -> void:
	$VBoxContainer/SidebarTitle.set_title(region.region_name)
	$VBoxContainer/RegionDisplay.set_region_data(region)
	var index = 0
	for i in $VBoxContainer/MarginContainer/NodeBox.get_children():
		if len(region.nodes) > index:
			i.show()
			i.set_node_data(region.nodes[index])
		else:
			i.hide()
		index += 1
