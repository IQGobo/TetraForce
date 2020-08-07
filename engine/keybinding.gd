extends Control

# based on https://www.gotut.net/godot-key-bindings-tutorial/

var can_change_key = false
var action_string

enum ACTIONS {A, B, X, Y}

func _ready():
	_set_keys()

func _input(event):
	# differentiate between keyboard keys and joypad buttons to allow to have both mapped at the same time
	if event is InputEventKey:
		if can_change_key:
			_change_key(event, InputEventKey)
			can_change_key = false
	elif event is InputEventJoypadButton:
		if can_change_key:
			_change_key(event, InputEventJoypadButton)
			can_change_key = false

func _change_key(new_key, type):
	# delete actions of the same type as the new key
	if !InputMap.get_action_list(action_string).empty():
		# walk backwards through the array as we may be deleting its items!
		for i in range(InputMap.get_action_list(action_string).size() - 1, -1, -1):
			if InputMap.get_action_list(action_string)[i] is type:
				InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[i])
	
	# remove the new key from any action it is assigned to right now
	for action in ACTIONS:
		if InputMap.action_has_event(action, new_key):
			InputMap.action_erase_event(action, new_key)
	
	# ass the new key to our currently selected action
	InputMap.action_add_event(action_string, new_key)
	
	# update the UI
	_set_keys()

func _actions_join(array : Array, glue : String = "") -> String:
	# concatenates all elements of the input array, separated by the optional glue, into a single string
	var result : String = ""
	for index in range(0, array.size()):
		# keyboard and joypad have different methods to get their descriptive text...
		if array[index] is InputEventKey:
			result += array[index].as_text()
		elif array[index] is InputEventJoypadButton:
			# result += "JOY_BUTTON_" + str(array[index].get_button_index())
			result += Input.get_joy_button_string(array[index].get_button_index())
		else:
			result += "*unknown*"
		if index < array.size() - 1:
			result += glue
	return result

func _set_keys():
	for action in ACTIONS:
		get_node("Panel/ScrollContainer/VBoxContainer/Action_" + str(action) + "/Button").set_pressed(false)
		get_node("Panel/ScrollContainer/VBoxContainer/Action_" + str(action) + "/Label").set_text(str(action))
		if !InputMap.get_action_list(action).empty():
			var btn_text = _actions_join(InputMap.get_action_list(action), ", ")
			get_node("Panel/ScrollContainer/VBoxContainer/Action_" + str(action) + "/Button").set_text(btn_text)
		else:
			get_node("Panel/ScrollContainer/VBoxContainer/Action_" + str(action) + "/Button").set_text("No Button!")

func _mark_button(target):
	can_change_key = true
	action_string = target
	for action in ACTIONS:
		if action != target:
			get_node("Panel/ScrollContainer/VBoxContainer/Action_" + str(action) + "/Button").set_pressed(false)

func button_change_key_A():
	_mark_button("A")

func button_change_key_B():
	_mark_button("B")

func button_change_key_X():
	_mark_button("X")

func button_change_key_Y():
	_mark_button("Y")
