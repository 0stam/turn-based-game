extends MarginContainer

onready var signals = Signals


func _ready():
	pass


func _on_Button_pressed():
	signals.emit_signal("turn_passed")
