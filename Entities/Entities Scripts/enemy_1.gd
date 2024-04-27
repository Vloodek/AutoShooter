extends CharacterBody2D

@export var speed = 20
@onready var fx_scene = preload("res://Entities/Scenes/FX/fx_scene.tscn")
@onready var ammo_scene = preload("res://Interactables/scenes/ammo_1.tscn")
enum enemy_direction {RIGHT, LEFT, UP, DOWN, CHASE}
var new_direction = enemy_direction.RIGHT
var change_direction

@onready var target = get_node("../Player")
# Called when the node enters the scene tree for the first time.
func _ready():
	choose_direction()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match new_direction:
		enemy_direction.RIGHT:
			move_right()
		enemy_direction.LEFT:
			move_left()
		enemy_direction.UP:
			move_up()
		enemy_direction.DOWN:
			move_down()
		enemy_direction.CHASE:
			chase_state()
func move_right():
	velocity = Vector2.RIGHT * speed 
	$anim.play("move_right")
	move_and_slide()
func move_left():
	velocity = Vector2.LEFT * speed 
	$anim.play("move_left")
	move_and_slide()
func move_up():
	velocity = Vector2.UP * speed 
	$anim.play("move_up")
	move_and_slide()
func move_down():
	velocity = Vector2.DOWN * speed 
	$anim.play("move_down")
	move_and_slide()

func choose_direction():
	change_direction = randi() % 4
	random_direction()
	
	
func random_direction():
	match  change_direction:
		0:
			new_direction = enemy_direction.RIGHT
		1:
			new_direction = enemy_direction.LEFT
		2:
			new_direction = enemy_direction.UP
		3:
			new_direction = enemy_direction.DOWN


func _on_timer_timeout():
	choose_direction()
	$Timer.start()


func _on_hitbox_area_entered(area):
	if area.is_in_group("Bullet"):
		instance_ammo()
		instance_fx()
		queue_free()

func instance_fx():
	var fx = fx_scene.instantiate()
	fx.global_position = global_position
	get_tree().root.add_child(fx)


func instance_ammo():
	var ammo = ammo_scene.instantiate()
	ammo.global_position = global_position
	get_tree().root.add_child(ammo)

func chase_state():
	var chase_speed = 60
	velocity = position.direction_to(target.global_position ) * chase_speed
	animation()
	move_and_slide()

func animation():
	if velocity > Vector2.ZERO:
		$anim.play("move_right")
	if velocity < Vector2.ZERO:
		$anim.play("move_left")



func _on_chase_box_area_entered(area):
	if area.is_in_group("follow"):
		new_direction = enemy_direction.CHASE
