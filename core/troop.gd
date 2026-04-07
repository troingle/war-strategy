extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@onready var attack_timer = $AttackTimer

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export var team = true # red is true blue is false

var target = null
var hp = 1.0

var type = "melee"
var max_hp = 10.0
var speed = 150.0
var damage = 1.0
var attack_cooldown = 0.7
var melee_range = 40.0 # non ranged
var ranged_range = 1.0 # ranged

func _ready():
	sprite.material = sprite.material.duplicate()
	if team: 
		sprite.material.set_shader_parameter("color", Color("b4202a")) 
	else: 
		sprite.material.set_shader_parameter("color", Color("285cc4")) 
	
	fit_collider()
	
	attack_timer.wait_time = attack_cooldown
	hp = max_hp

func _physics_process(delta):
	# check for death
	if hp <= 0.0:
		queue_free()
	
	# find target
	nav_agent.target_position = find_target()
	
	# attack if possible
	var dist_from_target = global_position.distance_to(target.global_position)
	if type == "melee" or type == "rusher":
		if dist_from_target < melee_range:
			if attack_timer.is_stopped(): attack_timer.start()
			return
	attack_timer.stop()
	
	
	# navigate
	
	var next_path_position: Vector2 = nav_agent.get_next_path_position()

	var direction: Vector2 = (next_path_position - global_position).normalized()
	sprite.flip_h = direction.x > 0

	velocity = direction * speed
	move_and_slide()
	
	z_index = int(global_position.y)
	
		
	
func find_target():
	var target_candidates = []
	
	if type == "melee":
		for entity in get_tree().get_nodes_in_group("entity"):
			if team != entity.team: target_candidates.append(entity)
	
	var closest_dist = 9999999.0
	var closest_candidate = null
	for candidate in target_candidates:
		var dist = candidate.global_position.distance_to(global_position)
		if dist < closest_dist:
			closest_candidate = candidate
			closest_dist = dist
			
	target = closest_candidate
	return closest_candidate.global_position
	
func fit_collider():
	var tex_size: Vector2 = sprite.texture.get_size()
	var scale: Vector2 = sprite.scale

	var final_size = tex_size * scale

	var shape := collision.shape as RectangleShape2D

	shape.size.x = final_size.x
	shape.size.y = final_size.y / 3.0

	collision.position = Vector2(
		0,
		final_size.y / 2.0 - shape.size.y / 2.0
	)

func _on_attack_timer_timeout() -> void:
	print(target.hp)
	target.hp -= damage
