extends HBoxContainer

export var button : PackedScene # Variable holding scene which should be instanced as a new button


func _ready():
	pass


func add_button(text : String, action : String, mode : String, cost : int, usage_limit : int): # Instancing new button
	var new_button = button.instance()
	add_child(new_button)
	new_button.text = text
	new_button.action = action
	new_button.mode = mode
	new_button.cost = cost
	new_button.usage_limit = usage_limit


func clear(): # Removes all children
	for i in get_children():
		remove_child(i)


func refresh_buttons(ap : int, actions_usages : Dictionary):
	for i in get_children():
		i.check_for_availability(ap, actions_usages)
