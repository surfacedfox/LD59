@tool
class_name GenericLight extends DraggingObject3D


@export var light_parameters: LightParameters


@onready var light_node: SpotLight3D = get_node("body/light")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


func _process(delta: float) -> void:
	self.light_node.light_projector = self.light_parameters.light_projector
	self.light_node.light_color = self.light_parameters.light_color
	self.light_node.light_energy = self.light_parameters.light_energy
