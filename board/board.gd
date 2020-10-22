extends Control


# Texture names for graphics. Used when using given texture from different resolution folder
var textures_path = "res://board/art"
var textures = {
	"field": "field.png",
}

export var size : Vector2 = Vector2(6, 6)
export var texture_size : int = 128
var resizable = [self] # Nodes requiring resizing on columns/rows count change
var initialized = false

onready var fields : GridContainer = $Fields
onready var grid : TextureRect = $Grid
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
	
	# Loading sized textures
	grid.texture = load(textures_path.plus_file(texture_size).plus_file(textures["field"]))
	
	# Setting border size
	var margin : int = round(0.06 * texture_size)
	border.patch_margin_bottom = margin
	border.patch_margin_left = margin
	border.patch_margin_right = margin
	border.patch_margin_top = margin
	
	for i in resizable: # Resizing children
		i.rect_min_size = size * texture_size
		i.rect_size = size * texture_size
	
	fields.columns = int(size.x)
	
	for i in range(size.x * size.y): # Adding buttons/fields
		var button : TextureButton = preload("res://board/button.tscn").instance()
		button.rect_min_size = Vector2.ONE * texture_size
		button.rect_size = Vector2.ONE * texture_size
		button.number = i
		button.connect("button_pressed", self, "_on_button_pressed")
		fields.add_child(button)


func set_field(coordinates : Vector2, graphic : Texture) -> bool:
	var field_number : int = int(coordinates.y * fields.columns + coordinates.x)
	if field_number >= fields.get_child_count():
		return false
	fields.get_child(field_number).texture_normal = graphic
	return true


func _on_button_pressed(number : int) -> void:
	signals.emit_signal("field_pressed", Vector2(number % int(size.x), int(number / size.x)))
