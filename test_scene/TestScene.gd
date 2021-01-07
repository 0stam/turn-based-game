extends Control

onready var board = $HBoxContainer/Board

var board_size : Vector2 = Vector2(8, 7)


func _ready():
	randomize()
	make_board(board_size)
	yield(get_tree().create_timer(0.0000000001), "timeout")
	rect_size = get_viewport().size


func make_board(size : Vector2):
	var screen_size : Vector2 = get_viewport().size
	var max_size = Vector2((screen_size.x - 720) / board_size.x, screen_size.y / board_size.y)
	if max_size.x < max_size.y:
		board.texture_size = max_size.x
	else:
		board.texture_size = max_size.y
	Signals.emit_signal("initialize", size)
	Signals.emit_signal("board_generation_requested", "simple")
	Signals.emit_signal("queue_clear_requested")
	$Systems/Board.place_entity()
