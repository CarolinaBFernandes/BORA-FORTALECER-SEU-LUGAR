extends Area2D



var jogador_perto: bool = false
var balao_atual = null

func _input(event: InputEvent) -> void:
	if jogador_perto and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			print("Apertou E perto do NPC!")
			if not is_instance_valid(balao_atual):
				balao_atual = SpeechBalloon.new()
				balao_atual.max_width = 100.0
				balao_atual.font_size = 5
				balao_atual.z_index = 90
				get_parent().add_child(balao_atual)
				balao_atual.global_position = $CollisionShape2D.global_position + Vector2(0, -15)
				balao_atual.say("Silvio Santos publicou uma foto em São Sebastião do alto. (Não há ganho de sinal)")
				print("Balao criado em: ", balao_atual.global_position)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = false
		if is_instance_valid(balao_atual):
			balao_atual.queue_free()
