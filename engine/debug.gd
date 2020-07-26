extends CanvasLayer

onready var text = $Control/Label
var debug_text : String = "empty"

func _init():
	var Randomizer : Resource = load("res://randomizer/randomizer.gd")
	var rzer : Randomizer = Randomizer.new()
	debug_text = rzer.create("res://config/location2logic.json", ["heartfull", "heartfull", "heartfull"])

func _process(delta):
	text.text = str(
		"Player List: ", network.player_list,
		"\nMap Peers: ", network.map_peers,
		"\nMap Hosts: ", network.map_hosts,
		"\nPlayer Nodes: ", get_tree().get_nodes_in_group("player"),
		"\nRandomizer: ", debug_text
		)
