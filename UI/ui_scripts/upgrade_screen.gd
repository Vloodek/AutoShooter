extends Control

var player
#@onready var player = get_node("../Player")
@onready var carts_id_in_cart_slots: Array = [-1, -1, -1]
@onready var procent_in_cart_slots: Array = [-1, -1, -1]
@onready var target_gun_in_cart_slots: Array = [-1, -1, -1]
var is_showing = false
var can_take_next_gun = false


func _ready():
	player_data.set_upgrade_screen($".")
	$Button.disabled = true


func show_screen():
	generate_carts()
	is_showing = true
	get_tree().paused = true  # Устанавливаем паузу в игре
	toggle_buttons_state()
	$PanelContainer/HBoxContainer/Button2.grab_focus()
	$AnimationPlayer.play("blur")


func generate_carts():
	player = get_tree().get_first_node_in_group("player")
	for i in range(len(carts_id_in_cart_slots)):
		var cart_id
		if can_take_next_gun:
			cart_id = randi() % player_data.ALL_CART_TYPES
		else:
			cart_id = randi() % (player_data.ALL_CART_TYPES-4) + 4
		carts_id_in_cart_slots[i] = cart_id
		#procent_in_cart_slots[i] = randi() % 10
		var card_level = randi() % 100 + 1
		if card_level < 61:
			procent_in_cart_slots[i] = randi() % 3 + 1
		elif card_level < 86:
			procent_in_cart_slots[i] = randi() % 5 + 3
		elif card_level < 96:
			procent_in_cart_slots[i] = randi() % 7 + 5
		else:
			procent_in_cart_slots[i] = randi() % 10 + 7
		target_gun_in_cart_slots[i] = randi() % player_data.enabled_guns
		print(cart_id, " cart ", procent_in_cart_slots[i], " percent ", target_gun_in_cart_slots[i], "target_gun")
		
			


func toggle_buttons_state():
	$PanelContainer/HBoxContainer/Button1.disabled = !$PanelContainer/HBoxContainer/Button1.disabled
	$PanelContainer/HBoxContainer/Button2.disabled = !$PanelContainer/HBoxContainer/Button2.disabled
	$PanelContainer/HBoxContainer/Button3.disabled = !$PanelContainer/HBoxContainer/Button3.disabled


func choose_cart(slot_id):
	if carts_id_in_cart_slots[slot_id] < 4:
		can_take_next_gun = false
	player.update_stats(carts_id_in_cart_slots[slot_id], procent_in_cart_slots[slot_id])
	toggle_buttons_state()
	hide_screen()


func hide_screen():
	get_tree().paused = false  # Снимаем паузу в игре
	$AnimationPlayer.play_backwards("blur")
	is_showing = false


func _on_button_pressed():
	hide_screen()


func _on_button_1_pressed():
	choose_cart(0)


func _on_button_2_pressed():
	choose_cart(1)


func _on_button_3_pressed():
	choose_cart(2)
