extends Node3D

@export var Orb = preload("res://subscenes/red.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var ref = Orb.instantiate()
	add_child(ref)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
