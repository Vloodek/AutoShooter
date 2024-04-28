extends Area2D

@export var ammo = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	$anim.play("Active")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "Player":
		player_data.ammo += ammo
		queue_free()