extends Area2D

@export var mensagem_noticia: String = "Biblioteca comunitária funciona até as 18h. +1 sinal"
@export var pontos_wifi: int = 13
@export var amplitude_voo_x: float = 18.0
@export var amplitude_voo_y: float = 6.0
@export var velocidade_voo: float = 2.5

@onready var sprite: Sprite2D = $Sprite2D

var tempo: float = 0.0
var posicao_inicial: Vector2
var ja_coletado: bool = false
var tween_brilho: Tween = null


func _ready() -> void:
	posicao_inicial = position
	iniciar_brilho()

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if ja_coletado:
		return

	tempo += delta

	var deslocamento_x = sin(tempo * velocidade_voo) * amplitude_voo_x
	var deslocamento_y = sin(tempo * velocidade_voo * 2.0) * amplitude_voo_y
	position = posicao_inicial + Vector2(deslocamento_x, deslocamento_y)

	var direcao_x = cos(tempo * velocidade_voo)
	sprite.flip_h = direcao_x < 0
	sprite.rotation = direcao_x * 0.15


func iniciar_brilho() -> void:
	if sprite == null:
		return
	tween_brilho = create_tween().set_loops()
	tween_brilho.tween_property(sprite, "modulate", Color(1.6, 1.5, 1.1, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_brilho.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node2D) -> void:
	if ja_coletado:
		return
	if body.name == "Player" or body is CharacterBody2D:
		ja_coletado = true

		if is_instance_valid(tween_brilho):
			tween_brilho.kill()

		sprite.visible = false
		$CollisionShape2D.set_deferred("disabled", true)

		# Cria o Label direto na cena principal para não herdar Scale pequeno do avião
		var label_noticia = Label.new()
		label_noticia.text = mensagem_noticia
		label_noticia.add_theme_font_size_override("font_size", 8)
		label_noticia.add_theme_color_override("font_color", Color.WHITE)
		label_noticia.add_theme_color_override("font_outline_color", Color.BLACK)
		label_noticia.add_theme_constant_override("outline_size", 2)
		label_noticia.z_index = 100
		get_tree().current_scene.add_child(label_noticia)
		label_noticia.global_position = body.global_position + Vector2(-25, -24)

		GameManager.alterar_sinal(pontos_wifi)

		await get_tree().create_timer(6.0).timeout
		if is_instance_valid(label_noticia):
			label_noticia.queue_free()
		queue_free()
