extends Node

var queue : Array = [] # List of entities in the 
var current : int = 0 # Index of entity currently performing it's turn
var current_action = null # Action type selected
var actions_usages = {} # Dictionary holding number of specific action usages in given turn
var ap = 0

export var board_system_path : NodePath # Path to board system

onready var board = get_node(board_system_path) # Actual board system refference
onready var signals = Signals

func _ready():
	signals.connect("action_changed", self, "on_action_changed")
	signals.connect("field_pressed", self, "on_field_pressed")
	signals.connect("entity_added", self, "add_entity")
	signals.connect("queue_clear_requested", self, "clear_queue")
	signals.connect("turn_passed", self, "next")


func init_entity_variables():
	ap = board.get_entity(queue[current])["ap"]
	actions_usages = {}
	for i in board.get_entity(queue[current])["actions"]:
		actions_usages[i] = board.get_entity(queue[current])["actions"][i]["usage_limit"]


func add_entity(index : int): # Add new entity position
	queue.append(index)
	if len(queue) == 1:
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


func on_field_pressed(position : Vector2):
	if actions_usages[current_action] == 0:
		return
	match board.get_entity(queue[current])["actions"][current_action]["type"]:
		"move":
			print("Move position: ", position)
			# Checking if field is reachable
			# TODO: move to targeting system
			board.reset_flood_fill()
			board.flood_fill_check(board.get_entity_position(queue[current]),
								   board.get_entity(queue[current])["actions"]["move"]["val"] + 1,
								   [board.get_entity_position(queue[current])])
			if board.flood_fill[position.x][position.y] and position != board.get_entity_position(queue[current]):
				board.move(Vector3(1, board.get_entity_position(queue[current]).x, board.get_entity_position(queue[current]).y),
						   Vector3(1, position.x, position.y))
				signals.emit_signal("entity_moved", queue[current], position)
			else:
				return
		_:
			return
	ap -= 1
	actions_usages[current_action] -= 1
	if ap == 0:
		next()
		signals.emit_signal("current_entity_changed", current)
