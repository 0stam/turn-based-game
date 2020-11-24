extends HBoxContainer

export var button : PackedScene


func _ready():
	pass


func add_button(text : String, action : String, mode : String):
	var new_button : Button = button.instance()
	new_button.text = text
	new_button.action = action
	new_button.mode = mode
	add_child(new_button)


func clear():
	for i in get_children():
		i.queue_free()
