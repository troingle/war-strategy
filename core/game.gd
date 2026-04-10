extends Node2D

@onready var troop_obj = load("res://core/troop.tscn")
@onready var troop_data = Global.troop_data
	
func _ready() -> void:
	pass

func spawn_troop(troop_name, team, spawn_pos):
	var troop = troop_obj.instantiate()
	troop.team = team
	troop.global_position = spawn_pos
	
	var properties = troop_data[troop_name]
	troop.max_hp = properties["max_hp"]
	troop.type = properties["type"]
	troop.speed = properties["speed"]
	troop.damage = properties["damage"]
	troop.attack_cooldown = properties["attack_cooldown"]
	troop.attack_range = properties["attack_range"]
	
	add_child(troop)
	
	
