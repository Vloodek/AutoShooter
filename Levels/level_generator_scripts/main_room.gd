extends Node2D

@onready var exit_scene = preload("res://Interactables/scenes/exit.tscn")
@onready var player_scene = preload("res://Entities/Scenes/Player/player.tscn")
@onready var enemy_scene = preload("res://Entities/Scenes/Enemies/enemy_1.tscn")

@onready var tilemap = $TileMap
@onready var ground = $ground


@export var borders = Rect2(1,1,100,52)
var walker
var map

var ground_layer = 0

func _ready():
	randomize()
	generate_level()

func generate_level():
	walker = Walker_room.new(Vector2(3,5), borders)
	map = walker.walk(800) # потестить
	var using_cells: Array = []
	var all_cells: Array = tilemap.get_used_cells(ground_layer)
	tilemap.clear()
	walker.queue_free()
	for tile in all_cells:
		if !map.has(Vector2(tile.x, tile.y)):
			using_cells.append(tile)
			ground.set_cell(0,Vector2i(tile.x, tile.y), 2,Vector2i(3,4)) # Заготовленная плитка ставится на тайлмап ground
	tilemap.set_cells_terrain_connect(ground_layer,using_cells, ground_layer, ground_layer,false)
	tilemap.set_cells_terrain_path(ground_layer,using_cells, ground_layer, ground_layer,false)
	
	
	instance_exit()
	instance_player()
	instance_enemy()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

var player_pos = null
func instance_player():
	var player = player_scene.instantiate()
	add_child(player)
	
	player.position = map.pop_front() * 16
	print(player.position)
	player_pos = player.position
func instance_exit():
	var exit = exit_scene.instantiate()

	add_child(exit)
	exit.position = walker.get_end_room().position * 16

#func instance_enemy():
	#for i in range(12):
		#var enemy = enemy_scene.instantiate()
		#enemy.position = (map.pick_random() * borders.position) * 16
		#add_child(enemy)

func instance_enemy():
	var player_position = player_pos # Предположим, что позиция игрока доступна через узел $Player
	var player_detection_radius = 300 # Условный радиус обнаружения игрока для врагов
	
	for i in range(12):
		var enemy_spawned = false
		var enemy_position = Vector2.ZERO
		
		while !enemy_spawned:
			enemy_position = (map.pick_random() * borders.position) * 16
			# Проверяем, находится ли точка спавна в пределах обнаружения игрока
			if enemy_position.distance_to(player_position) > player_detection_radius:
				enemy_spawned = true
		
		var enemy = enemy_scene.instantiate()
		enemy.position = enemy_position
		add_child(enemy)



func _on_timer_timeout():
	pass
	#таймер в игре
	#get_tree().reload_current_scene()
