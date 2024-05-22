extends Node2D
class_name MainLevel

@onready var exit_scene = preload("res://Interactables/scenes/exit.tscn")
@onready var player_scene = preload("res://Entities/Scenes/Player/player.tscn")
@onready var enemy_scene = preload("res://Entities/Scenes/Enemies/enemy_1.tscn")

@export var borders = Rect2(1,1,100,52)
@export var grid_map_size = 16

var enemy_textures: Array = ["res://Sprites/MedZ_Animation.png", "res://Sprites/MedZ_Animation_02.png", "res://Sprites/WagnerZ_Animation_01.png", "res://Sprites/WagnerZ_Animation_01.png"]
#var enemy_counter = 0
var number_timeout = 0
var number_enemy_at_group = 30
var max_number_enemy = 300
var player
var exit
var map
var level_timeout = 30 # seconds
@onready var timer = $Timer
@onready var times_spawned = level_timeout / timer.wait_time
var is_boss_spawned = false
var is_scene_reloading = false
var map_picks: Array

enum enemy_difficult {easy, middle, hard, boss} 
var level_number_easy_enemies: Array = [180, 320]
var level_number_middle_enemies: Array = [20, 80]
var level_number_hard_enemies: Array = [0, 0]
var level_difficult_enemies: Array = [1, 2]
var current_level_groups_participants_to_spawn: Array = [-1, -1, -1]
var levels_numbers_enemies: Array  = [level_number_easy_enemies, level_number_middle_enemies, level_number_hard_enemies]
var hp_enemies: Array = [3, 10, 50, 1000]
var speed_enemies: Array = [20, 60, 50, 70]
var enemy_damage: Array = [1, 4, 10, 30]


func _ready():
	#randomize()
	var start_number_enemy = 10
	print(player_data.on_floor_level)
	for i in range(current_level_groups_participants_to_spawn.size()):
		current_level_groups_participants_to_spawn[i] = levels_numbers_enemies[i][player_data.on_floor_level] / times_spawned
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
	var player_detection_radius = 200 # Условный радиус обнаружения игрока для врагов
	for i in range(number_enemy):
		var enemy_position = Vector2.ZERO
		var enemy_spawned = false
		var enemy
		if enemy_difficult_type == enemy_difficult.boss:
			enemy_position = exit.position
			enemy = enemy_scene.instantiate()
			enemy.HP = hp_enemies[enemy_difficult.boss]
			enemy.speed = speed_enemies[enemy_difficult.boss]
			enemy.damage = enemy_damage[enemy_difficult.boss]
			enemy.set_texture(enemy_textures[enemy_difficult.boss])
		else:
			while !enemy_spawned:
				var map_pick = map.pick_random()
				if map_pick not in map_picks:
					enemy_position = (map_pick * borders.position) * grid_map_size
					# Проверяем, находится ли точка спавна в пределах обнаружения игрока
					if enemy_position.distance_to(player_pos) > player_detection_radius:
						enemy_spawned = true
						map_picks.append(map_pick)
			enemy = enemy_scene.instantiate()
			match enemy_difficult_type:
				0:
					enemy.HP = hp_enemies[enemy_difficult.easy]
					enemy.speed = speed_enemies[enemy_difficult.easy]
					enemy.damage = enemy_damage[enemy_difficult.easy]
					#print(hp_enemies[enemy_difficult.easy], speed_enemies[enemy_difficult.easy])
					enemy.set_texture(enemy_textures[enemy_difficult.easy])
				1:
					enemy.HP = hp_enemies[enemy_difficult.middle]
					enemy.speed = speed_enemies[enemy_difficult.middle]
					enemy.damage = enemy_damage[enemy_difficult.middle]
					enemy.set_texture(enemy_textures[enemy_difficult.middle])
					#print(hp_enemies[enemy_difficult.middle], speed_enemies[enemy_difficult.middle])
				2:
					enemy.HP = hp_enemies[enemy_difficult.hard]
					enemy.speed = speed_enemies[enemy_difficult.hard]
					enemy.damage = enemy_damage[enemy_difficult.hard]
					enemy.set_texture(enemy_textures[enemy_difficult.hard])
		enemy.update_damage()
		enemy.position = enemy_position
		add_child(enemy)
		#enemy_counter += 1
		#print(enemy_counter)


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
	print(get_tree().get_nodes_in_group("enemy_1").size())
	if get_tree().get_nodes_in_group("enemy_1").size() < max_number_enemy:
		for i in range(current_level_groups_participants_to_spawn.size()):
			print(enemy_difficult.values()[i], " ", current_level_groups_participants_to_spawn[i])
			instance_enemy(enemy_difficult.values()[i], player.position, current_level_groups_participants_to_spawn[i])
	number_timeout += 1
	if number_timeout * timer.wait_time > level_timeout && !is_boss_spawned:
		is_boss_spawned = true
		instance_enemy(enemy_difficult.boss, player.position, 1)
		print("spawned")
	#таймер в игре
	#get_tree().reload_current_scene()


func _on_timer_check_reload_timeout():
	if exit.is_entered && !is_scene_reloading:
		is_scene_reloading = true
		player_data.on_floor_level += 1
		reload_game()


func reload_game():
	#Очистка опыта на карте
	var exp_pickups = get_tree().get_nodes_in_group("exp_pickup")
	for exp_pickup in exp_pickups:
		exp_pickup.queue_free()
	player.reset_states()
	get_tree().reload_current_scene()
