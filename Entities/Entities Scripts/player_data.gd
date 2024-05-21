extends Node

class_name player_data

# Статическое свойство для ссылки на экран прокачки
static var upgrade_screen: Node

static var default_health = 4
static var default_ammo = 1000000000
static var default_fire_rate: float = 1.0
static var default_speed = 100
static var default_collector_range_scale: float = 1.0
static var default_min_distance_to_shoot: int = 100
static var default_enabled_guns = 1
static var default_gun_in_inventory = [0, 0, 0, 0]

static var enabled_guns = default_enabled_guns

static var health = default_health
static var ammo = default_ammo
static var fire_rate1: float = default_fire_rate
static var fire_rate2: float = default_fire_rate
static var fire_rate3: float = default_fire_rate
static var fire_rate4: float = default_fire_rate
static var speed = default_speed
static var collector_range_scale = default_collector_range_scale
static var min_distance_to_shoot: int = default_min_distance_to_shoot

static var gun_textures: Array = ["res://Sprites/turret_01.png", "res://Sprites/turret_02.png", "res://Sprites/turret_03.png", "res://Sprites/turret_04.png"]
static var gun_fire_rates: Array = [1.0, 0.3, 1.5, 4]
static var gun_fire_power: Array = [1.0, 0.1, 2, 6]
static var gun_bullet_speed: Array = [25, 50, 40, 30]

static var ALL_WEAPON_SLOTS = 4
static var ALL_CART_TYPES = 4
static var experience = 0
static var level = 1

static var gun_in_inventory: Array = default_gun_in_inventory

#@onready var gun_spr1 = $gun_handler1/gun_sprite


static func add_experience(amount: int):
	experience += amount
	check_level_up()
	#gun_spr1.texture.set_texture("res://Sprites/exit_portal.png")


static func check_level_up():
	var experience_needed = get_experience_needed()
	while experience >= experience_needed && upgrade_screen.is_showing == false:
		level += 1
		update_attributes_for_level()
		experience_needed = get_experience_needed()
		if level > 1:
			show_upgrade_screen()


static func get_experience_needed() -> int:
	print("level is ", level)
	if level == 1:
		return 500
	elif level >= 2 and level <= 7:
		return 500 + (level - 2) * 1000
	elif level >= 8 and level <= 20:
		return 5500 + (level - 8) * 1700
	elif level >= 21 and level <= 30:
		return 31500 + (level - 21) * 2200
	elif level >= 31 and level <= 65:
		return 83200 + (level - 31) * 5000
	else:
		return 0


static func update_attributes_for_level():
	pass


# Функция для установки ссылки на экран прокачки
static func set_upgrade_screen(screen: Node):
	upgrade_screen = screen


static func show_upgrade_screen():
	# Проверяем, что у нас есть ссылка на экран прокачки
	if upgrade_screen:
		#print(upgrade_screen)
		# Показываем экран прокачки
		upgrade_screen.show_screen()
		# Также приостанавливаем игру, если это необходимо
		# Например, сделайте get_tree().paused = true
	else:
		print("Ошибка: Не установлена ссылка на экран прокачки")
