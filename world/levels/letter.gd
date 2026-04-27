extends Area2D

@export_multiline var lore_text: String = "Escreva aqui a história..."
var can_read: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		can_read = true
		print("Pressione E para ler")

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		can_read = false

func _input(event: InputEvent):
	if can_read and event.is_action_pressed("interagir"):
		
		# O "true, false" é a mágica:
		# true = procura dentro de todos os nós recursivamente
		# false = ignora a regra de "dono" da cena, vasculhando até dentro do Player
		var hud = get_tree().current_scene.find_child("HUD", true, false)
		
		if hud:
			print("SUCESSO: HUD encontrado! Abrindo a carta...")
			hud.show_letter(lore_text)
		else:
			# Se cair aqui, é porque o nome do nó está diferente de "HUD"
			print("ERRO: O nó 'HUD' não foi encontrado. Verifique se o nome está escrito com letras maiúsculas!")
