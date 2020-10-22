extends Node

# Variables keeping parsed json data
var objects : Dictionary = {}
var generators : Dictionary = {}

var board : Array = [] # Actual board array
var flood_fill : Array = [] # Required for flood fill to work

export(String) var json_list : String # Name of file containing all json files paths

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
	flood_fill = [] # Also reset the flood fill array
	for i in range(size.x):
		board.append([])
		flood_fill.append([])
		for _j in range(size.y):
			board[i].append({})
			flood_fill[i].append(false)


func flood_fill_check(position : Vector2) -> void: # Performing flood fill on board
	# If position.x and y are valid board indexes
	if len(board) > position.x and position.x >= 0 and len(board[0]) > position.y and position.y >= 0:
		if not flood_fill[position.x][position.y]: # If this field wasn't processed previously.
			if not get_key(position, "collision", false): # If there is no collision here
				flood_fill[position.x][position.y] = true # Mark this field as processed
				for i in range(-1, 2, 2): # Perform same operation for neighbouring fields
					flood_fill_check(position + Vector2(i, 0))
					flood_fill_check(position + Vector2(0, i))
		


func check_for_unreachable():
	# Finding first empty field
	var start : Vector2 = Vector2.ZERO
	var exit : bool = false # Indicates need of breaking outer loop
	for i in range(len(board)):
		for j in range(len(board[0])):
			if not get_key(Vector2(i, j), "collision", false):
				start = Vector2(i, j)
				exit = true
				break
		if exit:
			break
	
	flood_fill_check(start) # Performing flood fill
	
	for i in range(len(board)): # Checking if some empty field wasn't filled
		for j in range(len(board[0])):
			if get_key(Vector2(i, j), "collision", false) != (not flood_fill[i][j]):
				return false # If so, returning false
	print("DEBUG: true")
	return true # Else returning true


func generate_board(name : String) -> void:
	while true:
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
			
			# Putting objects on board: if field is empty, place object, else try again
			while quantity > 0:
				var field_coordinates = Vector2(randi() % len(board), randi() % len(board[0]))
				if board[field_coordinates.x][field_coordinates.y].hash() == {}.hash():
					board[field_coordinates.x][field_coordinates.y] = objects[object["id"]].duplicate()
					quantity -= 1
		if check_for_unreachable(): # If map is alright, proceed
			break
		else: # If some empty field cannot be accessed (eg. map is split), try again
			initialize_board(Vector2(len(board), len(board[0])))
	signals.emit_signal("board_changed")


func get_key(position : Vector2, key : String, default): # Used for getting same key from board
	if board[position.x][position.y].has(key):
		return board[position.x][position.y][key]
	else:
		return default


func has_collision(position : Vector2) -> bool:
	return get_key(position, "collision", false)


func get_graphic(position : Vector2):
	return get_key(position, "graphic", null)
