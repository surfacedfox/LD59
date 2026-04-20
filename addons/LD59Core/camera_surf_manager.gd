extends Node

## Collision layer bit for StaticBody3D pick proxies (layer 8 in the editor = 1 << 7).
const LAYER_SURF_PICK: int = 1 << 7
## World props / triggers for dialogue (layer 9 in the editor = 1 << 8). Must not be on [member LAYER_SURF_PICK].
const LAYER_WORLD_INTERACT: int = 1 << 8

const CANVAS_LAYER_RETICLE: int = 50
const CANVAS_LAYER_DIALOGUE: int = 80

signal hover_valid_changed(is_valid: bool)
signal interact_hover_changed(is_hovering: bool)

var _registered: Array[SurveillanceCamera] = []
var active_camera: SurveillanceCamera = null
var _hover_target: SurveillanceCamera = null
var _hover_valid: bool = false
var _interact_hover: bool = false
var _switch_tween: Tween
var _auto_start_pending: bool = false
var _dialogue_layer: CanvasLayer = null
## Keys: surveillance camera instance id. Value: first-visit line already played for that node instance.
var _first_visit_dialogue_done: Dictionary = {}

## If true, cursor is captured while surfing (best mouse-look feel). Pick rays always use the viewport center, not the pointer.
@export var use_captured_mouse: bool = true


func _ready() -> void:
	var reticle_scene: PackedScene = preload("res://subscenes/CameraSurfReticle.tscn")
	var reticle_root: CanvasLayer = reticle_scene.instantiate() as CanvasLayer
	reticle_root.layer = CANVAS_LAYER_RETICLE
	add_child(reticle_root)
	_setup_dialogue_ui()


func _physics_process(_delta: float) -> void:
	if active_camera == null:
		_set_hover(null, false)
		_set_interact_hover(false)
		return
	var target := _ray_pick_target()
	var valid := _is_valid_hop_target(target)
	_set_hover(target, valid)
	var interact_hover := false
	if not valid:
		interact_hover = _is_world_interact_under_ray()
	_set_interact_hover(interact_hover)


func _input(event: InputEvent) -> void:
	if active_camera == null:
		return
	var box := _get_dialogue_box()
	if box != null and box.is_running():
		return
	if event is InputEventMouseMotion:
		active_camera.apply_look_delta(event.relative)
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("camera_surf_confirm"):
		return
	if active_camera == null:
		return
	var db := _get_dialogue_box()
	if db != null and db.is_running():
		return
	var target := _ray_pick_target()
	if switch_to(target):
		get_viewport().set_input_as_handled()
		return
	if _try_play_world_interact_dialogue():
		get_viewport().set_input_as_handled()


func register(cam: SurveillanceCamera) -> void:
	if cam in _registered:
		return
	_registered.append(cam)
	if active_camera == null:
		_request_auto_start()


func unregister(cam: SurveillanceCamera) -> void:
	_first_visit_dialogue_done.erase(cam.get_instance_id())
	_registered.erase(cam)
	if active_camera == cam:
		active_camera = null
		_clear_all_current()
		_set_hover(null, false)
		if not _registered.is_empty():
			start(_pick_entry_camera())
		else:
			_apply_mouse_mode()


func _request_auto_start() -> void:
	if _auto_start_pending:
		return
	_auto_start_pending = true
	call_deferred(&"_auto_start_if_needed")


func _auto_start_if_needed() -> void:
	_auto_start_pending = false
	if active_camera != null or _registered.is_empty():
		return
	var entry := _pick_entry_camera()
	if entry:
		start(entry)


func _pick_entry_camera() -> SurveillanceCamera:
	for node in get_tree().get_nodes_in_group("surf_entry"):
		if node is SurveillanceCamera and node in _registered and is_instance_valid(node):
			return node
	return _registered[0]


func start(entry: SurveillanceCamera) -> void:
	if entry == null or not is_instance_valid(entry) or not entry.is_inside_tree():
		return
	active_camera = entry
	_make_current(entry)
	_apply_mouse_mode()
	_maybe_play_first_visit_dialogue(entry)


func switch_to(target: SurveillanceCamera) -> bool:
	if not _is_valid_hop_target(target):
		return false
	active_camera = target
	_make_current(target)
	_play_switch_polish(target)
	_apply_mouse_mode()
	_maybe_play_first_visit_dialogue(target)
	return true


func _make_current(entry: SurveillanceCamera) -> void:
	var vc: Camera3D = entry.get_view_camera()
	if vc == null:
		return
	for cam in _registered:
		var c: Camera3D = cam.get_view_camera()
		if c:
			c.current = false
	vc.current = true


func _clear_all_current() -> void:
	for cam in _registered:
		var c: Camera3D = cam.get_view_camera()
		if c:
			c.current = false


func _pick_screen_position() -> Vector2:
	return get_viewport().get_visible_rect().get_center()


func _setup_dialogue_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "DialogueLayer"
	layer.layer = CANVAS_LAYER_DIALOGUE
	var dc: Control = preload("res://subscenes/DialogueContainer.tscn").instantiate()
	dc.auto_start_on_ready = false
	layer.add_child(dc)
	add_child(layer)
	_dialogue_layer = layer


func _get_dialogue_box() -> DialogueBox:
	if _dialogue_layer == null:
		return null
	var dc: Node = _dialogue_layer.get_child(0)
	if dc == null:
		return null
	return dc.get_node_or_null("DialogueBox") as DialogueBox


func _try_play_world_interact_dialogue() -> bool:
	var hit := _ray_world_interact_hit()
	if hit.is_empty():
		return false
	var collider: Node = hit.get("collider") as Node
	if collider != null and _resolve_surveillance(collider) != null:
		return false
	var inter: SurfInteractable = _resolve_surf_interactable(collider)
	if inter == null or inter.dialogue_data == null:
		return false
	var box := _get_dialogue_box()
	if box == null or box.is_running():
		return false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	box.dialogue_ended.connect(_restore_surf_mouse_after_dialogue, CONNECT_ONE_SHOT)
	box.data = inter.dialogue_data
	box.start(inter.dialogue_start_id)
	return true


func _restore_surf_mouse_after_dialogue() -> void:
	_apply_mouse_mode()


func _maybe_play_first_visit_dialogue(cam: SurveillanceCamera) -> void:
	if cam == null or not is_instance_valid(cam):
		return
	if cam.first_visit_dialogue == null:
		return
	var id: int = cam.get_instance_id()
	if _first_visit_dialogue_done.get(id, false):
		return
	var box := _get_dialogue_box()
	if box == null or box.is_running():
		return
	_first_visit_dialogue_done[id] = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	box.dialogue_ended.connect(_restore_surf_mouse_after_dialogue, CONNECT_ONE_SHOT)
	box.data = cam.first_visit_dialogue
	box.start(cam.first_visit_start_id)


func _ray_world_interact_hit() -> Dictionary:
	var vc: Camera3D = active_camera.get_view_camera()
	if vc == null:
		return {}
	var screen_center := _pick_screen_position()
	var from: Vector3 = vc.project_ray_origin(screen_center)
	var to: Vector3 = from + vc.project_ray_normal(screen_center) * 5000.0
	var space: PhysicsDirectSpaceState3D = vc.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = LAYER_WORLD_INTERACT
	q.collide_with_bodies = true
	q.collide_with_areas = false
	return space.intersect_ray(q)


func _is_world_interact_under_ray() -> bool:
	var hit := _ray_world_interact_hit()
	if hit.is_empty():
		return false
	var collider: Node = hit.get("collider") as Node
	if collider == null or _resolve_surveillance(collider) != null:
		return false
	var inter: SurfInteractable = _resolve_surf_interactable(collider)
	return inter != null and inter.dialogue_data != null


func _resolve_surf_interactable(node: Node) -> SurfInteractable:
	var n: Node = node
	while n:
		if n is SurfInteractable:
			return n
		n = n.get_parent()
	return null


func _set_interact_hover(is_hovering: bool) -> void:
	if is_hovering == _interact_hover:
		return
	_interact_hover = is_hovering
	interact_hover_changed.emit(is_hovering)


func _ray_pick_target() -> SurveillanceCamera:
	var vc: Camera3D = active_camera.get_view_camera()
	if vc == null:
		return null
	var screen_center := _pick_screen_position()
	var from: Vector3 = vc.project_ray_origin(screen_center)
	var to: Vector3 = from + vc.project_ray_normal(screen_center) * 5000.0
	var space: PhysicsDirectSpaceState3D = vc.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to)
	q.collision_mask = LAYER_SURF_PICK
	q.collide_with_bodies = true
	q.collide_with_areas = false
	# Pick proxy sits in front of the lens; without excluding it, every ray hits ourselves first.
	var pick_body: Node = active_camera.get_node_or_null("PickBody")
	if pick_body is CollisionObject3D:
		q.exclude = [pick_body.get_rid()]
	var hit: Dictionary = space.intersect_ray(q)
	if hit.is_empty():
		return null
	var collider: Node = hit.get("collider") as Node
	return _resolve_surveillance(collider)


func _resolve_surveillance(node: Node) -> SurveillanceCamera:
	var n: Node = node
	while n:
		if n is SurveillanceCamera:
			return n
		n = n.get_parent()
	return null


func _is_valid_hop_target(target: SurveillanceCamera) -> bool:
	if target == null or active_camera == null or not is_instance_valid(target):
		return false
	return target != active_camera and target in _registered


func _set_hover(target: SurveillanceCamera, valid: bool) -> void:
	_hover_target = target
	if valid == _hover_valid:
		return
	_hover_valid = valid
	hover_valid_changed.emit(valid)


func _play_switch_polish(target: SurveillanceCamera) -> void:
	var vc: Camera3D = target.get_view_camera()
	if vc == null:
		return
	if _switch_tween != null:
		_switch_tween.kill()
	_switch_tween = create_tween()
	var base_fov: float = vc.fov
	vc.fov = base_fov * 1.08
	_switch_tween.tween_property(vc, "fov", base_fov, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _apply_mouse_mode() -> void:
	if active_camera == null:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif use_captured_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
