extends HBoxContainer

export var button : PackedScene # Variable holding scene which should be instanced as a new button


func _ready():
	pass


func add_button(text : String, action : String, mode : String): # Instancing button and assigning it proper values
	var new_button : Button = button.instance()
	new_button.text = text
	new_button.action = action
	new_button.mode = mode
	add_child(new_button)


func clear(): # Removes all children
	for i in get_children():
		remove_child(i)
