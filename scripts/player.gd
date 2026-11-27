extends CharacterBody2D

@export var speed: float = 80.0
@export var jump_velocity: float = -210.0 # Força do pulo para cima (negativo sobe)
@export var gravity: float = 520.0 # Gravidade puxando para baixo
@export var limite_esquerdo: float = -550.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fim_do_mapa: Marker2D = get_node_or_null("../FimDoMapa")
@onready var sinal_wifi: AnimatedSprite2D = $SinalWifi


func _physics_process(delta: float) -> void:
	# GRAVIDADE REAL NO CORPO TODO
	if not is_on_floor():
		velocity.y += gravity * delta

	# INICIAR PULO (SÓ QUANDO ESTIVER PISANDO NO CHÃO OU PLATAFORMA)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# MOVIMENTO HORIZONTAL
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	# MOVE O CORPO E A COLISÃO JUNTOS
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

	# ANIMAÇÕES
	if not is_on_floor():
		sprite.play("jump")
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


func _on_npc_praca_body_exited(body: Node2D) -> void:
	pass


func _on_npc_praca_body_entered(body: Node2D) -> void:
	pass
