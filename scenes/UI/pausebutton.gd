extends Control

#signal pause_pressed(origin: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_texture_button_pressed() -> void:
	print("trying to pause the game")
	#pause_pressed.emit("pause_button")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
