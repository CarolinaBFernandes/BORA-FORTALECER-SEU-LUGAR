extends AnimatedSprite2D

var speed = 150
var jump_force = -300 # Valor negativo faz o personagem subir
var gravity = 800
var velocity_y = 0
var is_jumping = false
var floor_y = 0

func _ready():
	# Salva a posição vertical inicial como sendo o "chão"
	floor_y = position.y 

func _process(delta):
	# 1. SISTEMA DE PULO E GRAVIDADE
	if is_jumping:
		velocity_y += gravity * delta # A gravidade puxa para baixo
		position.y += velocity_y * delta # Move o personagem no eixo Y
		
		# Se passou da linha do chão, ele aterriza
		if position.y >= floor_y:
			position.y = floor_y
			is_jumping = false
			velocity_y = 0
			
	# Iniciar o pulo (apertando a seta para cima ou espaço)
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_accept"):
		is_jumping = true
		velocity_y = jump_force

	# 2. MOVIMENTO HORIZONTAL
	var is_moving = false
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta
		flip_h = false 
		is_moving = true
	elif Input.is_action_pressed("ui_left"):
		position.x -= speed * delta
		flip_h = true 
		is_moving = true

	# 3. CONTROLE DE ANIMAÇÕES
	if is_jumping:
		play("jump") # Toca a animação de pulo se estiver no ar
	elif is_moving:
		play("walk") # Toca a de andar se estiver no chão e se movendo
	else:
		play("idle") # Toca a parada se não estiver fazendo nada
