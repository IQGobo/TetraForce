extends Node

class_name Randomizer

# var rng = RandomNumberGenerator.new()

func create(logicFileName: String, startingEquipment : Array) -> String:
	# rng.randomize()
	randomize()
	# print("Random number: ", randi())
	
	var logicFile := File.new()
	if not logicFile.file_exists(logicFileName):
		print("ERROR: could not load file with randomizer logic at ", logicFileName)
		return "ERROR: load logic"
	logicFile.open(logicFileName, File.READ)
	var logic : Dictionary = parse_json(logicFile.get_as_text())
	logicFile.close()
	# print("Logic: ", logic)
	
	var locationFile := File.new()
	var locationFileName := "res://config/location2loot.json"
	if not locationFile.file_exists(locationFileName):
		print("ERROR: coult not load file with location data at ", locationFileName)
		return "ERROR: load locations"
	locationFile.open(locationFileName, File.READ)
	var locations : Dictionary = parse_json(locationFile.get_as_text())
	locationFile.close()
	# print("Locations: ", locations)
	
	# sanity check if all random loot drop location are known to the logic
	for location in locations.keys():
		if not logic.has(location):
			print("ERROR: location ", location, " is unknown to logic!")
			return "ERROR: unknown location"
	
	# loop until the size of redistributed equals locations
	var redistributed : Dictionary = {}
	var maxTries = 20
	var tries = 0
	while redistributed.size() < locations.size() && tries < maxTries:
		redistributed = _shuffle(logic, locations, startingEquipment)
		tries += 1
	if redistributed.size() < locations.size():
		print("ERROR: could not generate a random distribution with all locations")
		return "ERROR: incomplete seed"
	print("new seed: ", redistributed)
	
	# save redistributed as seed file to user directory "seeds" with a hashed name
	# the real path should be something like "%APPDATA%/TetraForce/seeds/<hash>.json" on Windows
	# or "~/.local/share/godot/app_userdata/TetraForce/seeds/<hash>.json" for Mac and Linux
	
	var seedDir = "user://seeds/"
	var dirHandle = Directory.new()
	var redistributedJson = to_json(redistributed)
	var redistributedHash = redistributedJson.md5_text()
	var seedFileName = seedDir + redistributedHash + ".json"
	# var seedFileName = "user://seed.json"
	# print("\nAttempting to save seed to file ", seedFileName)
	
	if not dirHandle.dir_exists(seedDir):
		dirHandle.make_dir_recursive(seedDir)
	var seedFile = File.new()
	var openError = seedFile.open(seedFileName, File.WRITE)
	if openError != OK:
		print("ERROR: Could not save seed to File, code ", openError)
		return "ERROR: save seed failed"
	seedFile.store_string(redistributedJson)
	seedFile.close()
	
	return "OK: " + redistributedHash

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
	
	result["hearts"] = 0
	result["piecesofheart"] = 0
	result["coins"] = 0
	
	var skipItems = ["heartfull", "heartpiece", "redcoin", "bluecoin", "greencoin", "purplecoin", "silvercoin", "goldcoin"]
	
	for item in items:
		if skipItems.has(item):
			continue
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
		_:
			inventory[item] = true
	
	return inventory
