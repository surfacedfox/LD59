extends Control

## Single neutral reticle color; only sizes change on hover.
const RETICLE_COLOR := Color(1, 1, 1, 0.72)

const DOT_IDLE: float = 4.0
const DOT_HOVER: float = 2.5
const RING_IDLE: float = 0.0
const RING_HOVER: float = 24.0
const RING_WIDTH: float = 2.75
const TWEEN_SEC: float = 0.16

var _cam_valid: bool = false
var _interact: bool = false

var _dot_radius: float = DOT_IDLE
var _ring_radius: float = RING_IDLE
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	CameraSurfManager.hover_valid_changed.connect(_on_hover_valid)
	CameraSurfManager.interact_hover_changed.connect(_on_interact_hover)
	_refresh_visual_state(false)


func _on_hover_valid(is_valid: bool) -> void:
	_cam_valid = is_valid
	_refresh_visual_state(true)


func _on_interact_hover(is_hovering: bool) -> void:
	_interact = is_hovering
	_refresh_visual_state(true)


func _refresh_visual_state(animate: bool) -> void:
	var hover := _cam_valid or _interact
	if animate:
		_tween_to_hover(hover)
	else:
		_ring_radius = RING_HOVER if hover else RING_IDLE
		_dot_radius = DOT_HOVER if hover else DOT_IDLE
		queue_redraw()


func _tween_to_hover(on: bool) -> void:
	var r_end: float = RING_HOVER if on else RING_IDLE
	var d_end: float = DOT_HOVER if on else DOT_IDLE
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_method(_set_ring_radius, _ring_radius, r_end, TWEEN_SEC)
	_tween.tween_method(_set_dot_radius, _dot_radius, d_end, TWEEN_SEC)


func _set_ring_radius(v: float) -> void:
	_ring_radius = v
	queue_redraw()


func _set_dot_radius(v: float) -> void:
	_dot_radius = v
	queue_redraw()


func _draw() -> void:
	var c: Vector2 = size * 0.5
	if _dot_radius > 0.05:
		draw_circle(c, _dot_radius, RETICLE_COLOR, true, true)
	if _ring_radius > 0.08:
		draw_arc(c, _ring_radius, 0.0, TAU, 96, RETICLE_COLOR, RING_WIDTH, true)
