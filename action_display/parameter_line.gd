extends HBoxContainer

var parameter : String setget set_parameter
var value : String setget set_value

onready var name_label : Label = $Name
onready var value_label : Label = $Value

func _ready():
	pass


func set_parameter(val : String):
	parameter = val
	name_label.text = val


func set_value(val : String):
	value = val
	value_label.text = val
