extends Node2D
class_name MainLevel

@onready var exit_scene = preload("res://Interactables/scenes/exit.tscn")
@onready var player_scene = preload("res://Entities/Scenes/Player/player.tscn")
@onready var enemy_scene = preload("res://Entities/Scenes/Enemies/enemy_1.tscn")

@export var borders = Rect2(1,1,100,52)
@export var grid_map_size = 16

var enemy_counter = 0
var number_timeout = 0
var number_enemy_at_group = 150
var player
var exit
var map
var level_timeout = 300 # seconds
var is_boss_spawned = false;
var is_scene_reloading = false;
@onready var timer = $Timer

enum enemy_difficult {easy, middle, hard, boss} 


func _ready():
	#randomize()
	var start_number_enemy = 10
	generate_level(start_number_enemy)


func generate_level(start_number_enemy):
	var walker
	var rooms_data = instance_empty_rooms()
	walker = rooms_data[0]
	map = rooms_data[1]
	exit = instance_exit(walker)
	player = instance_player()
	instance_enemy(enemy_difficult.easy, player.position, start_number_enemy)


func instance_empty_rooms():
	var tilemap = $TileMap
	var ground = $ground
	var ground_layer = 0
	var walker = Walker_room.new(Vector2(3,5), borders)
	map = walker.walk(800) # потестить
	var using_cells: Array = []
	var all_cells: Array = tilemap.get_used_cells(ground_layer)
	tilemap.clear()
	walker.queue_free()
	for tile in all_cells:
		if !map.has(Vector2(tile.x, tile.y)):
			using_cells.append(tile)
			ground.set_cell(0,Vector2i(tile.x, tile.y), 2,Vector2i(3,4)) # Заготовленная плитка ставится на тайлмап ground
	tilemap.set_cells_terrain_connect(ground_layer, using_cells, ground_layer, ground_layer, false)
	#tilemap.set_cells_terrain_path(ground_layer, using_cells, ground_layer, ground_layer, false)
	return [walker, map]


func instance_exit(walker):
	exit = exit_scene.instantiate()
	add_child(exit)
	exit.position = walker.get_end_room().position * grid_map_size
	return exit


func instance_player():
	player = player_scene.instantiate()
	add_child(player)
	player.position = map.pop_front() * grid_map_size
	# print(player.position)
	#player_pos = player.position
	player.update_stats()
	return player


#func instance_enemy():
	#for i in range(number_enemy):
		#var enemy = enemy_scene.instantiate()
		#enemy.position = (map.pick_random() * borders.position) * grid_map_size
		#add_child(enemy)


func instance_enemy(enemy_difficult_type, player_pos, number_enemy):
	#var player_position = player_pos # Предположим, что позиция игрока доступна через узел $Player
	var player_detection_radius = 150 # Условный радиус обнаружения игрока для врагов
	
	for i in range(number_enemy):
		var enemy_spawned = false
		var enemy_position = Vector2.ZERO
		
		while !enemy_spawned:
			enemy_position = (map.pick_random() * borders.position) * grid_map_size
			# Проверяем, находится ли точка спавна в пределах обнаружения игрока
			if enemy_position.distance_to(player_pos) > player_detection_radius:
				enemy_spawned = true	
		var enemy
		match enemy_difficult_type:
			enemy_difficult.easy:
				enemy = enemy_scene.instantiate()
			enemy_difficult.middle:
				enemy = enemy_scene.instantiate()
			enemy_difficult.hard:
				enemy = enemy_scene.instantiate()
			enemy_difficult.boss:
				enemy = enemy_scene.instantiate()
		enemy.position = enemy_position
		add_child(enemy)
		enemy_counter += 1
		print(enemy_counter)


# enter pressed
func _input(_event):
	if player._is_dead && Input.is_action_just_pressed("ui_accept") && !is_scene_reloading:
			is_scene_reloading = true
			reload_game()


#func set_value_timer_ended_counter(value):
	#number_timeout = value


func set_value_timer(value):
	timer.wait_time = value
	

func set_value_number_enemy_at_group(value):
	number_enemy_at_group = value


func _on_timer_timeout():
	instance_enemy(enemy_difficult.easy, player.position, number_enemy_at_group)
	number_timeout += 1
	if number_timeout * timer.wait_time > level_timeout and !is_boss_spawned:
		is_boss_spawned = true
		instance_enemy(enemy_difficult.boss, player.position, 1)
		print("spawned")
	#таймер в игре
	#get_tree().reload_current_scene()


func _on_timer_check_reload_timeout():
	if exit.is_entered && !is_scene_reloading:
		is_scene_reloading = true
		reload_game()


func reload_game():
	if get_tree():
		#Очистка опыта на карте
		var exp_pickups = get_tree().get_nodes_in_group("exp_pickup")
		for exp_pickup in exp_pickups:
			exp_pickup.queue_free()
		player_data.health = player_data.default_health
		player_data.ammo = player_data.default_ammo
		player.change_dead_state(false)
		get_tree().reload_current_scene()
