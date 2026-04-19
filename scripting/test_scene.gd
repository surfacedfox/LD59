extends Node3D

@export var Orb = preload("res://subscenes/GenericLight.tscn")


const PARAM_SETS: Array[LightParameters] = [
	preload("res://data/lights/red.tres"),
	preload("res://data/lights/blue.tres"),
	preload("res://data/lights/green.tres"),
	preload("res://data/lights/cyan.tres"),
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	for color in PARAM_SETS:
		var ref: GenericLight = Orb.instantiate()
		ref.light_parameters = color
		add_child(ref)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
