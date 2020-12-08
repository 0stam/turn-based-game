extends HBoxContainer

# TODO: rewrite to actually store values and add HP and AP prefixes to labels
var entity_name : String = "" setget set_name
var hp : String = "" setget set_hp
var ap : String = "" setget set_ap
var color : String = "" setget set_color

var active : bool = true setget set_active

onready var name_label : Label = $Name
onready var hp_label : Label = $HP
onready var ap_label : Label = $AP


func _ready():
	pass


func set_name(text : String):
	entity_name = text
	name_label.text = text


func set_hp(text : String):
	hp = text
	hp_label.text = "HP: " + text


func set_ap(text : String):
	ap = text
	ap_label.text = "AP: " + text


func set_active(value : bool):
	active = value
	if value:
		modulate.a = 1
	else:
		modulate.a = 0.4


func set_color(value : String):
	color = value
	modulate = color
	set_active(active)
