extends Area2D

var experience = 400
@onready var player = get_tree().get_first_node_in_group("player")


func _ready():
	$anim.play("Active")


func _on_body_entered(body):
	if body.name == "Player":
		#player_data.ammo += ammo
		player_data.collector_range_scale += 0.2
		if player:
			player.update_stats()
		queue_free()


#Радиус сбора игрока 
func _on_area_entered(area):
	if area.name == "collect_area":
		if player:
			player_data.collector_range_scale += 0.1
			player.update_stats()
			player_data.add_experience(experience)
		queue_free()