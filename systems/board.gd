extends Node

var objects : Dictionary = {}
var generators : Dictionary = {}
var board : Array = []

export(String) var json_list : String

onready var signals = Signals


func _ready():
	parse_data() # Read all json data
	signals.connect("initialize", self, "initialize_board")
	signals.connect("board_generation_requested", self, "generate_board")


func parse_object(file_name : String) -> Dictionary: # Function for reading single json file
	var file : File = File.new()
	file.open("res://data/".plus_file(file_name), File.READ)
	return parse_json(file.get_as_text())


func parse_data() -> void: # Read all json data
	# Parse list of json files containing game data
	var json_list_file : File = File.new()
	json_list_file.open("res://data/".plus_file(json_list), File.READ)
	var json_refference_list : Dictionary = parse_json(json_list_file.get_as_text())
	
	# Read individual data categories
	for i in json_refference_list["objects"]:
		i = parse_object(i)
		objects[i["id"]] = i
	for i in json_refference_list["generators"]:
		i = parse_object(i)
		generators[i["id"]] = i


func initialize_board(size : Vector2, reset:=true) -> void: # Fill board with empty dictionaries
	if reset:
		board = []
	for i in range(size.y):
		board.append([])
		for _j in range(size.x):
			board[i].append({})


func generate_board(name : String) -> void:
	var field_count = len(board) * len(board[0]) # Number of fields present on the board
	for object in generators[name]["objects"]: # For every object type to be generated
		var quantity : float = 0 # Variable storing how many of that object should be generated
		
		# Qantity is table following rule [a, b, c] = a*q^2+b*q+c and so on, where q is field_count
		for i in range(len(object["quantity"])):
			quantity += pow(field_count, i) * object["quantity"][-i - 1]
		
		quantity = clamp(quantity, 0, field_count) # Clamping quantity to valid values
		match object["round"]: # Applying requested type of rounding to int
			"math":
				quantity = round(quantity)
			"down":
				quantity = floor(quantity)
			"up":
				quantity = ceil(quantity)
		
		# Putting objects on board: ff field is empty, place object, else try again
		while quantity > 0:
			var field_coordinates = Vector2(randi() % len(board), randi() % len(board[0]))
			if board[field_coordinates.x][field_coordinates.y].hash() == {}.hash():
				board[field_coordinates.x][field_coordinates.y] = objects[object["id"]].duplicate()
				quantity -= 1
	
	signals.emit_signal("board_changed")
