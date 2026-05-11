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


## Swap the active scene to an arbitrary packed root (e.g. after camera-surf ending). Root must be [Node3D].
func change_scene_to_packed(packed: PackedScene) -> void:
	if packed == null:
		push_warning("GameMaster.change_scene_to_packed: PackedScene is null.")
		return
	if activeScene:
		remove_child(activeScene)
		activeScene.queue_free()
	var newscene: Node3D = packed.instantiate() as Node3D
	if newscene == null:
		push_error("GameMaster.change_scene_to_packed: scene root must be Node3D.")
		return
	add_child(newscene)
	activeScene = newscene
