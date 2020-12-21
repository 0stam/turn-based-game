extends Node

export(NodePath) var board_path

onready var signals = Signals
onready var board = get_node(board_path)


func _ready():
	signals.connect("attack_requested", self, "damage")
	signals.connect("regeneration_requested", self, "regenerate")


func damage(target_index : int, damage, pierce) -> void:
	var target : Dictionary = board.get_entity(target_index)
	if target["effects"]["hp"][0] > damage:
		target["effects"]["hp"][0] -= damage
	else:
		damage -= target["effects"]["hp"][0]
		target["hp"] -= clamp(damage - clamp((target["armor"] + target["effects"]["armor"][0]) - pierce, 0, INF), 0, INF)
		if target["hp"] <= 0:
			board.remove_entity(target_index)


func regenerate(target : Dictionary, regeneration : int) -> void:
	target["hp"] = clamp(target["hp"] + regeneration, 0, target["max_hp"])
