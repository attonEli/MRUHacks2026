extends Node

@export var main_menu_packed: PackedScene
@export var load_level_packed: PackedScene
@export var paused_packed: PackedScene

var game_scene: Node = null

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
	game_scene = load_level_packed.instantiate()
	add_child(game_scene)
	var pause_button = game_scene.get_node_or_null("CanvasLayer/TextureButton")
	pause_button.pause_pressed.connect(pause_menu)
	

func open_options(origin: String) -> void:
	pass

func exit_game(origin: String) -> void:
	get_tree().quit()	
	
func pause_menu(origin: String) -> void:
	print("paused the game")
	var p_menu: CanvasLayer = paused_packed.instantiate()
	add_child(p_menu)
	p_menu.show()
	get_tree().paused = true # Freezes the game world behind the pause menu!
	p_menu.resume_pressed.connect(resume_game)
	p_menu.quit_to_main_pressed.connect(quit_to_menu)
	
func resume_game(origin: String) -> void:
	get_tree().paused = false
	get_node("pausemenu").queue_free()
	
func quit_to_menu(origin: String) -> void:
	get_tree().paused = false
	get_node("pausemenu").queue_free()

	game_scene.queue_free()

	load_main_menu("game start")
