extends Node

@export var main_menu_packed: PackedScene
@export var load_level_packed: PackedScene
@export var paused_packed: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_main_menu("game start")

func load_main_menu(origin: String) -> void:
	var main_menu: Control = main_menu_packed.instantiate()
	main_menu.start_pressed.connect(start_game)
	main_menu.options_pressed.connect(open_options)
	main_menu.quit_pressed.connect(exit_game)
	
	add_child(main_menu)
	
func start_game(origin: String) -> void:
	if origin == "main_menu":
		get_node("mainMenu").queue_free()
	var game_scene: Node2D = load_level_packed.instantiate()
	add_child(game_scene)
	
	

func open_options(origin: String) -> void:
	pass

func exit_game(origin: String) -> void:
	get_tree().quit()	
	
func pause_menu(origin: String) -> void:
	print("paused the game")
	var p_menu: Control = paused_packed.instantiate()
	add_child(p_menu)
	p_menu.show()
	get_tree().paused = true # Freezes the game world behind the pause menu!
