extends Node

var available_fields : Array = [] # Array keeping valid targets for given action
var display : Array = [] # Version of available_fields to be displayed on the board
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
			possible_move(board.get_entity_position(current_entity), action["val"] + 1)
		"attack":
			var entity : Dictionary = board.get_entity(current_entity)
			attack(board.get_entity_position(current_entity), entity["team"], action["range"])
		_:
			reset()
	signals.emit_signal("targets_changed", available_fields)
	signals.emit_signal("targets_display_changed", display)


func possible_move(entity_position : Vector2, move : int) -> void:
	board.reset_flood_fill()
	board.flood_fill_check(entity_position, move, [entity_position])
	available_fields = board.flood_fill.duplicate(true)
	display = available_fields.duplicate(true)
	available_fields[entity_position.x][entity_position.y] = false


func reset() -> void:
	board.reset_flood_fill()
	available_fields = board.flood_fill.duplicate(true)
	display = available_fields.duplicate(true)


func attack(position : Vector2, team : int, attack_range : int) -> void:
	board.reset_flood_fill()
	available_fields = board.flood_fill.duplicate(true)
	for i in range(board.get_entity_count()):
		var target : Vector2 = board.get_entity_position(i)
		var diff : Vector2 = Vector2(target.x - position.x, target.y - position.y)
		if (abs(diff.x) + abs(diff.y)) <= attack_range and team != board.get_entity(board.get_entity_index(target))["team"]:
			if diff.x == 0 or diff.y == 0 or abs(diff.x) == abs(diff.y):
				diff.x = clamp(diff.x, -1, 1)
				diff.y = clamp(diff.y, -1, 1)
				var probe : Vector2 = position + diff
				while true:
					if probe == target:
						available_fields[probe.x][probe.y] = true
					if board.get_key(probe, "collision", false):
						break
					probe += diff
				
	display = available_fields
