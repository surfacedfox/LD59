class_name SurfInteractable
extends StaticBody3D

## Put this on a [StaticBody3D] (or replace root type) on physics layer 9 ([code]CameraSurfWorldInteract[/code]). Ray confirm plays this graph.
@export var dialogue_data: DialogueData = preload("res://data/test_dialog.tres")
@export var dialogue_start_id: String = "intro"
