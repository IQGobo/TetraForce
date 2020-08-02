extends Node
class_name prizepacks

# will hold an array of prizepack objects
var packs : Array = []

# will remap prizepack indexes, usefull for randomized games
var remapped : Array = []

func _init():
	# default prize pack definitions, array of items to drop and the chance to drop
	var packdefs : Array = [
		{"pool": [""], "chance": 1.0},
		{"pool": ["smallheart","whitetetran"], "chance": 0.5},
		{"pool": ["whitetetran","whitetetran","smallheart","redtetran"], "chance" : 0.5},
		{"pool": ["smallheart","redtetran","smallheart","bluetetran"], "chance": 0.5},
		{"pool": ["whitetetran","redtetran","bluetetran","greentetran"], "chance": 0.5}
	]
	var pp = load("res://engine/prizepack.gd")
	for p in packdefs:
		packs.append(pp.new(packdefs[p].pool, packdefs[p].chance))

func remap():
	if packs.size() > 0:
		for i in range(packs.size()):
			remapped[i] = i
	else:
		remapped = []

func set_map(map : Array):
	if map.size() > packs.size():
		remap()
	else:
		remapped = map

func _ready():
	remap()

# each enemy should have a prizepack property (integer) to pass to this function on kill
func get_drop_from_pack(pack : int) -> String:
	if pack >= packs.size():
		return ""
	return packs[remapped[pack]].get_drop()
