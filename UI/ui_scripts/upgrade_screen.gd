extends Control

func _ready():
	player_data.set_upgrade_screen($".")
	
func show_screen():
	print('SHOW SCREEN2')
	get_tree().paused = true  # Устанавливаем паузу в игре
	$AnimationPlayer.play("blur")
func hide_screen():

	get_tree().paused = false  # Снимаем паузу в игре
	$AnimationPlayer.play_backwards("blur")
func _on_upgrade_button_pressed():
	# Обработка нажатия на кнопку прокачки
	# Здесь можно реализовать логику для прокачки персонажа
	pass

func _on_weapon_button_pressed():
	# Обработка нажатия на кнопку выбора оружия
	# Здесь можно реализовать логику для выбора оружия
	pass


func _on_button_pressed():
	hide_screen()
