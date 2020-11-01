extends Node

export(NodePath) var board_data_path
export(NodePath) var board_path
export(NodePath) var entity_panel_path

onready var board_data = get_node(board_data_path)
onready var board = get_node(board_path)
onready var entity_panel = get_node(entity_panel_path)
onready var signals = Signals

var graphics = {}


func _ready():
	signals.connect("board_changed", self, "update_board")
	signals.connect("queue_clear_requested", self, "clear_entities")
	signals.connect("entity_added", self, "on_entity_added")
	signals.connect("current_entity_changed", self, "on_current_entity_changed")


func get_graphic(name : String):
	if not name in graphics:
		graphics[name] = load("res://art/".plus_file(name))
	return graphics[name]


func update_board():
	for i in range(len(board_data.board[0])):
		for j in range(len(board_data.board[0][i])):
			if board_data.get_key(Vector2(i, j), "graphic") != null:
				board.set_field(Vector2(i, j), get_graphic(board_data.get_key(Vector2(i, j), "graphic")))
			else:
				board.set_field(Vector2(i, j), null)


func clear_entities():
	entity_panel.clear_entities()


func on_entity_added(index : int):
	var entity : Dictionary = board_data.get_entity(index)
	entity_panel.add_entity(entity["id"], str(entity["hp"]), str(entity["ap"]), board_data.get_entity_count() == 1)


func on_current_entity_changed(index : int):
	entity_panel.set_active(index)
