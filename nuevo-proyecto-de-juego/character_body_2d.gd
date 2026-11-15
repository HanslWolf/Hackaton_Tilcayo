extends CharacterBody2D

const WALK_SPEED := 200.0
const RUN_SPEED := 350.0
const DOUBLE_TAP_WINDOW := 0.25

# Pon true si al caminar a la izquierda el muñeco se ve mirando a la derecha
const MIRROR_LEFT := false

const LEFT_KEYS := [KEY_A, KEY_LEFT]
const RIGHT_KEYS := [KEY_D, KEY_RIGHT]
const UP_KEYS := [KEY_W, KEY_UP]
const DOWN_KEYS := [KEY_S, KEY_DOWN]
const MOVE_KEYS := [KEY_A, KEY_LEFT, KEY_D, KEY_RIGHT, KEY_W, KEY_UP, KEY_S, KEY_DOWN]

const IDLE := {"down": "idle_d", "up": "idle_u", "right": "idle_r", "left": "idle_l"}
const WALK := {"down": "walk_down", "up": "walk_up", "right": "walk_right", "left": "walk_left"}
const RUN := {"down": "run_d", "up": "run_u", "right": "run_r", "left": "run_l"}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var last_direction: String = "down"
var interactable_in_range: Node2D = null

var is_running: bool = false
var last_tap_key: int = 0
var last_tap_time: float = 0.0


func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	# Sin colisiones por ahora: el mapa aún no las tiene y nada debe frenarlo
	collision_layer = 0
	collision_mask = 0
	print("Personaje listo en: ", global_position)


func _physics_process(_delta: float) -> void:
	var direction := _get_input_direction()

	if direction == Vector2.ZERO:
		is_running = false

	velocity = direction * (RUN_SPEED if is_running else WALK_SPEED)
	move_and_slide()
	update_animation(direction)


func _get_input_direction() -> Vector2:
	var x := int(_any_pressed(RIGHT_KEYS)) - int(_any_pressed(LEFT_KEYS))
	var y := int(_any_pressed(DOWN_KEYS)) - int(_any_pressed(UP_KEYS))
	return Vector2(x, y).normalized()


func _any_pressed(keys: Array) -> bool:
	for k in keys:
		if Input.is_physical_key_pressed(k):
			return true
	return false


func _unhandled_input(event: InputEvent) -> void:
	# Doble toque sobre una misma tecla de movimiento = correr
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.physical_keycode
		if key in MOVE_KEYS:
			var now := Time.get_ticks_msec() / 1000.0
			if key == last_tap_key and (now - last_tap_time) <= DOUBLE_TAP_WINDOW:
				is_running = true
			last_tap_key = key
			last_tap_time = now

	if InputMap.has_action("interact") and event.is_action_pressed("interact"):
		if interactable_in_range != null and interactable_in_range.has_method("interact"):
			interactable_in_range.interact()


func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"

	anim.flip_h = MIRROR_LEFT and last_direction == "left"

	if direction == Vector2.ZERO:
		_play(IDLE[last_direction])
	elif is_running:
		_play(RUN[last_direction])
	else:
		_play(WALK[last_direction])


func _play(anim_name: String) -> void:
	if anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		if anim.animation != anim_name or not anim.is_playing():
			anim.play(anim_name)


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
