extends CanvasLayer

# @onready garante que o código espera os textos carregarem antes de tentar usá-los
@onready var gas_label = $VBoxContainer/TextGasoline
@onready var dollar_label = $VBoxContainer/TextDolar
@onready var torch_label = $VBoxContainer/TextTorchRefil
@onready var terror_bar = $TerrorBar
@onready var letter_panel = $LetterPanel
@onready var letter_label = $LetterPanel/LetterText
@onready var adrenaline_label = $VBoxContainer/Adrenalina 
@onready var gas_icon = $VBoxContainer/GasolineIcon
@onready var cure_label = $VBoxContainer/TextCura
@onready var status_label = $VBoxContainer/TextStatus
@onready var adrenaline_timer_label = $VBoxContainer/TextAdrenalineTimer

@export var gasoline_images: Array[Texture2D]
func _process(_delta: float) -> void:
	# Atualiza os textos na tela com os valores reais do GameManager
	gas_label.text = "Galões: " + str(GameManager.gasoline_count) + " / 10"
	dollar_label.text = "Dólares: $" + str(GameManager.dollars)
	torch_label.text = "Tocha: " + str(GameManager.torch_refills)
	terror_bar.value = GameManager.terror_level
	adrenaline_label.text = "Adrenalina:" + str(GameManager.adrenaline_count)
	
	if gasoline_images.size() > 0:
		var current_index = clamp(GameManager.gasoline_count, 0, gasoline_images.size() - 1)
		gas_icon.texture = gasoline_images[current_index]
	cure_label.text = "Curas: " + str(GameManager.cures_count)
	if GameManager.adrenaline_time_left > 0:
		# int() remove as casas decimais para a tela ficar limpa (ex: 5s em vez de 5.342s)
		adrenaline_timer_label.text = "Efeito Adrenalina: " + str(int(GameManager.adrenaline_time_left)) + "s"
		adrenaline_timer_label.visible = true
	else:
		adrenaline_timer_label.visible = false # Esconde quando o efeito acaba
		
	if GameManager.is_addicted:
		status_label.text = "Estado: VICIADO"
		status_label.modulate = Color(1, 0, 0) # Vermelho
	elif GameManager.terror_level >= 60:
		status_label.text = "Estado: EM PÂNICO"
		status_label.modulate = Color(1, 0.5, 0) # Laranja
	else:
		status_label.text = "Estado: NORMAL"
		status_label.modulate = Color(0, 1, 0) # Verde

func show_letter(content: String):
	print("HUD: Recebi o texto: ", content) # Verifique se o texto chegou
	letter_label.text = content
	letter_panel.visible = true
	print("HUD: Visibilidade do painel agora é: ", letter_panel.visible)
	get_tree().paused = true
