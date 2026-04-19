extends Node3D

var gameSequence : SceneDefinition = preload("res://data/LD59SceneOrder.tres")
var activeScene : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func animate():
	pass

func changeScene(index: int):
	if(activeScene):
		remove_child(activeScene)
	var newscene = gameSequence.sceneOrder[index].instantiate()
	add_child(newscene)
	activeScene = newscene
