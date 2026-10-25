class_name Interactable
extends Area2D

@export var texture: Texture2D
@export var required_item := ""
@export var locked_message := "It's locked"

var _player_in_range := false
var _prompt := Label.new()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and texture:
		sprite.texture = texture
	_prompt.text = "[E]"
	_prompt.position = Vector2(-14, -48)
	_prompt.z_index = 10
	_prompt.add_theme_constant_override("outline_size", 6)
	_prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	_prompt.hide()
	add_child(_prompt)
	
func interact() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	if required_item != "" and not GameState.has_item(required_item):
		GameState.show_message(locked_message)
		return
	interact()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.hide()
