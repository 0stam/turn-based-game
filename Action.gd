extends Node

var queue : Array = [] # List of entities in the 
var current : int = 0 # Index of entity currently performing it's turn
var current_action = null # Action type selected

export var board_system_path : NodePath # Path to board system

onready var board = get_node(board_system_path) # Actual board system refference
onready var signals = Signals

func _ready():
	signals.connect("action_changed", self, "on_action_changed")
	signals.connect("field_pressed", self, "on_field_pressed")
	signals.connect("entity_added", self, "add_entity")
	signals.connect("queue_clear_requested", self, "clear_queue")


func add_entity(entity_position : Vector2): # Add new entity position
	queue.append(entity_position)


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


func on_action_changed(action : String):
	current_action = action


func on_field_pressed(position : Vector2):
	match current_action:
		"move":
			print("Move position: ", position)
			# Checking if field is reachable
			board.reset_flood_fill()
			board.flood_fill_check(queue[current], board.get_key(queue[current], "move") + 1)
			if board.flood_fill[position.x][position.y]:
				board.move(Vector3(1, queue[current].x, queue[current].y), Vector3(1, position.x, position.y))
				queue[current] = position
				next()
			
