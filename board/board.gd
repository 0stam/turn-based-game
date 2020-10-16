extends Control


var textures_path = "res://board/art"
var textures = {
	"field": "field.png",
	"border": "border.png",
}

export var size : Vector2 = Vector2(6, 6)
export var texture_size : int = 64
var resizable = [self] # Nodes requiring resizing on columns/rows count change

onready var fields : GridContainer = $Fields
onready var grid : TextureRect = $Grid
onready var border : NinePatchRect = $Border
onready var signals = Signals


func _ready():
	signals.connect("initialize", self, "initialize")
	
	for i in get_children(): # Adding nodes witch need resizing
		resizable.append(i) # If excluding some child would be required, consider blacklist


func initialize(size_recieved=Vector2.ZERO):
	if size_recieved != Vector2.ZERO:
		size = size_recieved
		
	grid.texture = load(textures_path.plus_file(texture_size).plus_file(textures["field"])) # Loading sized texture
	border.texture = load(textures_path.plus_file(texture_size).plus_file(textures["border"]))
	
	for i in resizable: # Resizing children
		i.rect_min_size = size * texture_size
		i.rect_size = size * texture_size
	
	fields.columns = int(size.y)
	
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


func _on_button_pressed(number : int):
	signals.emit_signal("field_pressed", Vector2(number % int(size.x), int(number / size.x)))
