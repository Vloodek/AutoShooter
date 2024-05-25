extends Area2D


func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()


func _on_body_entered(body):
	if body.name == "Player":
		player_data.health -= 0.1
