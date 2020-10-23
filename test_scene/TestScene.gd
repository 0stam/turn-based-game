extends Control


onready var board = $HBoxContainer/Board


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Signals.connect("field_pressed", self, "_on_field_pressed")
	make_board()
	


func make_board():
	Signals.emit_signal("initialize", Vector2(7, 5))
	Signals.emit_signal("board_generation_requested", "simple")
	Signals.emit_signal("queue_clear_requested")
	Signals.emit_signal("action_changed", "move")
	$Systems/Board.place_entity()


func _on_field_pressed(cooridinates : Vector2):
	print(cooridinates)


func _on_Button_pressed():
	make_board()


func _on_Button2_pressed():
	pass
