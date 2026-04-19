@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("GameMaster", "res://addons/LD59Core/ld59.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("GameMaster")
