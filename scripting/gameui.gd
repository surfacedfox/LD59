extends Control

var nextButton : Button
var num : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameMaster.changeScene(num)
	nextButton = get_node("%NextButton")
	nextButton.pressed.connect(_next_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _next_pressed():
	GameMaster.changeScene(num)
	num = num + 1
