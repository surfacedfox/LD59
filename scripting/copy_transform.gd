extends Node3D

@export var Target: Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	transform = Target.transform
