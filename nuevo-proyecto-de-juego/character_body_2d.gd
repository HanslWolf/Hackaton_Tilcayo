extends CharacterBody2D

@export var walk_speed: float = 200.0
@export var run_speed: float = 350.0
@export var double_tap_window: float = 0.25 # Tiempo máximo (en segundos) entre dos pulsaciones para correr

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
#@onready var interaction_area: Area2D = $InteractionArea

var last_direction: String = "down"
var interactable_in_range: Node2D = null

# Variables para detectar doble pulsación
var is_running: bool = false
var last_tap_action: String = ""
var last_tap_time: float = 0.0

#func _ready() -> void:
#	interaction_area.area_entered.connect(_on_area_entered)
#	interaction_area.area_exited.connect(_on_area_exited)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("vi_left", "vi_right", "vi_up", "vi_down")
	
	if direction == Vector2.ZERO:
		is_running = false
		
	var current_speed := run_speed if is_running else walk_speed
	velocity = direction * current_speed
	move_and_slide()
	
	update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:

	for action in ["vi_left", "vi_right", "vi_up", "vi_down"]:
		if event.is_action_pressed(action) and not event.is_echo():
			var current_time := Time.get_ticks_msec() / 1000.0
			if action == last_tap_action and (current_time - last_tap_time) <= double_tap_window:
				is_running = true
			last_tap_action = action
			last_tap_time = current_time

	if event.is_action_pressed("interact") and interactable_in_range != null:
		if interactable_in_range.has_method("interact"):
			interactable_in_range.interact()

func update_animation(direction: Vector2) -> void:
	
	if direction == Vector2.ZERO:
		match last_direction:
			"down":
				anim.flip_h = false
				anim.play("idle_d")
			"up":
				anim.flip_h = false
				anim.play("idle_u")
			"right":
				anim.flip_h = false
				anim.play("idle_r")
			"left":
				anim.flip_h = true
				anim.play("idle_l")
		return


	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			last_direction = "right"
			anim.flip_h = false
		else:
			last_direction = "left"
			anim.flip_h = true
	else:
		anim.flip_h = false
		last_direction = "down" if direction.y > 0 else "up"
			
	if is_running:
		match last_direction:
			"down":
				anim.play("run_d")
			"up":
				anim.play("run_u")
			"right":
				anim.play("run_r")
			"left":
				anim.play("run_l")
	else:
		if last_direction == "left":
			anim.play("walk_right")
		else:
			anim.play("walk_" + last_direction)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactables"):
		interactable_in_range = area
		if area.has_method("show_prompt"):
			area.show_prompt(true)

func _on_area_exited(area: Area2D) -> void:
	if area == interactable_in_range:
		if area.has_method("show_prompt"):
			area.show_prompt(false)
		interactable_in_range = null
