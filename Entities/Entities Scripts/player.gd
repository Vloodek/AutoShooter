extends CharacterBody2D

var current_state = player_states.MOVE
enum player_states {MOVE, DEAD}
var _is_dead = false

@onready var bullet_scene = preload("res://Entities/Scenes/Bullets/bullet_1.tscn")
@onready var trail_scene = preload("res://Entities/Scenes/FX/scent_trail.tscn")
@export var speed: int
var input_movement = Vector2()
@onready var ray_cast = $RayCast2D
@onready var shoot_range_collider = $shoot_range_area/shoot_range_collider
@onready var guns: Array = [$gun_handler1, $gun_handler2, $gun_handler3, $gun_handler4]
@onready var gun_sprs: Array = [$gun_handler1/gun_sprite, $gun_handler2/gun_sprite, $gun_handler3/gun_sprite, $gun_handler4/gun_sprite]
@onready var bullet_points: Array = [$gun_handler1/bullet_point, $gun_handler2/bullet_point, $gun_handler3/bullet_point, $gun_handler4/bullet_point]
#@onready var fire_timer = $fire_timer

var pos
var rot
var min_distance_to_shoot
var time_since_last_call_fire_rate1: float = 0.0
var time_since_last_call_fire_rate2: float = 0.0
var time_since_last_call_fire_rate3: float = 0.0
var time_since_last_call_fire_rate4: float = 0.0
@onready var times_fire_rates: Array = [time_since_last_call_fire_rate1, time_since_last_call_fire_rate2, time_since_last_call_fire_rate3, time_since_last_call_fire_rate4]
@onready var fire_rates: Array = [player_data.fire_rate1, player_data.fire_rate2, player_data.fire_rate3, player_data.fire_rate4]
var enemy_list_at_range: Array


func _ready():
	pass
	#fire_timer.wait_time = player_data.fire_rate
	#fire_timer.start()


func _process(delta):
	if player_data.health <= 0:
		current_state = player_states.DEAD
		die()
	else:
		target_enemy(delta)
		#if current_state == player_states.MOVE:
		movement(delta)


func movement(_delta):
	#animations()
	input_movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_movement != Vector2.ZERO:
		$anim.play("Move")
		velocity = input_movement * speed
	else:
		$anim.play("Idle")
		velocity = Vector2.ZERO
	#if Input.is_action_just_pressed("ui_shoot") && player_data.ammo > 0:
		#player_data.ammo -= 1
		#instance_bullet()
	move_and_slide()


#func animations():
	#if input_movement != Vector2.ZERO:
		#$anim.play("Move")
	#else:
		#$anim.play("Idle")


func die():
	_is_dead = true
	#fire_timer.stop()
	velocity = Vector2.ZERO
	for gun in guns:
		gun.visible = false
	$anim.play("Dead")
	await get_tree().create_timer(2).timeout
	$anim.pause()
	$Sprite2D.material.set_shader_parameter("flash_modifer", 0)
	#reload_game()


#func reload_game():
	#fire_timer.stop()
	#_is_dead = true
	#velocity = Vector2.ZERO
	#gun.visible = false
	#$anim.play("Dead")
	#await get_tree().create_timer(2).timeout
	#if get_tree():
		##Очистка опыта на карте
		#var exp_pickups = get_tree().get_nodes_in_group("exp_pickup")
		#for exp_pickup in exp_pickups:
			#exp_pickup.queue_free()
		#player_data.health = player_data.default_health
		#player_data.ammo = player_data.default_ammo
		#_is_dead = false
		#$Sprite2D.material.set_shader_parameter("flash_modifer", 0)
		#get_tree().reload_current_scene()


func target_enemy(delta):
	var closest_enemy = null
	min_distance_to_shoot = player_data.min_distance_to_shoot
	# Iterate through all enemies to find the closest one
	for enemy in enemy_list_at_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance_to_shoot:
			min_distance_to_shoot = distance
			closest_enemy = enemy
	
	# If an enemy is found, rotate the gun towards it and start the timer
	if closest_enemy:
		ray_cast.target_position = to_local(closest_enemy.global_position)
		if ray_cast.get_collider() and ray_cast.get_collider().get_class() == "CharacterBody2D":
			#if fire_timer.is_stopped():
				#fire_timer.start()
			for i in range(player_data.enabled_guns):
				guns[i].look_at(closest_enemy.global_position)
			pos = global_position
			rot = rad_to_deg((closest_enemy.global_position - pos).angle())
			if rot >= -90 and rot <= 90:
				for i in range(player_data.enabled_guns):
					gun_sprs[i].flip_v = false
				$Sprite2D.flip_h = false
			else:
				for i in range(player_data.enabled_guns):
					gun_sprs[i].flip_v = true
				$Sprite2D.flip_h = true
			 # Обновляем счетчик времени
			for i in range(player_data.enabled_guns):
				times_fire_rates[i] += delta
				# Проверяем, прошло ли малое время с последнего вызова
				if times_fire_rates[i] >= fire_rates[i]:
					instance_bullet(bullet_points[i], guns[i])
					# Сбрасываем счетчик времени после вызова функции
					times_fire_rates[i] = 0.0
		#else:
			#fire_timer.stop()
	# If no enemies are nearby, pause the timer
	#else:
		#fire_timer.stop()


#func target_mouse_or_enemy(delta):
	#if _is_dead:
		#return
	#var is_enemy_on_the_scene = get_tree().get_nodes_in_group("enemy").size()
	#if is_enemy_on_the_scene > 0:
	#target_enemy(delta)
	#else:
		#fire_timer.stop()


func change_dead_state(value):
	_is_dead = value


func instance_bullet(bullet_point, gun):
	var bullet = bullet_scene.instantiate()
	bullet.direction = bullet_point.global_position - gun.global_position
	bullet.global_position = bullet_point.global_position
	get_tree().root.add_child(bullet)


func reset_states():
	player_data.health = player_data.default_health
	player_data.ammo = player_data.default_ammo
	player_data.fire_rate1 = player_data.default_fire_rate1
	player_data.fire_rate2 = player_data.default_fire_rate2
	player_data.fire_rate3 = player_data.default_fire_rate3
	player_data.fire_rate4 = player_data.default_fire_rate4
	player_data.min_distance_to_shoot = player_data.default_min_distance_to_shoot
	player_data.enabled_guns = player_data.default_enabled_guns
	change_dead_state(false)
	#current_state = player_states.MOVE


func instance_trail():
	var trail = trail_scene.instantiate()
	trail.global_position = global_position
	get_tree().root.add_child(trail)


func _on_trail_timer_timeout():
	instance_trail()
	$trail_timer.start()


func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		flash()
		player_data.health -= 0


func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifer", 1)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifer", 0)


#func _on_fire_timer_timeout():
	#pass
	#if player_data.ammo > 0:
	#instance_bullet()
	#player_data.ammo -= 1


func update_stats(cart_id: int = -1):
	#$collect_collider.scale = $collect_collider.scale + $collect_collider.scale*0.2
	#print('update')
	$collect_area.scale = Vector2(player_data.collector_range_scale, player_data.collector_range_scale)
	#shoot_range_collider.shape.radius = player_data.min_distance_to_shoot
	
	#if player_data.experience > 1000:
		#player_data.enabled_guns = 2
		
	match cart_id:
		0, 1, 2, 3:
			if player_data.enabled_guns < player_data.ALL_WEAPON_SLOTS:
				player_data.enabled_guns += 1
				player_data.gun_in_inventory[player_data.enabled_guns-1] = cart_id
				gun_sprs[player_data.enabled_guns-1].texture = load(player_data.gun_textures[cart_id])
		4:
			pass

	for i in range(player_data.enabled_guns):
		guns[i].visible = true


#func _on_collect_area_area_entered(_area):
	##print('da')
	#update_stats()


func _on_shoot_range_area_body_entered(body):
	if enemy_list_at_range.size() < 10:
		enemy_list_at_range.append(body)
		for enemy in enemy_list_at_range:
			if enemy == null:
				enemy_list_at_range.erase(enemy)
		#print(enemy_list_at_range)


func _on_shoot_range_area_body_exited(body):
	enemy_list_at_range.erase(body)
