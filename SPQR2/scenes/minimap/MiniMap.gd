extends Control

func _ready():
	pass

func _on_MapButton_pressed():
	$VBox/HBox/MapButton.pressed = true
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = false

func _on_ArmyButton_pressed():
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = true
	$VBox/HBox/CoinButton.pressed = false

func _on_CoinButton_pressed():
	$VBox/HBox/MapButton.pressed = false
	$VBox/HBox/ArmyButton.pressed = false
	$VBox/HBox/CoinButton.pressed = true
