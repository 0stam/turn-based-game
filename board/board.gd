extends Control

export var size : Vector2 = Vector2(0, 0)
export var texture_size : int = 128
var resizable = [self] # Nodes requiring resizing on columns/rows count change

onready var fields : GridContainer = $Fields
onready var grid : GridContainer = $Grid
onready var border : NinePatchRect = $Border
onready var signals = Signals


func _ready():
	signals.connect("initialize", self, "initialize_board")
	
	for i in get_children(): # Adding nodes witch need resizing
		resizable.append(i) # If excluding some child would be required, consider blacklist


func initialize_board(size_recieved=Vector2.ZERO) -> void:
	# Picking right size
	if size_recieved != Vector2.ZERO: # If no size was given, use the scipt varables
		if size_recieved == size: # If size didn't change, just reset all graphics
			for i in fields.get_children():
				i.texture_normal = null
			return
		size = size_recieved # If size was changed, proceed with new size
	
	while fields.get_child_count() > 0: # Deleting all fields for sake of creating new ones
		fields.get_child(0).queue_free()
	
	# Setting border size
	var margin : int = int(round(0.06 * texture_size))
	border.patch_margin_bottom = margin
	border.patch_margin_left = margin
	border.patch_margin_right = margin
	border.patch_margin_top = margin
	
	for i in resizable: # Resizing children
		i.rect_min_size = size * texture_size
		i.rect_size = size * texture_size
	
	# Adding field buttons and borders with propper size
	fields.columns = int(size.x)
	grid.columns = int(size.x)
	
	for i in range(size.x * size.y): # Adding buttons/fields
		var button : TextureButton = preload("res://board/button.tscn").instance()
		var field : TextureRect = preload("res://board/field.tscn").instance()
		
		button.rect_min_size = Vector2.ONE * texture_size
		button.rect_size = Vector2.ONE * texture_size
		button.number = i
		
		field.rect_min_size = Vector2.ONE * texture_size
		field.rect_size = Vector2.ONE * texture_size
		
		button.connect("button_pressed", self, "_on_button_pressed")
		fields.add_child(button)
		grid.add_child(field)


func set_field(coordinates : Vector2, graphic : Texture): # Set texture of button at given coordinates
	var field_number : int = int(coordinates.y * fields.columns + coordinates.x)
	fields.get_child(field_number).texture_normal = graphic


func set_border(coordinates : Vector2, color : Color) -> void: # Set color of button's border at given coordinates
	var field_number : int = int(coordinates.y * grid.columns + coordinates.x)
	grid.get_child(field_number).modulate = color


func _on_button_pressed(number : int) -> void:
	signals.emit_signal("field_pressed", Vector2(number % int(size.x), int(number / size.x)))
