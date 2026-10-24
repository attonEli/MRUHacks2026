extends CharacterBody2D

#@export_category("Stats")
@export var speed: float = 400.0

var move_direction: Vector2 = Vector2(0,0)

func _physics_process(delta: float) -> void:
		movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	move_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	#velocity = move_direction.normalized() * speed
	
	if move_direction.x < 0:
		$Sprite2D.flip_h = true
	elif move_direction.x > 0:
		$Sprite2D.flip_h = false
	
	velocity = move_direction.normalized() * speed
	
	move_and_slide()
	
	
