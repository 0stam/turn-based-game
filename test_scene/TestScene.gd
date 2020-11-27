extends Control

onready var board = $HBoxContainer/Board


func _ready():
	randomize()
	make_board()


func make_board():
	board.texture_size = 128
	Signals.emit_signal("initialize", Vector2(7, 5))
	Signals.emit_signal("board_generation_requested", "simple")
	Signals.emit_signal("queue_clear_requested")
	$Systems/Board.place_entity()
	Signals.emit_signal("action_changed", "move")
