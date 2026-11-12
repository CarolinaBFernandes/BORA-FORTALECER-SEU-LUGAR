
extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_height: float = 65.0
@export var jump_duration: float = 0.5
@export var limite_esquerdo: float = -550.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fim_do_mapa: Marker2D = $"../FimDoMapa"

var is_jumping: bool = false
var jump_timer: float = 0.0

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	velocity.x = direction * speed
	velocity.y = 0

	move_and_slide()

	# Limites do cenário
	global_position.x = clampf(
		global_position.x,
		limite_esquerdo,
		fim_do_mapa.global_position.x
	)

	# Virar personagem
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

	# Iniciar pulo
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		is_jumping = true
		jump_timer = 0.0

	# Animação do pulo
	if is_jumping:
		jump_timer += delta

		var progress = min(jump_timer / jump_duration, 1.0)

		sprite.position.y = -sin(progress * PI) * jump_height
		sprite.play("jump")

		if progress >= 1.0:
			is_jumping = false
			sprite.position.y = 0

	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")
