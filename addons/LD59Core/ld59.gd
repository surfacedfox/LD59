extends Node3D

var gameSequence : SceneDefinition = preload("res://data/LD59SceneOrder.tres")
var activeScene : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_boot_after_main_is_current.call_deferred()


func _boot_after_main_is_current() -> void:
	if gameSequence.sceneOrder.is_empty():
		return
	# Wait one frame so ProjectSettings run/main_scene is current_scene.
	await get_tree().process_frame
	var cur: Node = get_tree().current_scene
	var first: PackedScene = gameSequence.sceneOrder[0]
	if cur != null and first != null and String(cur.scene_file_path) == String(first.resource_path):
		# Main scene is already the first game scene — do not instantiate a second copy under
		# GameMaster (overlapping worlds break physics / camera surf picks).
		if cur.get_parent() != self:
			var p: Node = cur.get_parent()
			if p:
				p.remove_child(cur)
			add_child(cur)
		activeScene = cur
		return
	changeScene(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func animate():
	pass

func changeScene(index: int):
	if(activeScene):
		remove_child(activeScene)
	var newscene = gameSequence.sceneOrder[index].instantiate()
	add_child(newscene)
	activeScene = newscene
