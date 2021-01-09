extends Node

# Variables storing other systems' paths
export(NodePath) var board_data_path
export(NodePath) var data_path

# Controlled nodes
export(NodePath) var entity_panel_path
export(NodePath) var action_menu_path
export(NodePath) var board_path
export(NodePath) var action_display_path
export(NodePath) var trigger_action_path

# Resolved referrences to nodes for which paths vere given
onready var board_data : Node = get_node(board_data_path)
onready var data : Node = get_node(data_path)
onready var board : Control = get_node(board_path)
onready var entity_panel : VBoxContainer = get_node(entity_panel_path)
onready var action_menu : HBoxContainer = get_node(action_menu_path)
onready var action_display : MarginContainer = get_node(action_display_path)
onready var entity_temp : Dictionary = board_data.entity_temp
onready var trigger_action : MarginContainer = get_node(trigger_action_path)
onready var signals = Signals

var button_types : Dictionary = {} # Determines if action button should be created as change or trigger type
var graphics = {} # Variable storing list of used graphics to avoid loading single texture multiple times
var current_entity = 0 # Variable storing current entity index for the sake of updating it's ap
var color : String # Stores color for UI elements matching current player

func _ready():
	signals.connect("board_changed", self, "update_board")
	signals.connect("queue_clear_requested", self, "clear_entities")
	signals.connect("entity_added", self, "on_entity_added")
	signals.connect("current_entity_changed", self, "on_current_entity_changed")
	signals.connect("targets_display_changed", self, "on_targets_display_changed")
	signals.connect("action_succeeded", self, "on_action_succeeded")
	signals.connect("targeting_called", self, "on_targeting_called")
	signals.connect("entity_removed", self, "on_entity_removed")
	


func get_graphic(name : String) -> Texture: # Function for loading with "graphics" variable
	if not name in graphics:
		graphics[name] = load("res://art/".plus_file(name))
	return graphics[name]


func update_board() -> void: # Sets all board's fields graphics to proper values
	for i in range(len(board_data.board[0])):
		for j in range(len(board_data.board[0][i])):
			if board_data.get_key(Vector2(i, j), "graphic") != null:
				board.set_field(Vector2(i, j), get_graphic(board_data.get_key(Vector2(i, j), "graphic")))
			else:
				board.set_field(Vector2(i, j), null)


func clear_entities() -> void: # Tells entity_panel to reset
	entity_panel.clear_entities()


func on_entity_added(index : int) -> void: # Adds new row to the entity panel
	var entity : Dictionary = board_data.get_entity(index)
	entity_panel.add_entity(entity["name"], str(entity["hp"]), str(entity["ap"]), board_data.get_entity_count() == 1, entity["color"])


func on_current_entity_changed(index : int) -> void:
	current_entity = index
	entity_panel.set_active(index) # Set correct current highlight on entity_panel
	
	for i in range(board_data.get_entity_count()): # Reset displayed ap values
		entity_panel.modify(i, "ap", str(board_data.get_entity(i)["ap"]))
	
	color = board_data.get_entity(current_entity)["color"]
	
	# Create action buttons
	var entity : Dictionary = board_data.get_entity(index)
	action_menu.clear()
	print(entity_temp)
	for i in entity["actions"].keys():
		var action : Dictionary = entity["actions"][i]
		var on_cooldown : bool = "cooldown" in action and action["cooldown"][0] < action["cooldown"][1]
		action_menu.add_button(action["name"], i, action["cost"], action["usage_limit"], entity["color"], on_cooldown)


func on_targets_display_changed(targets : Array) -> void:
	for i in range(len(targets)):
		for j in range(len(targets[i])):
			if targets[i][j]:
				board.set_border(Vector2(i, j), Color(color))
			else:
				board.set_border(Vector2(i, j), Color(1, 1, 1, 1))


func on_action_succeeded() -> void:
	for i in range(board_data.get_entity_count()):
		var entity : Dictionary = board_data.get_entity(i)
		if current_entity == i:
			entity_panel.modify(i, "ap", str(entity_temp["ap"]))
		else:
			entity_panel.modify(i, "ap", str(entity["ap"]))
		entity_panel.modify(i, "hp", str(entity["hp"]))
	action_menu.refresh_buttons(entity_temp["ap"], entity_temp["actions_usages"])


func on_targeting_called(action): # Function updateing action specific information (description and trigger)
	# Clear the parameter information panel and hide trigger button
	action_display.clear()
	trigger_action.hide()
	
	if action["target"][0] == "": # If action is reseted, stop here
		return
	
	# Fill ActionDisplay with proper parameters
	var rules : Dictionary = data.rules["action_parameters"]
	var aliases : Dictionary = data.rules["aliases"]
	
	for i in rules.keys(): # For each key in rules (uses rules instead of action for consistent parameter order)
		if not i in action: # If given key isn't present it current action, continue
			continue

		var alias = action[i] # Variable holding value to be displayed, can be overwitten by alias
		if i in aliases: # If given parameter has aliases available
			for j in aliases[i]:
				if j[0] == action[i]:
					alias = j[1]
		if alias is Array:
			action_display.add_parameter(rules[i], str(alias[0]) + "-" + str(alias[1]))
		else:
			action_display.add_parameter(rules[i], str(alias))
	
	if action["target"][0] in data["rules"]["action_button_types"]["trigger"]: # Show trigger button if necessary
		trigger_action.show()


func on_entity_removed(index : int):
	entity_panel.remove_entity(index)
