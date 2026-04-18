extends CanvasItem

@export var Target: Camera3D

func _ready():
	var viewportTex : ViewportTexture = ViewportTexture.new()
	var dithershader : ShaderMaterial = material
	viewportTex = get_viewport().get_texture()
	dithershader.set_shader_parameter("SCREEN_TEXTURE", viewportTex)