extends CharacterBody2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var anim = $AnimationPlayer
@onready var attack_timer = $AttackTimer
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var team = true

var target = null
var target_pos = Vector2.ZERO

var hp = 1.0
var type = "melee"
var max_hp = 4.0
var speed = 150.0
var damage = 1.0
var attack_cooldown = 0.7
var attack_range = 50.0

func _ready():
	sprite.material = sprite.material.duplicate()
	if team:
		sprite.material.set_shader_parameter("color", Color("b4202a"))
	else:
		sprite.material.set_shader_parameter("color", Color("285cc4"))

	fit_collider()
	attack_timer.wait_time = attack_cooldown
	hp = max_hp
	nav_agent.max_speed = speed

	nav_agent.velocity_computed.connect(_on_velocity_computed)

func _physics_process(delta):
	if hp <= 0.0:
		queue_free()
	
	find_target()
	nav_agent.target_position = target_pos

	var dist_from_target = global_position.distance_to(target_pos)
	if dist_from_target < attack_range:
		if attack_timer.is_stopped():
			attack_timer.start()
		nav_agent.set_velocity(Vector2.ZERO)
		return

	attack_timer.stop()

	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = (next_path_position - global_position).normalized()
	sprite.flip_h = direction.x > 0
	anim.play("walk")
	z_index = int(global_position.y)

	nav_agent.set_velocity(direction * speed)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	
func find_target():
	var target_candidates = []
	
	if type == "melee":
		for entity in get_tree().get_nodes_in_group("entity"):
			if team != entity.team: target_candidates.append(entity)
	
	var closest_dist = INF
	var closest_candidate = null
	for candidate in target_candidates:
		var dist = candidate.collision.global_position.distance_to(global_position)
		if dist < closest_dist:
			closest_candidate = candidate
			closest_dist = dist
			
	target = closest_candidate
	target_pos = target.collision.global_position
	
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
	if type == "melee" or type == "rusher":
		if target: target.hp -= damage
	elif type == "ranged":
		pass
	elif type == "support":
		pass
	
	if sprite.flip_h: anim.play("attack_right")
	else: anim.play("attack_left")
	
	
