extends CanvasLayer

const HEART_ROW_SIZE = 200
const HEART_OFFSET = 16
@onready var timer = $"../TimerLevel"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in player_data.max_health:
		var new_heart = Sprite2D.new()
		new_heart.texture = $heart.texture
		new_heart.hframes = $heart.hframes
		$heart.add_child(new_heart)
		#new_heart.add_to_group("heart")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$xp_amount.text = var_to_str(player_data.experience)
	$timer_countdown.text = var_to_str(timer.time_left).pad_decimals(0)
	
	#if get_tree().get_nodes_in_group("heart").size() <= player_data.max_health:
	for heart in $heart.get_children():
		var index = heart.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		@warning_ignore("integer_division")
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		heart.position = Vector2(x,y)
		#Отображение сердечек в зависимости от кол-ва хп
		var last_heart = floor(player_data.health)
		if index > last_heart:
			heart.frame = 0
		if index == last_heart:
			heart.frame = (player_data.health - last_heart) * 4
		if index < last_heart:
			heart.frame = 4
