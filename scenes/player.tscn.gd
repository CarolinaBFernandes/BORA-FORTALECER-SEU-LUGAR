extends AnimatedSprite2D

var speed = 150 # Você pode aumentar ou diminuir a velocidade aqui

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += speed * delta # Move para a direita
		play("walk")
		flip_h = false 
	elif Input.is_action_pressed("ui_left"):
		position.x -= speed * delta # Move para a esquerda
		play("walk")
		flip_h = true 
	else:
		play("idle")
