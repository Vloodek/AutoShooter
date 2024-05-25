extends Control

var player
#@onready var player = get_node("../Player")
@onready var carts_id_in_cart_slots: Array = [-1, -1, -1]
@onready var procent_in_cart_slots: Array = [-1, -1, -1]
@onready var target_gun_in_cart_slots: Array = [-1, -1, -1]
@onready var carts: Array = [$PanelContainer/HBoxContainer/Button1, $PanelContainer/HBoxContainer/Button2, $PanelContainer/HBoxContainer/Button3]
@onready var color_rects: Array = [$PanelContainer/HBoxContainer/Button1/ColorRect, $PanelContainer/HBoxContainer/Button2/ColorRect, $PanelContainer/HBoxContainer/Button3/ColorRect]
@onready var labels: Array = [$PanelContainer/HBoxContainer/Button1/Label, $PanelContainer/HBoxContainer/Button2/Label, $PanelContainer/HBoxContainer/Button3/Label]
var is_showing = false
var can_take_next_gun = false
var int_to_str: Array = ["first", "second", "third", "forth"]
var attributes_textures: Array = ["", "", "", "", "res://Sprites/combat_visor.png", "res://Sprites/metalstorm_lvl1.png", "res://Sprites/weapon_power_lvl1.png", "res://Sprites/charged_bullets.png", "res://Sprites/fire_range_lvl1.png", "res://Sprites/blood_compressor.png", "res://Sprites/healers_nanobots.png", "res://Sprites/pickaxe.png"]
var commom_attributes = [4, 8, 9, 10, 11]
var attributes_name_label: Array = ["", "", "", "", 
"Combat Visor", "Metal Storm", "Weapon Powder", "Charged Bullets", "Rangefinder", "Blood Compressor", "Healers Nanobots", "Hammer"]

var weapons_name_label: Array = ["Gun", "Submachine gun", "Rifle", "Grenade Launcher"]
var description_attributes: Array = ["average statistics", "high speed\nlow damage", "low speed\nhigh damage", "very low speed\nvery high damage",
"increased radius exp collection",
"increased fire rate",
"increased power rate",
"increased bullet velocity",
"increased firing range",
"increased max health points",
"increased regeneration rate",
"increased digging speed"]


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
	target_gun_in_cart_slots = [-1, -1, -1]
	player = get_tree().get_first_node_in_group("player")
	for i in range(len(carts_id_in_cart_slots)):
		var cart_id
		var is_not_valid = true
		if can_take_next_gun:
			while is_not_valid:
				cart_id = randi() % 4
				if cart_id not in carts_id_in_cart_slots:
					carts_id_in_cart_slots[i] = cart_id
					is_not_valid = false
			carts[i].icon = load(player_data.gun_textures[carts_id_in_cart_slots[i]])
			#color_rects[i].color = Color(0.5, 0.5, 0.5, 1)
			labels[i].text = str(weapons_name_label[carts_id_in_cart_slots[i]])
		else:
			while is_not_valid:
				cart_id = randi() % (player_data.ALL_CART_TYPES-4) + 4
				if cart_id not in carts_id_in_cart_slots:
					if cart_id not in commom_attributes:
						target_gun_in_cart_slots[i] = randi() % player_data.enabled_guns
					carts_id_in_cart_slots[i] = cart_id
					is_not_valid = false
			carts[i].icon = load(attributes_textures[carts_id_in_cart_slots[i]])
			labels[i].text = str(attributes_name_label[carts_id_in_cart_slots[i]])
		#procent_in_cart_slots[i] = randi() % 10
		var card_level = randi() % 100 + 1
		if card_level < 61:
			procent_in_cart_slots[i] = randi() % 3 + 1
			#carts[i].self_modulate = Color(0, 1, 0, 1)
			#carts[i].icon = load(player_data.gun_textures[0])
			color_rects[i].color = Color(0, 1, 0, 1)
			#carts[i].icon.modulate = Color(1, 1, 1, 1)
		elif card_level < 86:
			procent_in_cart_slots[i] = randi() % 5 + 3
			color_rects[i].color = Color(0, 0, 1, 1)
			#carts[i].self_modulate = Color(0, 0, 1, 1)
		elif card_level < 96:
			procent_in_cart_slots[i] = randi() % 7 + 5
			#carts[i].self_modulate = Color(1, 0, 0, 1)
			color_rects[i].color = Color(1, 0, 0, 1)
		else:
			procent_in_cart_slots[i] = randi() % 10 + 7
			#carts[i].self_modulate = Color(1, 0, 1, 1)
			color_rects[i].color = Color(1, 0, 1, 1)
		print(carts_id_in_cart_slots[i], " cart ", procent_in_cart_slots[i], " percent ", target_gun_in_cart_slots[i], " target_gun")
		if target_gun_in_cart_slots[i] != -1:
			carts[i].text = str(procent_in_cart_slots[i]) + " percent on " + int_to_str[target_gun_in_cart_slots[i]] + " gun \n" + str(description_attributes[carts_id_in_cart_slots[i]])
		else:
			#color_rects[i].color = Color(1, 1, 1, 0)
			if carts_id_in_cart_slots[i] < 4:
				carts[i].text = str(description_attributes[carts_id_in_cart_slots[i]])
				color_rects[i].color = Color(1, 1, 1, 0)
			else:
				carts[i].text = str(procent_in_cart_slots[i]) + " percent \n" + str(description_attributes[carts_id_in_cart_slots[i]])


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
