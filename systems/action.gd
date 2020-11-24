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


func init_entity_variables(): # Initialize temporary variables which are not stored in the enity itself
	current_entity = board.get_entity(queue[current])
	ap = board.get_entity(queue[current])["ap"]
	actions_usages = {}
	for i in board.get_entity(queue[current])["actions"]:
		actions_usages[i] = board.get_entity(queue[current])["actions"][i]["usage_limit"]
	current_action = ""
	signals.emit_signal("current_entity_changed", current)
	signals.emit_signal("targeting_called", {"type": ""}) # Telling targeting system to reset


func add_entity(index : int):
	queue.append(index)
	if len(queue) == 1: # If this is the only entity in queue, set all variables for using it as the active one
		init_entity_variables()


func remove_entity(index : int):
	queue.remove(index)


func shuffle_queue():
	queue.shuffle()


func clear_queue():
	queue = []
	current = 0


func next():
	if current != len(queue) - 1:
		current += 1
	else:
		current = 0
	init_entity_variables()


func on_action_changed(action : String):
	current_action = action
	print("INFO: Action changed: ", action)
	if typeof(current_entity["actions"][action]) == TYPE_STRING:
		print("Ooops")
	signals.emit_signal("targeting_called", current_entity["actions"][action])


func on_field_pressed(position : Vector2):
	if current_action == "":
		return
	if actions_usages[current_action] == 0:
		return
	match current_entity["actions"][current_action]["type"]:
		"move":
			if valid_targets[position.x][position.y]:
				board.move(Vector3(1, board.get_entity_position(queue[current]).x, board.get_entity_position(queue[current]).y),
						   Vector3(1, position.x, position.y))
				signals.emit_signal("entity_moved", queue[current], position)
				print("Move position: ", position)
			else: # If move is incorrect, prevent ap and action_usages from decreasing
				return
		_: # If action type is incorrect, should never happen
			print("***Incorrect aciton type was chosen***")
			return # Preventing ap from decreasing because of error
	ap -= 1
	actions_usages[current_action] -= 1
	if ap == 0:
		next()


func on_targets_changed(targets : Array):
	valid_targets = targets


func on_action_triggered(action : String):
	match action:
		"pass":
			print("INFO: Turn passed")
			next()
		_:
			print("***Incorrect action type was triggered***")
