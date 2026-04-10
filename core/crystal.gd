extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@export var team = true

var hp = 20.0

func _ready() -> void:
	if team:  
		sprite.self_modulate = Color("b4202a")
	else:  
		sprite.self_modulate = Color("467ee9ff")
