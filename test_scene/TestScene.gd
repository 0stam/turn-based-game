extends Control

onready var board = $HBoxContainer/Board

var board_size : Vector2 = Vector2(3, 3)


func _ready():
	randomize()
	make_board(board_size)


func make_board(size : Vector2):
	var texture_size = 0
	var screen_width : int = get_viewport().size.x
	print(screen_width)
	while (texture_size + 64) * size.x + 760 <= screen_width:
		texture_size += 64
	board.texture_size = texture_size
	Signals.emit_signal("initialize", size)
	Signals.emit_signal("board_generation_requested", "simple")
	Signals.emit_signal("queue_clear_requested")
	$Systems/Board.place_entity()
	yield(get_tree().create_timer(0.1), "timeout")
	print($HBoxContainer/VBoxContainer/ActionDisplay.rect_size)
