extends Area2D

@export var mensagem: String = "A obra da cidade começa segunda-feira. (+1 sinal)"
@export var pontos_wifi: int = 13

var jogador_perto: bool = false
var player_ref: Node2D = null
var ja_usou: bool = false


func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if jogador_perto and not ja_usou and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			ja_usou = true

			# Sobe 1 barra visual do Wi-Fi (+13 pontos no GameManager)
			GameManager.alterar_sinal(pontos_wifi)

			# Cria o mesmo texto flutuante do avião de papel acima do Player
			var label_noticia := Label.new()
			label_noticia.text = mensagem
			label_noticia.add_theme_font_size_override("font_size", 8)
			label_noticia.add_theme_color_override("font_color", Color.WHITE)
			label_noticia.add_theme_color_override("font_outline_color", Color.BLACK)
			label_noticia.add_theme_constant_override("outline_size", 2)
			label_noticia.z_index = 100
			get_tree().current_scene.add_child(label_noticia)

			var pos_base := player_ref.global_position if is_instance_valid(player_ref) else global_position
			label_noticia.global_position = pos_base + Vector2(-45, -26)

			await get_tree().create_timer(5.0).timeout
			if is_instance_valid(label_noticia):
				label_noticia.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = true
		player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = false
