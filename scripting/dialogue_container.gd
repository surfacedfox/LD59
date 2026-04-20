extends Control


@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
var rng = RandomNumberGenerator.new()

## If true, runs the dialogue graph as soon as this UI is ready (legacy test behavior).
@export var auto_start_on_ready: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Full-rect root would otherwise steal every click from 3D / unhandled actions (e.g. camera surf).
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if auto_start_on_ready:
		dialogue_box.start()
	if dialogue_box.custom_effects.size() > 0:
		dialogue_box.custom_effects[0].char_displayed.connect(_on_char_displayed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_char_displayed(idx: int):
	if idx % 4 == 0:
		if rng.randf() < 0.67:
			self.audio_player.pitch_scale = rng.randf_range(0.7, 0.8)
			self.audio_player.play()
