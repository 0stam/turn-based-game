extends Node

var objects : Dictionary = {}
var generators : Dictionary = {}
var entities : Dictionary = {}

export var json_list : String


func _ready():
	parse_data()


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
	for i in json_refference_list["entities"]:
		i = parse_object(i)
		entities[i["id"]] = i
