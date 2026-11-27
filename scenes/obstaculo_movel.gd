extends Area2D

@export var textura_item: Texture2D 
@export var mensagem_noticia: String = "Boato! Torneio da praça foi cancelado—fonte: ouvi dizer! (-1 sinal)"
@export var valor_sinal: int = -13 # Negativo = tira 1 barrinha de sinal
@export var distancia_patrulha: float = 28.0
@export var velocidade: float = 25.0
@export var girar_sprite: bool = false # girar ou nao a bola

var direcao: int = 1
var pos_x_inicial: float = 0.0
var ja_coletou: bool = false
var label_noticia: Label = null
var tween_brilho: Tween = null

func _ready() -> void:
	pos_x_inicial = position.x

	
	if textura_item != null:
		$Sprite2D.texture = textura_item

	body_entered.connect(_on_body_entered)

	# Cria o texto da notícia com contorno pixel art
	label_noticia = Label.new()
	label_noticia.text = mensagem_noticia
	label_noticia.add_theme_font_size_override("font_size", 8)
	label_noticia.add_theme_color_override("font_color", Color.WHITE)
	label_noticia.add_theme_color_override("font_outline_color", Color.BLACK)
	label_noticia.add_theme_constant_override("outline_size", 2)
	label_noticia.z_index = 20
	label_noticia.position = Vector2(-55, -26)
	label_noticia.visible = false
	add_child(label_noticia)

	
	# Brilho vermelho mais claro e suave
	tween_brilho = create_tween().set_loops()
	tween_brilho.tween_property($Sprite2D, "modulate", Color(1.45, 0.72, 0.72, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_brilho.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if ja_coletou:
		return

	position.x += direcao * velocidade * delta

	if girar_sprite:
		$Sprite2D.rotation += direcao * 4.0 * delta

	if position.x >= pos_x_inicial + distancia_patrulha:
		position.x = pos_x_inicial + distancia_patrulha
		direcao = -1
	elif position.x <= pos_x_inicial - distancia_patrulha:
		position.x = pos_x_inicial - distancia_patrulha
		direcao = 1

func _on_body_entered(body: Node2D) -> void:
	if ja_coletou:
		return

	if body.name == "Player" or body is CharacterBody2D:
		coletar()

func coletar() -> void:
	ja_coletou = true

	if is_instance_valid(tween_brilho):
		tween_brilho.kill()

	$Sprite2D.visible = false
	label_noticia.visible = true

	GameManager.alterar_sinal(valor_sinal)

	await get_tree().create_timer(4.0).timeout
	queue_free()
	
