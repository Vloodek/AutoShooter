extends Control

var player
#@onready var player = get_node("../Player")
@onready var carts_id_in_cart_slots: Array = [-1, -1, -1]


func _ready():
	player_data.set_upgrade_screen($".")
	$Button.disabled = true


func show_screen():
	#print('SHOW SCREEN2')
	generate_carts()
	get_tree().paused = true  # Устанавливаем паузу в игре
	$AnimationPlayer.play("blur")


func generate_carts():
	player = get_tree().get_first_node_in_group("player")
	for i in range(len(carts_id_in_cart_slots)):
		var cart_id = randi() % player_data.ALL_CART_TYPES
		print(cart_id)
		carts_id_in_cart_slots[i] = cart_id


func choose_cart(slot_id):
	player.update_stats(carts_id_in_cart_slots[slot_id])
	hide_screen()


func hide_screen():
	get_tree().paused = false  # Снимаем паузу в игре
	$AnimationPlayer.play_backwards("blur")


func _on_button_pressed():
	hide_screen()


func _on_button_1_pressed():
	choose_cart(0)


func _on_button_2_pressed():
	choose_cart(1)


func _on_button_3_pressed():
	choose_cart(2)
