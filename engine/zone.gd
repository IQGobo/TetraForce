extends Area2D

export var music = ""
export var musicfx = ""
export var light = ""

func _ready():
	if music == "":
		music = get_parent().get_parent().music
	if musicfx == "":
		musicfx = get_parent().get_parent().musicfx
	if light == "":
		light = get_parent().get_parent().light
