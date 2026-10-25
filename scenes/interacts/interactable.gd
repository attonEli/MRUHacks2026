class_name Interactable
extends Area2D

@export var display_name := "" ## Shown above [E] when the player is close. Empty = no name.
@export var texture: Texture2D
@export var required_item := ""
@export var locked_message := "It's locked"

var _player_in_range := false
var _prompt := Label.new()
var _name_label := Label.new()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite and texture:
		sprite.texture = texture
	_name_label.text = get_display_name()
	_add_floating_label(_name_label, -72)
	_prompt.text = "[E]"
	_add_floating_label(_prompt, -48)

## Child scripts can override this to give a default name (e.g. "Switch 2").
func get_display_name() -> String:
	return display_name

func interact() -> void:
	pass

func _add_floating_label(label: Label, y: float) -> void:
	label.size = Vector2(200, 24)
	label.position = Vector2(-100, y)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 10
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.hide()
	add_child(label)

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
		_name_label.visible = _name_label.text != ""

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.hide()
		_name_label.hide()
