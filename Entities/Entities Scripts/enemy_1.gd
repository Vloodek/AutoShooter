extends CharacterBody2D

@export var speed = 10
@onready var fx_scene = preload("res://Entities/Scenes/FX/fx_scene.tscn")
@onready var exp_scene = preload("res://Interactables/scenes/exp.tscn")
@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D
enum enemy_direction {RIGHT, LEFT, UP, DOWN, CHASE}
var new_direction = enemy_direction.RIGHT
var change_direction
var HP = 3
const CHASE_SPEED = 60
@onready var target = get_node("../Player")
# Called when the node enters the scene tree for the first time.
var time_since_last_call: float = 0.0


func _ready():
	#choose_direction()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#match new_direction:
		#enemy_direction.RIGHT:
			#move_right()
		#enemy_direction.LEFT:
			#move_left()
		#enemy_direction.UP:
			#move_up()
		#enemy_direction.DOWN:
			#move_down()
		#enemy_direction.CHASE:
			#chase_state()


#func move_right():
	#velocity = Vector2.RIGHT * speed 
	#move_and_slide()
#
#
#func move_left():
	#velocity = Vector2.LEFT * speed 
	#move_and_slide()
#
#
#func move_up():
	#velocity = Vector2.UP * speed 
	#move_and_slide()
#
#
#func move_down():
	#velocity = Vector2.DOWN * speed 
	#move_and_slide()


#func choose_direction():
	#change_direction = randi() % 4
	#random_direction()
	
	
#func random_direction():
	#match  change_direction:
		#0:
			#new_direction = enemy_direction.RIGHT
		#1:
			#new_direction = enemy_direction.LEFT
		#2:
			#new_direction = enemy_direction.UP
		#3:
			#new_direction = enemy_direction.DOWN
	#new_direction = enemy_direction.values()[change_direction]


func _on_timer_timeout():
	makepath()
	$Timer.start()


func _on_hitbox_area_entered(area):
	if area.is_in_group("Bullet"):
		instance_experience()
		instance_fx()
		queue_free()


func instance_fx():
	var fx = fx_scene.instantiate()
	fx.global_position = global_position
	get_tree().root.add_child(fx)


func instance_experience():
	var experience = exp_scene.instantiate()
	experience.global_position = global_position
	experience.add_to_group("exp_pickup")  # Устанавливаем группу для патрона
	get_tree().root.call_deferred("add_child", experience)


#func chase_state():
	#var chase_speed = 60
	#velocity = position.direction_to(target.global_position ) * chase_speed
	#animation()
	#move_and_slide()


func animation():
	if velocity > Vector2.ZERO:
		$anim.play("move_right")
	if velocity < Vector2.ZERO:
		$anim.play("move_left")


#func _on_chase_box_area_entered(_area):
	#pass
	#if area.is_in_group("follow"):
		#new_direction = enemy_direction.CHASE


func _physics_process(_delta : float):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * CHASE_SPEED
	animation()
	move_and_slide()
	#time_since_last_call += delta
	#if time_since_last_call > 0.45:
		#makepath()
		#time_since_last_call = 0.0
	
	
func makepath():
	nav_agent.target_position = target.global_position
