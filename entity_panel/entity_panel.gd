extends VBoxContainer

var entity_list : Array = [] # Ensures that nodes different than rows don't interrupt setting active row 

export var entity_row : PackedScene

onready var signals = Signals


func _ready():
	pass


func add_entity(entity_name : String, hp : String, ap : String, active : bool, color : String):
	var entity : HBoxContainer = entity_row.instance()
	entity_list.append(entity)
	add_child(entity)
	entity.entity_name = entity_name
	entity.hp = hp
	entity.ap = ap
	entity.active = active
	entity.color = color


func remove_entity(index : int):
	remove_child(get_child(index))


func clear_entities():
	entity_list = []
	for i in get_children():
		i.queue_free()


func set_active(index : int):
	for i in range(len(entity_list)):
		entity_list[i].active = i == index


func modify(index : int, variable : String, value : String):
	match variable:
		"name": get_children()[index].entity_name = value
		"hp": get_children()[index].hp = value
		"ap": get_children()[index].ap = value
