extends MarginContainer

var signals = Signals


func _ready():
	pass


func _on_Button_pressed(): # When pressed, triggers currently selected action
	signals.emit_signal("action_triggered")
