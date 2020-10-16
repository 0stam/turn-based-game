extends Node

export(NodePath) var board_data_path
export(NodePath) var board_path

onready var board_data = get_node(board_data_path)
onready var board = get_node(board_path)


func _ready():
	Signals.connect("board_changed", self, "update_board")


func update_board():
	for i in range(len(board_data.board)):
		for j in range(len(board_data.board[i])):
			if board_data.board[i][j].has("graphic"):
				board.set_field(Vector2(j, i), load("res://art/".plus_file(board_data.board[i][j]["graphic"])))
