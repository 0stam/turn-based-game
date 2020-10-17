extends TextureButton

signal button_pressed(number)

export var number : int = 0 # Should be set by parent during creation


func _ready():
	pass


func _pressed():
	emit_signal("button_pressed", number)
