extends Node

export(NodePath) var board_path

onready var signals = Signals
onready var board = get_node(board_path)


func _ready():
	signals.connect("attack_requested", self, "damage")
	signals.connect("regeneration_requested", self, "regenerate")
	signals.connect("effects_addition_requested", self, "add_effects")


func damage(target_index : int, damage, pierce) -> void:
	var target : Dictionary = board.get_entity(target_index)
	if target["effects"]["hp"][0] > damage:
		target["effects"]["hp"][0] -= damage
	else:
		damage -= target["effects"]["hp"][0]
		target["hp"] -= clamp(damage - clamp((target["armor"] + target["effects"]["armor"][0]) - pierce, 0, INF), 0, INF)
		if target["hp"] <= 0:
			board.remove_entity(target_index)


func regenerate(target_index : int, regeneration : int) -> void:
	var target : Dictionary = board.get_entity(target_index)
	target["hp"] = clamp(target["hp"] + regeneration, 0, target["max_hp"])


func add_effects(target_index : int, effects : Dictionary):
	var target : Dictionary = board.get_entity(target_index)["effects"]
	for i in effects.keys():
		if (target[i][0] * target[i][1] < effects[i][0] * effects[i][1] or
			(target[i][0] * target[i][1] == effects[i][0] * effects[i][1] and target[i][0] < effects[i][0])):
			target[i] = effects[i].duplicate(true)
