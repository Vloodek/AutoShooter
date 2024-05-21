extends Area2D

@onready var fx_scene = preload("res://Entities/Scenes/FX/fx_scene.tscn")
@export var speed = 0
@export var power = 0
var direction = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.


#func _ready(spd):
	#speed = spd


#func _init(spd):
	#speed = spd


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta)


#Удаление пули после колизии
func _on_body_entered(_body):
	Globals.camera.screen_shake(2,9,0.05)
	instance_fx()
	queue_free()


func instance_fx():
	var fx = fx_scene.instantiate()
	fx.global_position = global_position
	get_tree().root.add_child(fx)
