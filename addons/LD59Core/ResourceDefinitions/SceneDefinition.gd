class_name SceneDefinition
extends Resource

@export var sceneOrder: Array[PackedScene]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_sceneOrder : Array[PackedScene] = []):
	sceneOrder = p_sceneOrder
