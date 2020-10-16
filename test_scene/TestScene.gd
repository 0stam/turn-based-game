extends Control


onready var board = $HBoxContainer/Board


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("field_pressed", self, "_on_field_pressed")
	Signals.emit_signal("initialize", Vector2(7, 7))
	Signals.emit_signal("board_generation_requested")
	


func _on_field_pressed(cooridinates : Vector2):
	print(cooridinates)
