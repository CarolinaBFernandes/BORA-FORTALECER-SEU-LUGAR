extends Area2D

@export_multiline var fala_npc: String = "Silvio Santos publicou uma foto em São Sebastião do alto. (Não há ganho de sinal)"
@export_multiline var pensamento_player: String = ""
@export var velocidade_texto: float = 22.0
@export var tempo_leitura_npc: float = 3.5
@export var tempo_leitura_pensamento: float = 5.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var jogador_perto: bool = false
var player_ref: Node2D = null
var balao_atual = null
var balao_pensamento = null
var tween_brilho: Tween = null
var ja_interagiu: bool = false


func _ready() -> void:
	iniciar_brilho()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_instance_valid(balao_pensamento) and is_instance_valid(player_ref):
		balao_pensamento.global_position = player_ref.global_position + Vector2(0, -28)


func iniciar_brilho() -> void:
	if sprite == null:
		return
	tween_brilho = create_tween().set_loops()
	tween_brilho.tween_property(sprite, "modulate", Color(1.35, 1.3, 1.1, 1.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_brilho.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func parar_brilho() -> void:
	if tween_brilho != null:
		tween_brilho.kill()
		tween_brilho = null
	if sprite != null:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _input(event: InputEvent) -> void:
	if jogador_perto and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if not ja_interagiu:
				ja_interagiu = true
				parar_brilho()
			if not is_instance_valid(balao_atual):
				balao_atual = SpeechBalloon.new()
				balao_atual.style = "speech"
				balao_atual.max_width = 100.0
				balao_atual.font_size = 5
				balao_atual.chars_per_second = velocidade_texto
				balao_atual.z_index = 90
				get_parent().add_child(balao_atual)
				balao_atual.global_position = $CollisionShape2D.global_position + Vector2(0, -15)
				balao_atual.say(fala_npc)

				if pensamento_player.strip_edges() != "" and not is_instance_valid(balao_pensamento):
					mostrar_pensamento_player()


func mostrar_pensamento_player() -> void:
	if is_instance_valid(balao_atual):
		await balao_atual.finished_typing
	await get_tree().create_timer(tempo_leitura_npc).timeout

	if is_instance_valid(balao_atual):
		balao_atual.queue_free()

	if not is_instance_valid(player_ref):
		return

	balao_pensamento = SpeechBalloon.new()
	balao_pensamento.style = "speech"
	balao_pensamento.palette = "light"
	balao_pensamento.max_width = 110.0
	balao_pensamento.font_size = 5
	balao_pensamento.chars_per_second = velocidade_texto
	balao_pensamento.z_index = 100
	get_parent().add_child(balao_pensamento)
	balao_pensamento.global_position = player_ref.global_position + Vector2(0, -28)
	balao_pensamento.say("(Pensando) " + pensamento_player)

	await balao_pensamento.finished_typing
	await get_tree().create_timer(tempo_leitura_pensamento).timeout
	if is_instance_valid(balao_pensamento):
		balao_pensamento.queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = true
		player_ref = body


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		jogador_perto = false
		if is_instance_valid(balao_atual):
			balao_atual.queue_free()
