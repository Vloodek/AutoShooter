extends CharacterBody2D

var current_state = player_states.MOVE
enum player_states {MOVE,DEAD}
var is_dead = false


@onready var bullet_scene = preload("res://Entities/Scenes/Bullets/bullet_1.tscn")
@onready var trail_scene = preload("res://Entities/Scenes/FX/scent_trail.tscn")
@export var speed: int
var input_movement = Vector2()
@onready var gun = $gun_handler
@onready var gun_spr = $gun_handler/gun_sprite
@onready var bullet_point = $gun_handler/bullet_point

var pos
var rot



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_data.health <= 0:
		current_state = player_states.DEAD
	target_mouse()
	
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
		
	if input_movement == Vector2.ZERO:
		velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("ui_shoot") && player_data.ammo > 0:
		player_data.ammo -=1
		instance_bullet()
		
		
	move_and_slide()
	
	
func animations():
	if input_movement != Vector2.ZERO:
		#if input_movement.x > 0:
			#$Sprite2D.flip_h = false
			
		#if input_movement.x < 0:
			#$Sprite2D.flip_h = true
		$anim.play("Move")
		
	if input_movement == Vector2.ZERO:
		$anim.play("Idle")

func dead():
	is_dead = true
	velocity = Vector2.ZERO
	gun.visible = false
	$anim.play("Dead")
	await get_tree().create_timer(2).timeout #Ждем две секунды (столько длится анимация) и делаем что-то
	if get_tree():
		get_tree().reload_current_scene()
		player_data.health =4
		player_data.ammo = 50
		is_dead = false
		
func target_mouse():
	if is_dead == false:
		var mouse_movement = get_global_mouse_position()
		pos = global_position
		gun.look_at(mouse_movement)
		rot = rad_to_deg((mouse_movement - pos).angle())
		#Поворот оружия
		if rot >= -90 and rot <= 90:
			gun_spr.flip_v = false
			$Sprite2D.flip_h = false
		else:
			gun_spr.flip_v = true
			$Sprite2D.flip_h = true
	else:
		return
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


#Если хитбокс игрока коллизия с врагом
func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy"):
		flash()
		player_data.health -=0

func flash():
	$Sprite2D.material.set_shader_parameter("flash_modifer",1)
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifer",0)
