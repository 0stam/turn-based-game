extends Node

export(NodePath) var board_path

onready var signals = Signals


func _ready():
	signals.connect("attack_requested", self, "damage")
	signals.connect("regeneration_requested", self, "regenerate")


func damage(target : Dictionary, damage, pierce) -> void:
	if target["effects"]["hp"][0] > damage:
		target["effects"]["hp"][0] -= damage
	else:
		damage -= target["effects"]["hp"][0]
		target["hp"] -= clamp(damage - clamp((target["armor"] + target["effects"]["armor"][0]) - pierce, 0, INF), 0, INF)


func regenerate(target : Dictionary, regeneration : int) -> void:
	target["hp"] = clamp(target["hp"] + regeneration, 0, target["max_hp"])
