extends Area2D

@export var mensagem_noticia: String = "A praça está sem iluminação há três dias. +1 sinal"

var player_perto: Node2D = null
var ja_interagiu: bool = false
var label_noticia: Label = null
var tween_brilho: Tween = null

func _ready() -> void:
	var centro_mochila: Vector2 = $Sprite2D.position

	# 1. Cria o texto da notícia centralizado abaixo da mochila no banco
	label_noticia = Label.new()
	label_noticia.text = mensagem_noticia
	label_noticia.add_theme_font_size_override("font_size", 8)
	label_noticia.add_theme_color_override("font_color", Color.WHITE)
	label_noticia.add_theme_color_override("font_outline_color", Color.BLACK)
	label_noticia.add_theme_constant_override("outline_size", 2)
	label_noticia.z_index = 20
	label_noticia.position = centro_mochila + Vector2(-20, 16)
	label_noticia.visible = false
	add_child(label_noticia)

	# 2. Animação de flutuação do Sprite2D da mochila
	var tween_mochila := create_tween().set_loops()
	var y_inicial: float = $Sprite2D.position.y
	tween_mochila.tween_property($Sprite2D, "position:y", y_inicial - 4.0, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween_mochila.tween_property($Sprite2D, "position:y", y_inicial, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 3. Conecta automaticamente a área maior de brilho, se existir na cena
	if has_node("AreaBrilho"):
		$AreaBrilho.body_entered.connect(_on_area_brilho_body_entered)
		$AreaBrilho.body_exited.connect(_on_area_brilho_body_exited)

func _input(event: InputEvent) -> void:
	if player_perto != null and not ja_interagiu and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			interagir()

func ativar_brilho(ativo: bool) -> void:
	if is_instance_valid(tween_brilho):
		tween_brilho.kill()
	
	if ativo:
		tween_brilho = create_tween().set_loops()
		tween_brilho.tween_property($Sprite2D, "modulate", Color(1.6, 1.5, 1.1, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_brilho.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		$Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)

func interagir() -> void:
	ja_interagiu = true
	ativar_brilho(false)
	label_noticia.visible = true
	
	for filho in get_children():
		if filho is Sprite2D:
			filho.visible = false
	
	GameManager.alterar_sinal(13)
	
	await get_tree().create_timer(6.0).timeout
	queue_free()

# Área maior: controla apenas o brilho à distância
func _on_area_brilho_body_entered(body: Node2D) -> void:
	if (body.name == "Player" or body is CharacterBody2D) and not ja_interagiu:
		ativar_brilho(true)

func _on_area_brilho_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		ativar_brilho(false)

# Área menor (própria Mochila): libera a interação com a tecla E
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		player_perto = body
		if not has_node("AreaBrilho") and not ja_interagiu:
			ativar_brilho(true)

func _on_mochila_body_entered(body: Node2D) -> void:
	_on_body_entered(body)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player" or body is CharacterBody2D:
		player_perto = null
		if not has_node("AreaBrilho"):
			ativar_brilho(false)

func _on_mochila_body_exited(body: Node2D) -> void:
	_on_body_exited(body)
