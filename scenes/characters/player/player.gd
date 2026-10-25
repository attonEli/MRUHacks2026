extends CharacterBody2D

#@export_category("Stats")
@export var speed: float = 400.0
@export var paused_packed: PackedScene

#@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer

var move_direction: Vector2 = Vector2(0,0)


func _physics_process(delta: float) -> void:
		movement_loop()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	move_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		$AnimatedSprite2D.play("default")
	elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.play("default")
	elif Input.is_action_pressed("ui_down"):
		$AnimatedSprite2D.play("move_down")
	elif Input.is_action_pressed("ui_up"):
		$AnimatedSprite2D.play("move_up")
	
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("move_sides")
	elif Input.is_action_pressed("ui_right"):
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("move_sides")
	
	else:
		$AnimatedSprite2D.play("default")
	
	velocity = move_direction.normalized() * speed
	
	move_and_slide()
	
func play_footstep() -> void:
	#footstep_player.play()
	pass
