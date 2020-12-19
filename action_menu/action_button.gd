extends Control

var mode : String = "change" # Controlls if action type is changed or the action is triggered on button press
var text : String = "" setget set_text
var cost : int = 0 # Cost in AP, button should be "disabled" when there isn't enough ap
var usage_limit : int = 0 # Button should be "disabled" if the given action was used to many times
var color : Color # Current UI color based on an active character
var selected : bool = false
var available : bool = true

export var action : String = ""

onready var button = $Button
onready var signals = Signals


func _ready():
	signals.connect("action_changed", self, "on_action_changed")
	signals.connect("action_succeeded", self, "on_action_succeeded")


func _on_Button_pressed():
	signals.emit_signal("action_changed", action)
	if mode == "trigger":
		signals.emit_signal("action_triggered", action)


func set_text(value : String):
	button.text = value
	text = value


func check_for_availability(ap : int, action_usages : Dictionary):
	available = ap >= cost and action_usages[action] > 0
	update_graphics()


func on_action_changed(action : String):
	selected = action == self.action
	update_graphics()


func update_graphics(): # Update graphics according to the selected and available variables
	if selected:
		modulate = color
	else:
		modulate = Color(1, 1, 1)
	if available:
		modulate.a = 1
	else:
		modulate.a = 0.7


func on_action_succeeded():
	selected = false
	update_graphics()
