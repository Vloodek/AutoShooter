extends Area2D

@onready var fx_scene = preload("res://Entities/Scenes/FX/fx_scene.tscn")
@export var speed = 50
var direction = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(direction * speed * delta )
	pass

#Удаление пули после колизии
func _on_body_entered(body):
	Globals.camera.screen_shake(2,9,0.05)
	instance_fx()
	queue_free()


func _on_visible_screen_exited():
	queue_free()


func instance_fx():
	var fx = fx_scene.instantiate()
	fx.global_position = global_position
	get_tree().root.add_child(fx)
