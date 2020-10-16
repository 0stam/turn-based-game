extends Node

var objects : Dictionary = {}
var board : Array = []

export(String) var json_list : String


func _ready():
	parse_data()
	Signals.connect("initialize", self, "initialize_board")
	Signals.connect("board_generation_requested", self, "generate_board")


func parse_object(file_name : String):
	var file : File = File.new()
	file.open("res://data/".plus_file(file_name), File.READ)
	return parse_json(file.get_as_text())


func parse_data():
	var json_list_file : File = File.new()
	json_list_file.open("res://data/".plus_file(json_list), File.READ)
	var json_refference_list : Dictionary = parse_json(json_list_file.get_as_text())
	
	for i in json_refference_list["objects"]:
		i = parse_object(i)
		objects[i["id"]] = i


func initialize_board(size : Vector2, reset:=true):
	if reset:
		board = []
	for i in range(size.y):
		board.append([])
		for _j in range(size.x):
			board[i].append({})

func generate_board():
	# TODO: Write real generator
	var smaller : int
	if len(board) > len(board[0]):
		smaller = len(board[0])
	else:
		smaller = len(board)
	for i in range(smaller):
		board[i][i] = objects["wall"].duplicate()
	Signals.emit_signal("board_changed")
