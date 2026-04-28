extends Control

func _ready() -> void:
	# Toca a animação que criamos
	$AnimationPlayer.play("vitoria")
	
	# Espera 6 segundos (tempo da animação + leitura) e volta ao menu
	await get_tree().create_timer(6.0).timeout
	get_tree().change_scene_to_file("res://main-menu.tscn")
