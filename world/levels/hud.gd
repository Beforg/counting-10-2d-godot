extends CanvasLayer

# @onready garante que o código espera os textos carregarem antes de tentar usá-los
@onready var gas_label = $TextGasoline
@onready var dollar_label = $TextDolar
@onready var torch_label = $TextTorchRefil
@onready var terror_bar = $TerrorBar

func _process(_delta: float) -> void:
	# Atualiza os textos na tela com os valores reais do GameManager
	gas_label.text = "Galões: " + str(GameManager.gasoline_count) + " / 10"
	dollar_label.text = "Dólares: $" + str(GameManager.dollars)
	torch_label.text = "Tocha: " + str(GameManager.torch_refills)
	terror_bar.value = GameManager.terror_level
