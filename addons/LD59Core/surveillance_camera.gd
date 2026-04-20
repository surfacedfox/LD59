class_name SurveillanceCamera
extends Node3D

const GROUP := "surveillance_camera"

## If true, joins group [code]surf_entry[/code]; [CameraSurfManager] picks the first of those when auto-starting.
@export var is_entry: bool = false
@export var look_enabled: bool = true
@export var look_sensitivity: float = 0.0025
@export var min_pitch_deg: float = -55.0
@export var max_pitch_deg: float = 55.0
## If set, plays once the first time you land on this camera (including auto-start entry). Same pattern as [SurfInteractable].
@export var first_visit_dialogue: DialogueData
@export var first_visit_start_id: String = "intro"

var _look_pitch_rad: float = 0.0


func _ready() -> void:
	var cam := get_view_camera()
	if cam:
		_look_pitch_rad = cam.rotation.x


func _enter_tree() -> void:
	add_to_group(GROUP)
	if is_entry:
		add_to_group("surf_entry")
	CameraSurfManager.register(self)


func _exit_tree() -> void:
	CameraSurfManager.unregister(self)


func get_view_camera() -> Camera3D:
	return get_node_or_null("Camera3D") as Camera3D


func apply_look_delta(relative: Vector2) -> void:
	if not look_enabled:
		return
	var sens := look_sensitivity
	rotate_y(-relative.x * sens)
	_look_pitch_rad = clampf(
		_look_pitch_rad - relative.y * sens,
		deg_to_rad(min_pitch_deg),
		deg_to_rad(max_pitch_deg),
	)
	var cam := get_view_camera()
	if cam:
		cam.rotation.x = _look_pitch_rad
