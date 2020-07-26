extends Node
class_name Randomizer

# The randomizer is called via the main function "create".
# Right now it needs two mapping files:
# - one with the location IDs and their original item to drop in the main game
#   As this will be the same for each randomizer setting, you don't have to
#   provide the file name, its default is "res://config/location2loot.json"
# - one with the location IDs and a conditional expression, which equipment is 
#   needed to access this location
# Those files are manually crafted by now, maybe the loot one can be exported
# automatically later on.

# The function also takes an array of starting equipment to allow for more varied
# starting conditions. Players might only spawn with a single heart or with
# additional gear to ease the early game, like better armor or starting with
# bombs already. 
# The generated file has the starting equipment at ["metadata"]["startingequipment"]
# plus some additional info like the creation timestamp and the file used for
# the logic of that seed.

# The generated seed is saved as a JSON file in user-space.
# The file is put into the "seeds" subdirectory and named after the MD5-Hash
# of the JSON contents. In future those seed files will be selected at the start
# of the game by the host.

func create(logicFileName: String, startingEquipment : Array) -> String:
	randomize()
	
	var logic : Dictionary = _loadJson(logicFileName)
	# print("Logic: ", logic)
	var locations : Dictionary = _loadJson("res://config/location2loot.json")
	# print("Locations: ", locations)
	
	# sanity check if all random loot drop location are known to the logic
	for location in locations.keys():
		if not logic.has(location):
			print("ERROR: location ", location, " is unknown to logic!")
			return "ERROR: unknown location"
	
	# loop until the size of redistributed equals locations
	var redistributed : Dictionary = {}
	var maxTries : int = 20
	var tries : int = 0
	while redistributed.size() < locations.size() && tries < maxTries:
		redistributed = _shuffle(logic, locations, startingEquipment)
		tries += 1
	if redistributed.size() < locations.size():
		print("ERROR: could not generate a random distribution with all locations")
		return "ERROR: incomplete seed"
	var ts = OS.get_unix_time()
	redistributed["metadata"] = {}
	redistributed["metadata"]["createdate"] = OS.get_datetime_from_unix_time(ts)
	redistributed["metadata"]["unixtimestamp"] = ts
	redistributed["metadata"]["startingequipment"] = startingEquipment
	redistributed["metadata"]["logicfile"] = logicFileName
	print("new seed: ", redistributed)
	
	# save redistributed as seed file to user directory "seeds" with a hashed name
	# the real path should be something like "%APPDATA%/TetraForce/seeds/<timestamp>_<hash>.json" on Windows
	# or "~/.local/share/godot/app_userdata/TetraForce/seeds/<timestamp>_<hash>.json" for Mac and Linux
	# <timestamp> is a unix epoch timestamp, seconds passed since 1970-01-01 00:00:00
	# <hash> is the MD5 of the JSON representation of the data in the file
	
	var seedDir : String = "user://seeds/"
	var dirHandle = Directory.new()
	var redistributedJson : String = to_json(redistributed)
	var redistributedHash : String = redistributedJson.md5_text()
	var seedFileName : String= seedDir + String(ts) + "_" + redistributedHash + ".json"
	# print("\nAttempting to save seed to file ", seedFileName)
	
	if not dirHandle.dir_exists(seedDir):
		dirHandle.make_dir_recursive(seedDir)
	
	print(_saveJson(seedFileName, redistributedJson))
	
	return "OK: " + redistributedHash

func _loadJson(filename : String):
	var file := File.new()
	if not file.file_exists(filename):
		print("ERROR: could not load file ", filename)
		return "ERROR: load " + filename
	file.open(filename, File.READ)
	var result = parse_json(file.get_as_text())
	file.close()
	return result

func _saveJson(filename : String, contents) -> String:
	var file = File.new()
	var openError = file.open(filename, File.WRITE)
	if openError != OK:
		print("ERROR: Could not save to file " + filename + ", code ", openError)
		return "ERROR: save failed for " + filename
	file.store_string(contents)
	file.close()
	return "OK: saved " + filename

func _shuffle(logic : Dictionary, locationData : Dictionary, startingEquipment : Array = ["heartfull", "heartfull", "heartfull"]) -> Dictionary:
	var locations : Array = locationData.keys()
	var drops : Array = []

	for location in locations:
		drops.append(locationData[location])

	var inventory : Dictionary = _randomizerInventoryInit(drops)
	for item in startingEquipment:
		inventory = _randomizerInventoryAdd(inventory, item)

	# pick a random one of availableLocations and assign it a random item until no more locations are available
	var randomizedLootDistribution : Dictionary = {}
	var available : Array = _availableLocations(locations, inventory, logic)
	# print("Available: ", available)
	while available.size():
		available.shuffle()
		drops.shuffle()
		var location : String = available.pop_back()
		var item = drops.pop_back()
		var pos : int = locations.find(location)
		if pos >= 0:
			locations.remove(pos)
		randomizedLootDistribution[location] = item
		inventory = _randomizerInventoryAdd(inventory, item)
		available = _availableLocations(locations, inventory, logic)
	
	return randomizedLootDistribution

func _availableLocations(locations : Array, has : Dictionary, logic : Dictionary) -> Array:
	var expression = Expression.new()
	var result : Array = []
	
	# loop over locations and add location that satisfies logic with the current inventory to result
	# note: we named the Randomizer's inventory "has" in this function for easy reference in the condition
	for location in locations:
		# print("Inventory is ", has)
		# print("Evaluating ", logic[location])
		var parsed = expression.parse(logic[location], PoolStringArray(["has"]))
		if parsed == OK:
			var evaluation = expression.execute([has], null, true)
			if not expression.has_execute_failed():
				if evaluation:
					result.append(location)
		else:
			print("ERROR: could not parse ", logic[location])
	
	return result

func _randomizerInventoryInit(items : Array) -> Dictionary:
	var result : Dictionary = {}
	
	# numerical loadout
	result["hearts"] = 0
	result["piecesofheart"] = 0
	result["coins"] = 0
	
	# pseudo items for advanced strategies and easier conditions
	
	# "darkroomtraversal" indicates if the player is able to go through dark
	# rooms. Will get set by any light source the player picks up, but can be
	# set as a starting equipment for advanced logic, if a player is able to
	# go through dark rooms blindly
	result["darkroomtraversal"] = false
	
	# at the initialization phase we are not interested in these items
	var skipItems = ["heartfull", "heartpiece", "redcoin", "bluecoin", "greencoin", "purplecoin", "silvercoin", "goldcoin"]
	
	for item in items:
		if skipItems.has(item):
			continue
		# set everything else to false, so the logic checks don't choke up
		result[item] = false
	
	return result

func _randomizerInventoryAdd(inventory : Dictionary, item : String) -> Dictionary:
	# TODO: add logic for more items and items that can tier up
	match item:
		"heartfull":
			inventory["hearts"] += 1
		"heartpiece":
			inventory["piecesofheart"] += 1
			if inventory["piecesofheart"] % 4 == 0:
				inventory["hearts"] += 1
		"redcoin":
			inventory["coins"] += 20
		"bluecoin":
			inventory["coins"] += 5
		"greencoin":
			inventory["coins"] += 1
		"purplecoin":
			inventory["coins"] += 50
		"silvercoin":
			inventory["coins"] += 100
		"goldcoin":
			inventory["coins"] += 300
		"lamp":
			inventory[item] = true
			inventory["darkroomtraversal"] = true
		_:
			inventory[item] = true
	
	return inventory
