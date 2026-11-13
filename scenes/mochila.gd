extends Area2D


@export var mensagem_noticia: String = "A praça está sem iluminação há três dias. +1 sinal"

var player_perto: Node2D = null
var ja_interagiu: bool = false
var label_noticia: Label = null

func _ready() -> void:
	# Cria o texto automaticamente via código
	label_noticia = Label.new()
	label_noticia.text = mensagem_noticia
	
	# Ajusta o tamanho da letra para pixel art (8px) e coloca na frente do cenário
	label_noticia.add_theme_font_size_override("font_size", 8)
	label_noticia.z_index = 10
	
	# Posiciona o texto um pouco acima da mochila
	label_noticia.position = Vector2(-60, -30)
	label_noticia.visible = false
	
	# Adiciona o texto dentro da Mochila
	add_child(label_noticia)

func _process(_delta: float) -> void:
	if player_perto != null and not ja_interagiu and Input.is_physical_key_pressed(KEY_E):
		interagir()

func interagir() -> void:
	ja_interagiu = true
	
	# 1. Mostra a notícia que o código criou
	label_noticia.visible = true
	
	# 2. Esconde o desenho da mochila
	for filho in get_children():
		if filho is Sprite2D:
			filho.visible = false
	
	# 3. Soma 13 pontos no GameManager (sobe 1 barrinha inteira)
	GameManager.alterar_sinal(13)
		
	# 4. Espera o tempo de leitura e apaga tudo
	await get_tree().create_timer(6.0).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = body

func _on_mochila_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = body

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = null

func _on_mochila_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_perto = null
