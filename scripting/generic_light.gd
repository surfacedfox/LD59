@tool
class_name GenericLight extends DraggingObject3D


@onready var light_node: SpotLight3D = get_node("body/light")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
