extends CharacterBody2D

var current_state = player_states.MOVE
enum player_states {MOVE, DEAD}
var is_dead = false

@onready var bullet_scene = preload("res://Entities/Scenes/Bullets/bullet_1.tscn")
@onready var trail_scene = preload("res://Entities/Scenes/FX/scent_trail.tscn")
@export var speed: int
var input_movement = Vector2()

@onready var gun = $gun_handler
@onready var gun_spr = $gun_handler/gun_sprite
@onready var bullet_point = $gun_handler/bullet_point

@onready var fire_timer = $fire_timer

var pos
var rot

# Called when the node enters the scene tree for the first time.
func _ready():
	fire_timer.wait_time = player_data.fire_rate
	fire_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_data.health <= 0:
		current_state = player_states.DEAD
	target_mouse_or_enemy()
	match current_state:
		player_states.MOVE:
			movement(delta)
		player_states.DEAD:
			dead()

func movement(delta):
	animations()
	input_movement = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if input_movement != Vector2.ZERO:
		velocity = input_movement * speed
	else:
		velocity = Vector2.ZERO
	
	#if Input.is_action_just_pressed("ui_shoot") && player_data.ammo > 0:
		#player_data.ammo -= 1
		#instance_bullet()
	
	move_and_slide()

func animations():
	if input_movement != Vector2.ZERO:
		$anim.play("Move")
	else:
		$anim.play("Idle")

func dead():
	reload_game()
		
func reload_game():
	fire_timer.stop()
	is_dead = true
	velocity = Vector2.ZERO
	gun.visible = false
	$anim.play("Dead")
	await get_tree().create_timer(2).timeout
	if get_tree():
		var ammo_pickups = get_tree().get_nodes_in_group("ammo_pickup")
		for ammo_pickup in ammo_pickups:
			ammo_pickup.queue_free()
		get_tree().reload_current_scene()
		player_data.health = 4
		player_data.ammo = 50
		is_dead = false
		$Sprite2D.material.set_shader_parameter("flash_modifer", 0)

func target_enemy():
	var closest_enemy = null
	var min_distance = 150

	# Iterate through all enemies to find the closest one
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy

	# If an enemy is found, rotate the gun towards it and start the timer
	if closest_enemy:
		if fire_timer.is_stopped():
			fire_timer.start()
		gun.look_at(closest_enemy.global_position)
		pos = global_position
		rot = rad_to_deg((closest_enemy.global_position - pos).angle())
		if rot >= -90 and rot <= 90:
			gun_spr.flip_v = false
			$Sprite2D.flip_h = false
		else:
			gun_spr.flip_v = true
			$Sprite2D.flip_h = true
	# If no enemies are nearby, pause the timer
	else:
		fire_timer.stop()



func target_mouse_or_enemy():
	if is_dead:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() > 0:
		target_enemy()
	else:
		fire_timer.stop()


func instance_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.direction = bullet_point.global_position - gun.global_position
	bullet.global_position = bullet_point.global_position
	get_tree().root.add_child(bullet)

func reset_states():
	current_state = player_states.MOVE

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

func _on_fire_timer_timeout():
	if player_data.ammo > 0:
		instance_bullet()
		player_data.ammo -= 1
