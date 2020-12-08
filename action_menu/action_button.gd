extends Control

var mode : String = "change" # Controlls if action type is changed or the action is triggered on button press
var text : String = "" setget set_text

export var action : String = ""

onready var button = $Button
onready var signals = Signals


func _ready():
	pass


func _on_Button_pressed():
	signals.emit_signal("action_changed", action)
	if mode == "trigger":
		signals.emit_signal("action_triggered", action)


func set_text(value : String):
	button.text = value
	text = value
