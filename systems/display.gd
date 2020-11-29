extends Node

# Variables storing other systems' paths
export(NodePath) var board_data_path
export(NodePath) var data_path

# Controlled nodes
export(NodePath) var entity_panel_path
export(NodePath) var action_menu_path
export(NodePath) var board_path

# Resolved referrences to nodes for which paths vere given
onready var board_data : Node = get_node(board_data_path)
onready var data : Node = get_node(data_path)
onready var board : Control = get_node(board_path)
onready var entity_panel : VBoxContainer = get_node(entity_panel_path)
onready var action_menu : HBoxContainer = get_node(action_menu_path)
onready var signals = Signals

var graphics = {} # Variable storing list of used graphics to avoid loading single texture multiple times
onready var button_types : Dictionary = {} # Determines if action button should be created as change or trigger type


func _ready():
	signals.connect("board_changed", self, "update_board")
	signals.connect("queue_clear_requested", self, "clear_entities")
	signals.connect("entity_added", self, "on_entity_added")
	signals.connect("current_entity_changed", self, "on_current_entity_changed")
	signals.connect("targets_changed", self, "on_targets_changed")


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


func clear_entities(): # Tells entity_panel to reset
	entity_panel.clear_entities()


func on_entity_added(index : int) -> void: # Adds new row to the entity panel
	var entity : Dictionary = board_data.get_entity(index)
	entity_panel.add_entity(entity["id"], str(entity["hp"]), str(entity["ap"]), board_data.get_entity_count() == 1)


func on_current_entity_changed(index : int) -> void:
	entity_panel.set_active(index) # Set current correct highlight on entity_panel
	
	# Create action buttons
	var entity : Dictionary = board_data.get_entity(index)
	action_menu.clear()
	for i in entity["actions"].keys():
		if entity["actions"][i]["type"] in data["rules"]["action_button_types"]["change"]:
			action_menu.add_button(i, i, "change")
		elif entity["actions"][i]["type"] in data["rules"]["action_button_types"]["trigger"]:
			action_menu.add_button(i, i, "trigger")
		else:
			action_menu.add_button(i, i, "trigger")
			print("***Incorrect action button type was chosen***")


func on_targets_changed(targets : Array) -> void:
	for i in range(len(targets)):
		for j in range(len(targets[i])):
			if targets[i][j]:
				board.set_border(Vector2(i, j), Color("#ff1f1f"))
			else:
				board.set_border(Vector2(i, j), Color(1, 1, 1, 1))
