extends Node2D

@onready var tilemap = $TileMap
@export var borders = Rect2(1,1,100,62)
var walker
var map

var ground_layer = 0


func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker_room.new(Vector2(3,5), borders)
	map = walker.walk(600) # потестить
	
	var using_cells: Array = []
	var all_cells: Array = tilemap.get_used_cells(ground_layer)
	tilemap.clear()
	walker.queue_free()
	
	for tile in all_cells:
		if !map.has(Vector2(tile.x, tile.y)):
			using_cells.append(tile)
	tilemap.set_cells_terrain_connect(ground_layer,using_cells, ground_layer, ground_layer,false)
	tilemap.set_cells_terrain_path(ground_layer,using_cells, ground_layer, ground_layer,false)
	

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
