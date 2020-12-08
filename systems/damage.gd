extends Node

export(NodePath) var board_path

onready var signals = Signals


func _ready():
	signals.connect("attack_requested", self, "damage")


func damage(target : Dictionary, damage, pierce):
	target["hp"] -= damage - clamp(target["armor"] - pierce, 0, INF)
