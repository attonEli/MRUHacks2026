extends Node

@export var main_menu_packed: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_main_menu("game start")

func load_main_menu(origin: String) -> void:
	pass
	
func open_settings(_origin: String) -> void:
	pass

func exit() -> void:
	get_tree().quit()	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
