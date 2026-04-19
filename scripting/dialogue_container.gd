extends Control


@onready var dialogue_box: DialogueBox = $DialogueBox
@onready var audio_player = $AudioStreamPlayer
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.dialogue_box.start()
	self.dialogue_box.custom_effects[0].char_displayed.connect(_on_char_displayed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_char_displayed(idx: int):
	if idx % 4 == 0:
		if rng.randf() < 0.67:
			self.audio_player.play()
