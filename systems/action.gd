extends Node

var queue : Array = [] # List of entities in the 
var current : int = 0 # Index of entity currently performing it's turn
var current_action = null # Action type selected
var actions_usages = {} # Dictionary holding number of specific action usages in given turn
var ap = 0
var current_entity : Dictionary # Variable storing current entity dictionary for easier access
var valid_targets : Array = [] # Array recieved from targeting, stores bools for valid/invalid

export var board_system_path : NodePath # Path to board system

onready var board = get_node(board_system_path) # Actual board system refference
onready var signals = Signals

func _ready():
	signals.connect("action_changed", self, "on_action_changed")
	signals.connect("field_pressed", self, "on_field_pressed")
	signals.connect("entity_added", self, "add_entity")
	signals.connect("queue_clear_requested", self, "clear_queue")
	signals.connect("turn_passed", self, "next")
	signals.connect("targets_changed", self, "on_targets_changed")
	signals.connect("action_triggered", self, "on_action_triggered")


func init_entity_variables() -> void: # Initialize temporary variables which are not stored in the enity itself
	current_entity = board.get_entity(queue[current])
	ap = board.get_entity(queue[current])["ap"]
	actions_usages = {}
	for i in board.get_entity(queue[current])["actions"]:
		actions_usages[i] = board.get_entity(queue[current])["actions"][i]["usage_limit"]
	current_action = ""
	signals.emit_signal("current_entity_changed", current)
	signals.emit_signal("targeting_called", {"type": ""}) # Telling targeting system to reset


func add_entity(index : int) -> void:
	queue.append(index)
	if len(queue) == 1: # If this is the only entity in queue, set all variables for using it as the active one
		init_entity_variables()


func remove_entity(index : int) -> void:
	queue.remove(index)


func shuffle_queue() -> void:
	queue.shuffle()


func clear_queue() -> void:
	queue = []
	current = 0


func next() -> void:
	if current != len(queue) - 1:
		current += 1
	else:
		current = 0
	init_entity_variables()


func on_action_changed(action : String) -> void:
	current_action = action
	print("INFO: Action changed: ", action)
	signals.emit_signal("targeting_called", current_entity["actions"][action])


func on_field_pressed(position : Vector2) -> void: # Handle actions triggered by pressing a field
	if current_action == "": # If player hasn't chosen any action yet.
		return
	if not validate_action():
		return
	if not valid_targets[position.x][position.y]:
		return
	match current_entity["actions"][current_action]["type"]: # If action is valid, match correct action
		"move":
			var entity_pos : Vector2 = board.get_entity_position(queue[current])
			board.move(Vector3(1, entity_pos.x, entity_pos.y), Vector3(1, position.x, position.y))
			signals.emit_signal("entity_moved", queue[current], position)
			print("Move position: ", position)
		"attack":
			var target : Dictionary = board.get_entity(board.get_entity_index(position))
			var damage : int = int(rand_range(current_entity["actions"][current_action]["val"][0], 
								current_entity["actions"][current_action]["val"][1] + 1))
			var pierce : int = current_entity["actions"][current_action]["pierce"]
			signals.emit_signal("attack_requested", target, damage, pierce)
			print("INFO: Target health after damage: ", target["hp"])
		_: # If action type is incorrect, should never happen
			print("***Incorrect aciton type was chosen***")
			return # Preventing ap from decreasing because of error
	end_action()


func on_targets_changed(targets : Array) -> void:
	valid_targets = targets # Put targets recieved from the Targeting system into local variable


func on_action_triggered(action : String) -> void: # Handle actions which doesn't require manual aiming
	if not validate_action():
		return
	match action:
		"pass":
			print("INFO: Turn passed")
			next()
			return
		_: # If incorrect action type was chosen, should never happen
			print("***Incorrect action type was triggered***")
			return
	end_action()


func validate_action() -> bool: # Returns true if action is valid
	if current_entity["actions"][current_action]["cost"] > ap:
		return false
	if actions_usages[current_action] < 1:
		return false
	return true


func end_action() -> void:
	ap -= current_entity["actions"][current_action]["cost"]
	actions_usages[current_action] -= 1
	current_action = ""
	if ap < 1:
		next()
		signals.emit_signal("action_succeeded", ap)
	else:
		signals.emit_signal("action_succeeded", ap)
		signals.emit_signal("targeting_called", {"type": ""})
