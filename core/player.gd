extends MarginContainer

@onready var game = $"../../../.."

var troop_grid = [
	[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
	[17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32],
]

var troop_corr = ["peasant"]

var selected_coords = Vector2i(0, 0)
@export var team = true

var money = 99999
var on_spawn_cooldown = false

var spawnpoints = ["Bottom", "Middle", "Top"]
var chosen_point = 1

var info_label = null
var c1pos = Vector2.ZERO
var c2pos = Vector2.ZERO
var c3pos = Vector2.ZERO

# selection settings
var hold_time = 0.0
var repeat_delay = 0.26      # time before repeating starts
var repeat_interval = 0.04   # time between repeats
var repeat_timer = 0.0
var held_direction = Vector2i.ZERO

func _ready() -> void:
	if team:
		info_label = $"../../../Player1Info"
		c1pos = $"../../../../Crystal".global_position
		c2pos = $"../../../../Crystal3".global_position
		c3pos = $"../../../../Crystal4".global_position
	else:
		info_label = $"../../../Player2Info"
		c1pos = $"../../../../Crystal2".global_position
		c2pos = $"../../../../Crystal6".global_position
		c3pos = $"../../../../Crystal5".global_position
	
	for y in troop_grid.size():
		for x in troop_grid[y].size():
			var n = troop_grid[y][x]
			var node = $VBoxContainer/GridContainer.get_node("TroopIcon%d" % n)
			troop_grid[y][x] = [n, node]
	
	for y in range(len(troop_grid)):
		for x in range(len(troop_grid[y])):
			var id = troop_grid[y][x][0] 
			var spot = troop_grid[y][x][1]
			if id - 1 < len(troop_corr):
				var properties = Global.troop_data[troop_corr[id - 1]]
				spot.sprite.texture = load(properties["sprite_path"])
				if properties["type"] == "melee":
					spot.color_rect.color = Color("b4202a")
				elif properties["type"] == "ranged":
					spot.color_rect.color = Color("b4202a")
				elif properties["type"] == "rusher":
					spot.color_rect.color = Color("b4202a")
				elif properties["type"] == "support":
					spot.color_rect.color = Color("b4202a")
				else:
					spot.color_rect.hide()
	update_selection()
	
func _process(delta: float) -> void:
	handle_selection(delta)
	
	var troop_id = troop_grid[selected_coords.y][selected_coords.x][0]
	if troop_id - 1 >= len(troop_corr): return
	var troop_name = troop_corr[troop_id - 1]
	var properties = Global.troop_data
	
	var troop_price = properties["peasant"]["price"]
	
	if money >= troop_price and not on_spawn_cooldown and ((team and Input.is_action_pressed("e")) or (not team and Input.is_action_pressed("o"))):
		money -= troop_price
		on_spawn_cooldown = true
		$TroopSpawnCooldown.start()
		var spawn_pos = c1pos
		if spawnpoints[chosen_point] == "Top": spawn_pos = c2pos
		if spawnpoints[chosen_point] == "Bottom": spawn_pos = c3pos
		game.spawn_troop(troop_name, team, Vector2(spawn_pos.x + 80 * [-1, 1][int(team)], spawn_pos.y))
		
	if (Input.is_action_just_pressed("q") and team) or (Input.is_action_just_pressed("u") and not team):
		chosen_point += 1
		if chosen_point > len(spawnpoints) - 1:
			chosen_point = 0
	
	info_label.text = "$" + str(money) + "
	Selected spawnpoint: " + spawnpoints[chosen_point] + "
	" + ["U", "Q"][int(team)] + " to change spawnpoint"

func handle_selection(delta: float):
	var left = ""
	var right = ""
	var up = ""
	var down = ""
	if not team:
		left = "j"
		right = "l"
		up = "i"
		down = "k"
	else:
		left = "a"
		right = "d"
		up = "w"
		down = "s"
		
	var input_dir = Vector2i.ZERO

	if Input.is_action_pressed(left):
		input_dir.x = -1
	elif Input.is_action_pressed(right):
		input_dir.x = 1
	elif Input.is_action_pressed(up) and selected_coords.y == 1:
		input_dir.y = -1
	elif Input.is_action_pressed(down) and selected_coords.y == 0:
		input_dir.y = 1

	# If new press → move instantly
	if input_dir != Vector2i.ZERO and held_direction != input_dir:
		held_direction = input_dir
		hold_time = 0.0
		repeat_timer = 0.0
		_move_selection(input_dir)
		return

	# If holding same direction
	if input_dir != Vector2i.ZERO:
		hold_time += delta

		if hold_time >= repeat_delay:
			repeat_timer += delta
			if repeat_timer >= repeat_interval:
				repeat_timer = 0.0
				_move_selection(input_dir)
	else:
		# Reset when no input
		held_direction = Vector2i.ZERO
		hold_time = 0.0
		repeat_timer = 0.0
	
func _move_selection(dir: Vector2i):
	selected_coords += dir

	# Wrap X
	if selected_coords.x < 0:
		selected_coords.x = 15
	elif selected_coords.x > 15:
		selected_coords.x = 0

	update_selection()

func update_selection():
	for y in range(len(troop_grid)):
		for x in range(len(troop_grid[y])):
			var spot = troop_grid[y][x][1]
			spot.selection.visible = Vector2i(x, y) == selected_coords
			
			
func _on_troop_spawn_cooldown_timeout() -> void:
	on_spawn_cooldown = false
