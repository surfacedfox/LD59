extends Node3D


const GENERIC_LIGHT = preload("res://subscenes/GenericLight.tscn")
var light_configs: Array[Callable] = []

var draggable_lights_by_config: Dictionary[int, Array] # Array[GenericLight]
@onready var draggable_lights_container: Node3D = get_node("draggable_lights")

var solution_lights_by_config: Dictionary[int, Array] # Array[GenericLight]
@onready var solution_lights_container: Node3D = get_node("solution_lights")

var number_of_lights: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_of_lights = 3
	create_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_game() -> void:
	print("Creating game")
	for i in range(number_of_lights):
		var light_index = rng.randi_range(0, self.light_configs.size() - 1)
		var dragx = rng.randf_range(-1.2, 1.2)
		var dragz = rng.randf_range(-0.6, 0.6)
		var solnx = rng.randf_range(-1.2, 1.2)
		var solnz = rng.randf_range(-0.6, 0.6)

		var draggable_light_config = self.light_configs[light_index]
		var draggable_light_object: GenericLight = GENERIC_LIGHT.instantiate()
		var dnd = DraggingObject3D.new()
		dnd.transform.origin.x = dragx
		dnd.transform.origin.z = dragz
		draggable_lights_container.add_child(dnd)
		dnd.add_child(draggable_light_object)
		draggable_light_config.call(draggable_light_object)

		var solution_light_config = self.light_configs[light_index]
		var solution_light_object: GenericLight = GENERIC_LIGHT.instantiate()
		solution_lights_container.add_child(solution_light_object)
		solution_light_object.transform.origin.x = solnx
		solution_light_object.transform.origin.z = solnz
		solution_light_config.call(solution_light_object)
		solution_light_object.light_node.light_color = Color(0.3, 0.3, 0.3)
		solution_light_object.input_ray_pickable = false


func _on_set_num_lights_f(value: float) -> void:
	self.number_of_lights = floori(value)
