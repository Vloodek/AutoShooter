extends Area2D

@export var ammo = 10
@onready var player = get_tree().get_first_node_in_group("player")


func _ready():
	$anim.play("Active")
func _on_body_entered(body):
	if body.name == "Player":
		player_data.ammo += ammo
		player_data.collector_range_scale += 0.2
		if player:
			player.update_stats()
		queue_free()


#Радиус сбора игрока 
func _on_area_entered(area):
	if area.name == "collect_area":
		if player:
			player_data.collector_range_scale += 0.5
			player.update_stats()
		queue_free()
