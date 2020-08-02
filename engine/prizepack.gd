extends Node

var index : int = 0
var pool : Array = []
var rng : RandomNumberGenerator = RandomNumberGenerator.new()
var chance : float = 0.5

func _ready():
	rng.randomize()

func _init(items : Array, threshold : float):
	pool = items
	chance = threshold

# returns the loot drop item for the current kill count in the prize pack
# keeps track of which item to drop and only provides an item if a random
# value matches the chance to drop an item
func get_drop() -> String:
	var drop = ""
	if rng.randf() <= chance:
		drop = pool[index % pool.size()]
	index += 1
	if index > pool.size() * 100:
		index = 0
	return drop
