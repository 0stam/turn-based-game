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


func on_current_entity_changed(index : int) -> void:
	current_entity = index


func on_targeting_called(action) -> void:
	if action["target"][0] == "":
		reset()
	else:
		match action["target"][0]:
			"field":
				if "move" in action:
					possible_move(board.get_entity_position(current_entity), action["move"] + 1)
			"entity":
				entity(action)
			_:
				reset()
	signals.emit_signal("targets_changed", available_fields)
	signals.emit_signal("targets_display_changed", display)


func possible_move(entity_position : Vector2, move : int) -> void:
	move += board.get_entity(current_entity)["effects"]["move"][0]
	board.reset_flood_fill()
	board.flood_fill_check(entity_position, move, [entity_position])
	available_fields = board.flood_fill.duplicate(true)
	display = available_fields.duplicate(true)
	available_fields[entity_position.x][entity_position.y] = false


func reset() -> void:
	board.reset_flood_fill()
	available_fields = board.flood_fill.duplicate(true)
	display = available_fields.duplicate(true)


func line_of_sight(pos1 : Vector2, pos2 : Vector2) -> bool:
	var direction = Vector2(clamp(pos2.x - pos1.x, -1, 1), clamp(pos2.y - pos1.y, -1, 1)) # Direction of one step performed during collision check
	if not (direction.x == 0 or direction.y == 0 or abs(direction.x) == abs(direction.y)): # If direction is illegal, return false
		return false
		
	var slant : bool = direction.x == direction.y # Determines necessity of checking addidiotal fields besides the shot path
	var probe : Vector2 = pos1 + direction # Position of currently performed check
	while true:
		if board.get_key(probe, "collision", false) and probe != pos2:
			return false
		if slant:
			if (board.get_key(Vector2(probe.x - direction.x, probe.y), "collision", false) and
				board.get_key(Vector2(probe.x, probe.y - direction.y), "collision", false)):
				return false
		if probe == pos2:
			return true
		probe += direction
	return false


func entity(action):
	board.reset_flood_fill()
	available_fields = board.flood_fill.duplicate(true)
	var pos1 = board.get_entity_position(current_entity)
	for i in range(board.get_entity_count()):
		if current_entity == i and (action["target"][1] == "self" or action["target"][1] == "ally"):
			available_fields[pos1.x][pos1.y] == true
			continue
		
		var teammates : bool = board.get_entity(current_entity)["team"] == board.get_entity(i)["team"]
		if not((action["target"][1] == "") or (action["target"][1] == "ally" and teammates) or
			(action["target"][1] == "enemy" and not teammates)):
			continue
		
		var pos2 = board.get_entity_position(i)
		if abs(pos2.x - pos1.x) + abs(pos2.y - pos1.y) > action["range"]:
			continue
		
		if not line_of_sight(pos1, pos2):
			continue
		
		available_fields[pos2.x][pos2.y] = true
	
	display = available_fields
