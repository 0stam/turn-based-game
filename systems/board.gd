extends Node

# Variables keeping parsed json data
var data : Node
var objects : Dictionary = {}
var generators : Dictionary = {}
var entities : Dictionary = {}

var board : Array = [[], []] # Actual board array
var flood_fill : Array = [] # Required for flood fill to work
var entity_list : Array = [] # List of all entities positions, required for "get_entity" to work
var object_list : Array = [] # List of objects requiring control of the objects system
var entity_temp : Dictionary = {"ap": 0, "actions_usages": {}} # Variables storing temporary entity variables
var position_blacklist : Array = [] # List of positions which should be left empty during board generation

export var data_path : NodePath

onready var signals = Signals


func _ready():
	signals.connect("initialize", self, "initialize_board")
	signals.connect("board_generation_requested", self, "generate_board")
	signals.connect("queue_clear_requested", self, "clear_entities")
	data = get_node(data_path)
	objects = data.objects
	generators = data.generators
	entities = data.entities
	


func initialize_board(size : Vector2, reset:=true) -> void: # Fill board with empty dictionaries
	if reset:
		board = [[], []]
		position_blacklist = []
	for i in range(size.x):
		board[0].append([])
		board[1].append([])
		for _j in range(size.y):
			board[0][i].append({})
			board[1][i].append({})
	position_blacklist += [Vector2(0, 0), Vector2(0, size.y - 1), Vector2(size.x - 1, 0), Vector2(size.x - 1, size.y - 1)]


func reset_flood_fill() -> void:
	# Reseting flood fill array
	flood_fill = []
	for i in range(len(board[0])):
		flood_fill.append([])
		for _j in range(len(board[0][i])):
			flood_fill[i].append(false)


# Function serving two purposes: map generation and checking if move/other action is legal. Consider splitting.
func flood_fill_check(position : Vector2, steps_left=-1, ignore=[]) -> void: # Performing flood fill on board
	if steps_left != -1: # If checking for the whole map, ignore this code, else decrement number of steps left
		if steps_left == 0:
			return
		steps_left -= 1
	
	# If position.x and y are valid board indexes
	if len(board[0]) > position.x and position.x >= 0 and len(board[0][0]) > position.y and position.y >= 0:
		if not flood_fill[position.x][position.y] or steps_left != -1: # If this field wasn't processed previously
			if not get_key(position, "collision", false) or ignore.has(position): # If there is no collision here
				flood_fill[position.x][position.y] = true # Mark this field as processed
				for i in range(-1, 2, 2): # Perform the same operation for neighbouring fields
					flood_fill_check(position + Vector2(i, 0), steps_left)
					flood_fill_check(position + Vector2(0, i), steps_left)
		


func check_for_unreachable() -> bool:
	# Finding first empty field
	var start : Vector2 = Vector2.ZERO
	var exit : bool = false # Indicates need of breaking outer loop
	for i in range(len(board[0])):
		for j in range(len(board[0][0])):
			if not get_key(Vector2(i, j), "collision", false):
				start = Vector2(i, j)
				exit = true
				break
		if exit:
			break
	
	reset_flood_fill()
	flood_fill_check(start) # Performing flood fill
	
	for i in range(len(board[0])): # Checking if some empty field wasn't filled
		for j in range(len(board[0][0])):
			if get_key(Vector2(i, j), "collision", false) != (not flood_fill[i][j]):
				print("INFO: map is incorect")
				return false # If so, returning false
	print("INFO: map is correct")
	return true # Else returning true


func generate_board(name : String) -> void:
	while true:
		var field_count = len(board[0]) * len(board[0][0]) # Number of fields present on the board
		for object in generators[name]["objects"]: # For every object type to be generated
			var quantity : float = 0 # Variable storing how many of that object should be generated
			
			# Qantity is table following rule [a, b, c] = a*q^2+b*q+c and so on, where q is field_count
			for i in range(len(object["quantity"])):
				quantity += pow(field_count, i) * object["quantity"][-i - 1]
			
			quantity = clamp(quantity, 0, field_count - len(position_blacklist)) # Clamping quantity to valid values
			match object["round"]: # Applying requested type of rounding to int
				"math":
					quantity = round(quantity)
				"down":
					quantity = floor(quantity)
				"up":
					quantity = ceil(quantity)
			
			# Putting objects on board: if field is empty place object, else try again
			while quantity > 0:
				var field_coordinates = Vector2(randi() % len(board[0]), randi() % len(board[0][0]))
				if board[0][field_coordinates.x][field_coordinates.y].hash() == {}.hash() and not field_coordinates in position_blacklist:
						board[0][field_coordinates.x][field_coordinates.y] = objects[object["id"]].duplicate(true)
						quantity -= 1
		if check_for_unreachable(): # If map is alright, proceed
			break
		else: # If some empty field cannot be accessed (eg. map is split), try again
			initialize_board(Vector2(len(board[0]), len(board[0][0])))
	# Checking for objects which need to be registered for the object system
	for i in len(board[0]):
		for j in len(board[0][i]):
			if "object" in board[0][i][j]:
				object_list.append(Vector2(i, j))
				signals.emit_signal("object_added", len(object_list) - 1)
	signals.emit_signal("board_changed")


func place_entity() -> void:
	board[1][0][0] = entities["red_dot"].duplicate(true)
	board[1][0][0]["team"] = 0
	entity_list.append(Vector2(0, 0))
	signals.emit_signal("entity_added", 0)
	
	board[1][len(board[0]) - 1][len(board[0][0]) - 1] = entities["blue_dot"].duplicate(true)
	board[1][len(board[0]) - 1][len(board[0][0]) - 1]["team"] = 1
	entity_list.append(Vector2(len(board[0]) - 1, len(board[0][0]) - 1))
	signals.emit_signal("entity_added", 1)
	
	board[1][0][len(board[0][0]) - 1] = entities["trooper"].duplicate(true)
	board[1][0][len(board[0][0]) - 1]["team"] = 2
	entity_list.append(Vector2(0, len(board[0][0]) - 1))
	signals.emit_signal("entity_added", 2)
	
	board[1][len(board[0]) - 1][0] = entities["knight"].duplicate(true)
	board[1][len(board[0]) - 1][0]["team"] = 2
	entity_list.append(Vector2(len(board[0]) - 1, 0))
	signals.emit_signal("entity_added", 3)
	
	signals.emit_signal("queue_shuffle_requested")
	signals.emit_signal("board_changed")


func get_key(position : Vector2, key : String, default=null): # Used for getting key from board
	if board[1][position.x][position.y].has(key):
		return board[1][position.x][position.y][key]
	if board[0][position.x][position.y].has(key):
		return board[0][position.x][position.y][key]
	return default


func move(from : Vector3, target : Vector3) -> void: # Moves object from from to target position
	if not get_key(Vector2(target.y, target.z), "collision", false):
		board[target.x][target.y][target.z] = board[from.x][from.y][from.z].duplicate()
		board[from.x][from.y][from.z] = {}
		if from.x == 1:
			for i in range(len(entity_list)):
				if entity_list[i] == Vector2(from.y, from.z):
					entity_list[i] = Vector2(target.y, target.z)
					break
		signals.emit_signal("board_changed")
	else:
		print("***TRIED MOVING TO FIELD WITH COLLISION***")


func get_entity(index : int) -> Dictionary:
	return board[1][entity_list[index].x][entity_list[index].y]


func get_entity_count() -> int:
	return len(entity_list)


func get_entity_position(index : int) -> Vector2:
	return entity_list[index]


func clear_entities() -> void:
	entity_list = []


func get_entity_index(position : Vector2) -> int: # Returns the index of an entity on a given position
	for i in range(len(entity_list)):
		if entity_list[i] == position:
			return i
	return -1


func remove_entity(index : int) -> void:
	board[1][entity_list[index].x][entity_list[index].y] = {}
	entity_list.remove(index)
	signals.emit_signal("entity_removed", index)
	signals.emit_signal("board_changed")


func get_object(index : int) -> Dictionary:
	return board[0][object_list[index].x][object_list[index].y]


func get_object_count() -> int:
	return len(object_list)


func get_object_index(position : Vector2) -> int:
	for i in len(object_list):
		if object_list[i] == position:
			return i
	return -1


func remove_object(index : int):
	board[0][object_list[index].x][object_list[index].y] = {}
	object_list.remove(index)
	signals.emit_signal("board_changed")


func replace_object(index : int):
	var object : Dictionary = board[0][object_list[index].x][object_list[index].y]
	while true: # Find random coordinates pointing to an empty field
		var x : int = int(rand_range(0, len(board[0])))
		var y : int = int(rand_range(0, len(board[0][x])))
		if board[0][x][y].hash() == {}.hash() and board[1][x][y].hash() == {}.hash(): # If the field is empty
			board[0][x][y] = object # Put current object there
			board[0][object_list[index].x][object_list[index].y] = {} # Remove old object from board
			object_list[index] = Vector2(x, y) # Update object_list reference
			break
	signals.emit_signal("board_changed")
	
