extends Area2D

@export_multiline var letter_text: String = "Escreva a história aqui..."
var player_near: bool = false

func _input(event: InputEvent) -> void:
	if player_near and event.is_action_pressed("interagir"): # Configure a tecla 'E' no Input Map
		_show_letter()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true
		# Opcional: mostrar um "Aperte E para ler" na tela

func _on_body_removed(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false

func _show_letter():
	# Acesse o HUD para mostrar o texto e pausar o jogo
	var hud = get_tree().current_scene.find_child("HUD")
	hud.show_letter(letter_text)
