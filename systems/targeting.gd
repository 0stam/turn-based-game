extends Node

var avaialable_fields : Array = [] # Array keeping valid targets for given action
var current_entity : int = 0

export var board_path : NodePath

onready var board : Node = get_node(board_path)
onready var signals = Signals


func _ready():
	signals.connect("current_entity_changed", self, "on_current_entity_changed")
	signals.connect("targeting_called", self, "on_targeting_called")


func on_current_entity_changed(index : int):
	current_entity = index


func on_targeting_called(action):
	match action["type"]:
		"move":
			possible_move(board.get_entity_position(current_entity), action["val"])
		_:
			reset()
	signals.emit_signal("targets_changed", avaialable_fields)


func possible_move(entity_position : Vector2, move : int):
	board.reset_flood_fill()
	board.flood_fill_check(entity_position, move, [entity_position])
	avaialable_fields = board.flood_fill.duplicate(true)


func reset():
	board.reset_flood_fill()
	avaialable_fields = board.flood_fill.duplicate(true)
