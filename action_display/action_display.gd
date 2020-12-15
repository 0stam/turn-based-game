extends MarginContainer

export(PackedScene) var parameter_line_path

onready var default_info : Label = $Margin/VBoxContainer/Default
onready var parameter_list : VBoxContainer = $Margin/VBoxContainer


func _ready():
	pass


func clear():
	for i in parameter_list.get_children():
		if i != default_info:
			parameter_list.remove_child(i)
	default_info.show()


func add_parameter(parameter : String, value : String):
	var parameter_line : HBoxContainer = parameter_line_path.instance()
	parameter_list.add_child(parameter_line)
	parameter_line.parameter = parameter
	parameter_line.value = value
	default_info.hide()
