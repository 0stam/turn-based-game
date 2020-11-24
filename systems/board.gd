extends Node

# Variables keeping parsed json data
var data : Node
var objects : Dictionary = {}
var generators : Dictionary = {}
var entities : Dictionary = {}

var board : Array = [[], []] # Actual board array
var flood_fill : Array = [] # Required for flood fill to work
var entity_list : Array = [] # List of all entities positions, required for "get_entity" to work

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
	for i in range(size.x):
		board[0].append([])
		board[1].append([])
		for _j in range(size.y):
			board[0][i].append({})
			board[1][i].append({})


func reset_flood_fill():
	# Reseting flood fill array
	flood_fill = []
	for i in range(len(board[0])):
		flood_fill.append([])
		for _j in range(len(board[0][i])):
			flood_fill[i].append(false)


# Function serving two purposes: map generation and checking if move is legal. Consider splitting.
func flood_fill_check(position : Vector2, steps_left=-1, ignore=[]) -> void: # Performing flood fill on board
	# Mechanic used when checking if field is accesable
	if steps_left != -1:
		if steps_left == 0:
			return
		steps_left -= 1
	
	# If position.x and y are valid board indexes
	if len(board[0]) > position.x and position.x >= 0 and len(board[0][0]) > position.y and position.y >= 0:
		if not flood_fill[position.x][position.y] or steps_left != -1: # If this field wasn't processed previously.
			if not get_key(position, "collision", false) or ignore.has(position): # If there is no collision here
				flood_fill[position.x][position.y] = true # Mark this field as processed
				for i in range(-1, 2, 2): # Perform same operation for neighbouring fields
					flood_fill_check(position + Vector2(i, 0), steps_left)
					flood_fill_check(position + Vector2(0, i), steps_left)
		


func check_for_unreachable():
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
				var field_coordinates = Vector2(randi() % len(board[0]), randi() % len(board[0][0]))
				if board[0][field_coordinates.x][field_coordinates.y].hash() == {}.hash():
					board[0][field_coordinates.x][field_coordinates.y] = objects[object["id"]].duplicate(true)
					quantity -= 1
		if check_for_unreachable(): # If map is alright, proceed
			break
		else: # If some empty field cannot be accessed (eg. map is split), try again
			initialize_board(Vector2(len(board[0]), len(board[0][0])))
	signals.emit_signal("board_changed")


func place_entity():
	var end : bool = false
	for i in range(len(board[0])):
		for j in range(len(board[0][i])):
			if not get_key(Vector2(i, j), "collision", false):
				board[1][i][j] = entities["red_dot"]
				entity_list.append(Vector2(i, j))
				signals.emit_signal("entity_added", len(entity_list) - 1)
				end = true
				break
		if end:
			break
	end = false
	for i in range(len(board[0]) - 1, -1, -1):
		for j in range(len(board[0][i]) - 1, -1, -1):
			if not get_key(Vector2(i, j), "collision", false):
				board[1][i][j] = entities["red_dot"]
				entity_list.append(Vector2(i, j))
				signals.emit_signal("entity_added", len(entity_list) - 1)
				end = true
				break
		if end:
			break
	signals.emit_signal("queue_shuffle_requested")
	signals.emit_signal("board_changed")


func get_key(position : Vector2, key : String, default=null): # Used for getting same key from board
	if board[1][position.x][position.y].has(key):
		return board[1][position.x][position.y][key]
	if board[0][position.x][position.y].has(key):
		return board[0][position.x][position.y][key]
	return default


func move(from : Vector3, target : Vector3): # Moves object from from to target position
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


func clear_entities():
	entity_list = []
