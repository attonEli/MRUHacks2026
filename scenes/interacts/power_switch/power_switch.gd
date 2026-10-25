extends Interactable

@export_range(1, 4) var switch_number := 1
@export var pressed_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var off_texture: Texture2D = sprite.texture


func _ready() -> void:
	super()
	GameState.switch_changed.connect(_on_switch_changed)


func interact() -> void:
	GameState.use_switch(switch_number)


func _on_switch_changed(number: int, is_on: bool) -> void:
	if number != switch_number:
		return
	sprite.texture = pressed_texture if is_on else off_texture
