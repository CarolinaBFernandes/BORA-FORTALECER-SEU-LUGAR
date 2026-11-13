
extends CharacterBody2D

@export var speed: float = 80.0
@export var jump_height: float = 65.0
@export var jump_duration: float = 0.5
@export var limite_esquerdo: float = -550.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fim_do_mapa: Marker2D = get_node_or_null("../FimDoMapa")
@onready var sinal_wifi: AnimatedSprite2D = $SinalWifi

var is_jumping: bool = false
var jump_timer: float = 0.0
var wifi_y_inicial: float = 0.0


func _ready() -> void:
	if sinal_wifi != null:
		wifi_y_inicial = sinal_wifi.position.y


func _physics_process(delta: float) -> void:

	# MOVIMENTO HORIZONTAL
	var direction = Input.get_axis("ui_left", "ui_right")

	velocity.x = direction * speed
	velocity.y = 0.0

	move_and_slide()

	# LIMITES DO CENÁRIO
	var limite_direito = INF

	if is_instance_valid(fim_do_mapa):
		limite_direito = fim_do_mapa.global_position.x

	global_position.x = clampf(
		global_position.x,
		limite_esquerdo,
		limite_direito
	)

	# VIRAR PERSONAGEM
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

	# INICIAR PULO
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		is_jumping = true
		jump_timer = 0.0

	# ANIMAÇÃO DO PULO
	if is_jumping:
		jump_timer += delta

		var progress = minf(jump_timer / jump_duration, 1.0)

		sprite.position.y = -sin(progress * PI) * jump_height

		if sinal_wifi != null:
			sinal_wifi.position.y = wifi_y_inicial + sprite.position.y

		sprite.play("jump")

		if progress >= 1.0:
			is_jumping = false
			sprite.position.y = 0.0

			if sinal_wifi != null:
				sinal_wifi.position.y = wifi_y_inicial

	# ANIMAÇÕES DE MOVIMENTO
	elif direction != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

	# ATUALIZAR SINAL DE WI-FI
	if sinal_wifi != null:
		var valor = GameManager.sinal_credibilidade

		if valor < 12:
			sinal_wifi.frame = 0
		elif valor < 25:
			sinal_wifi.frame = 1
		elif valor < 37:
			sinal_wifi.frame = 2
		elif valor < 50:
			sinal_wifi.frame = 3
		elif valor < 62:
			sinal_wifi.frame = 4
		elif valor < 75:
			sinal_wifi.frame = 5
		elif valor < 87:
			sinal_wifi.frame = 6
		else:
			sinal_wifi.frame = 7


func _on_barril_portal_body_entered(body: Node2D) -> void:
	pass
