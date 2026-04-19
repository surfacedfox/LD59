class_name ImageSingleton extends Node


var textures: Dictionary[String, Texture2D] = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in range(7):
		var full_name = "shape_" + String.chr(97 + c)
		textures[full_name] = load("res://textures/" + full_name + ".png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
