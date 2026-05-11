class_name SurveillanceCamera
extends Node3D

const GROUP := "surveillance_camera"

## If true, joins group [code]surf_entry[/code]; [CameraSurfManager] picks the first of those when auto-starting.
@export var is_entry: bool = false
@export var look_enabled: bool = true
@export var look_sensitivity: float = 0.0025
## If set, plays once the first time you land on this camera (including auto-start entry). Same pattern as [SurfInteractable].
@export var first_visit_dialogue: DialogueData
@export var first_visit_start_id: String = "intro"

@export_group("End camera")
## Final surveillance shot: no look, plays [member end_dialogue] when entered; after it finishes, the game fades out and loads [member end_scene].
@export var is_end_camera: bool = false
@export var end_dialogue: DialogueData
@export var end_dialogue_start_id: String = "intro"
@export var end_scene: PackedScene

var _authored_root_transform: Transform3D
var _authored_camera_transform: Transform3D
var _has_authored_snapshot: bool = false


func _enter_tree() -> void:
	if is_end_camera:
		look_enabled = false
		if end_dialogue == null:
			push_error("SurveillanceCamera '%s': is_end_camera requires end_dialogue." % name)
		if end_scene == null:
			push_error("SurveillanceCamera '%s': is_end_camera requires end_scene." % name)
	add_to_group(GROUP)
	if is_entry:
		add_to_group("surf_entry")
	CameraSurfManager.register(self)
	call_deferred(&"_deferred_snapshot_authored")


func _exit_tree() -> void:
	CameraSurfManager.unregister(self)


## Reset root and [Camera3D] to the transform captured from the scene (after one deferred frame in [method _enter_tree]).
func restore_authored_view() -> void:
	if not _has_authored_snapshot:
		return
	transform = _authored_root_transform
	var cam := get_view_camera()
	if cam:
		cam.transform = _authored_camera_transform


func _deferred_snapshot_authored() -> void:
	if _has_authored_snapshot or not is_inside_tree():
		return
	_authored_root_transform = transform
	var cam := get_view_camera()
	if cam:
		_authored_camera_transform = cam.transform
	_has_authored_snapshot = true


func get_view_camera() -> Camera3D:
	return get_node_or_null("Camera3D") as Camera3D


func get_audio_listener() -> AudioListener3D:
	return get_node_or_null("Camera3D/AudioListener3D") as AudioListener3D


func apply_look_delta(relative: Vector2) -> void:
	if is_end_camera or not look_enabled:
		return
	var sens := look_sensitivity
	var cam := get_view_camera()
	if not cam:
		return
	# Local-space look: yaw around this node's up, pitch around the camera's right (not world axes / euler .x on child).
	rotate_object_local(Vector3.UP, -relative.x * sens)
	cam.rotate_object_local(Vector3.RIGHT, -relative.y * sens)
