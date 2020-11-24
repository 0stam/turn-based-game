extends Button

var mode : String = "change" # Controlls if action type is changed or the action is triggered on button press

export var action : String = ""

onready var signals = Signals


func _ready():
	pass


func _on_Button_pressed():
	match mode:
		"change":
			signals.emit_signal("action_changed", action)
		"trigger":
			signals.emit_signal("action_triggered", action)
