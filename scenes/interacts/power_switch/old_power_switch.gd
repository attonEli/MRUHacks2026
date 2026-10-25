extends Area2D

# Allows you to drag and drop your "pressed" image right into the Inspector
@export var pressed_texture: Texture2D

# Keeps track of whether the button has already been triggered
var is_activated: bool = false

func _ready() -> void:
	print("TESTING")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# If it's already activated, do nothing (prevents re-triggering)
	if is_activated == true:
		return
		
	# Check if the player stepped on it
	if body.is_in_group("player"):
		is_activated = true
		print("Button pressed and locked!")
		
		# Change the texture if you assigned one in the inspector
		if pressed_texture:
			$Sprite2D.texture = pressed_texture
		
		# TODO: Trigger whatever the button opens (like opening a door)
