class_name Player
extends KinematicCharacter


const MOVING_VELOCITY := 150.0
const JUMP_VELOCITY := 500.0
const SLIDING_VELOCITY := 100.0

var is_moving_left := false
var is_moving_right := false

onready var state_machine: AnimationNodeStateMachinePlayback = $AnimationTree['parameters/playback']

func _process(delta):
	$AnimationTree['parameters/conditions/is_falling'] = gravity_velocity.length() > 0 and not is_on_ground()
	$AnimationTree['parameters/conditions/is_not_falling'] = not $AnimationTree['parameters/conditions/is_falling']
	$AnimationTree['parameters/conditions/is_moving'] = static_velocity.length() > 0
	$AnimationTree['parameters/conditions/is_not_moving'] = not $AnimationTree['parameters/conditions/is_moving']
	$AnimationTree['parameters/conditions/is_sliding'] = dynamic_velocity.length() > SLIDING_VELOCITY and dynamic_velocity.y == 0
	$AnimationTree['parameters/conditions/is_not_sliding'] = not $AnimationTree['parameters/conditions/is_sliding']


func _manipulate_velocities(delta: float) -> void:
	var final_vector := Vector2.ZERO
	if is_moving_left:
		final_vector += Vector2.LEFT
	elif is_moving_right:
		final_vector += Vector2.RIGHT
	static_velocity = final_vector * MOVING_VELOCITY

func _handle_collision(collision: KinematicCollision2D, delta: float) -> void:
	if collision.collider.is_in_group('Wall') and dynamic_velocity.length() > 0:
		bounce(collision.normal, 0.5)

func _input(event):
	if event.is_action_pressed("ui_left"):
		is_moving_left = true
		$AnimatedSprite.flip_h = true
	if event.is_action_released("ui_left"):
		is_moving_left = false
	if event.is_action_pressed("ui_right"):
		is_moving_right = true
		$AnimatedSprite.flip_h = false
	if event.is_action_released("ui_right"):
		is_moving_right = false
	if event.is_action_released("ui_up"):
		state_machine.travel("Jump")
		apply_impulse(Vector2.UP * JUMP_VELOCITY)
		#gravity_velocity = Vector2.ZERO
	if event.is_action_released("ui_accept"):
		if $AnimatedSprite.flip_h:
			apply_impulse(Vector2.LEFT * 500.0)
		else:
			apply_impulse(Vector2.RIGHT * 500.0)


func will_collide_with_floor(movement: Vector2) -> bool:
	return test_move(transform, movement) and is_on_ground()

func is_on_ground() -> bool:
	var r1: bool = $RayCast2D.is_colliding() and $RayCast2D.get_collider().is_in_group("Floor")
	var r2: bool = $RayCast2D2.is_colliding() and $RayCast2D2.get_collider().is_in_group("Floor")
	return r1 or r2
