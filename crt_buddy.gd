extends TextureRect

@export var viewport: SubViewport

func _ready() -> void:
	#(material as ShaderMaterial).set_shader_parameter("screen_texture", viewport.get_texture())
	pass
