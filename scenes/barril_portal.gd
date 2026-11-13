extends Area2D

const CENA_DA_PRACA = "res://scenes/zona_1_praca.tscn"

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem tocou na tampa do barril foi o jogador
	if body.name == "Player":
		# Verifica se o jogador está acima do barril (pulando em cima)
		if body.global_position.y < global_position.y:
			get_tree().call_deferred("change_scene_to_file", CENA_DA_PRACA)

func _on_body_exited(body: Node2D) -> void:
	# Opcional: Aqui você pode colocar algum aviso visual de "saiu do portal" 
	# se estiver a mostrar alguma dica na tela. Caso contrário, pode deixar com 'pass'.
	pass
