extends Node

export(NodePath) var board_data_path
export(NodePath) var board_path

onready var board_data = get_node(board_data_path)
onready var board = get_node(board_path)

var graphics = {}


func _ready():
	Signals.connect("board_changed", self, "update_board")


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
