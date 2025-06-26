extends Node3D

var OffsetAmount = .12

signal StoppedMoving

enum STATE {
	DECIDING,
	HITTING
}
var OriginalPosition = Vector3.ZERO
var CurrentState = STATE.DECIDING
var CurrentDirection = Vector3(1,0,0)

var LastMousePosition = Vector2.ZERO
var RotateSpeed = 2

var CameraRotationLimit = Vector2(-20, -5)
var ScrollSpeed = 200

func _ready() -> void:
	MoveToBall()
	Finder.GetMainBall().StateUpdate.connect(OnStateUpdate)
	
func MoveToBall():
	
	var newPosition = Finder.GetMainBall().global_position
	global_position = newPosition
	global_position += Vector3(0, .01, .0)
	global_position -= CurrentDirection * OffsetAmount
	var newDirection = (Finder.GetMainBall().global_position - newPosition).normalized()
	look_at(Finder.GetMainBall().global_position)
	print(CurrentDirection)
func _process(delta: float) -> void:
	if CanShoot():
		if Input.is_action_just_released("scroll_up"):
			$Camera3D.rotation_degrees.x += ScrollSpeed * delta
			if $Camera3D.rotation_degrees.x > CameraRotationLimit.y:
				$Camera3D.rotation_degrees.x = CameraRotationLimit.y
		elif Input.is_action_just_released("scroll_down"):
			$Camera3D.rotation_degrees.x -= ScrollSpeed * delta
			if $Camera3D.rotation_degrees.x < CameraRotationLimit.x:
				$Camera3D.rotation_degrees.x = CameraRotationLimit.x
				
		print($Camera3D.rotation)
		if Input.is_action_pressed("right_click"):
			var newPosition = get_viewport().get_mouse_position()
			if LastMousePosition != Vector2.ZERO or LastMousePosition != newPosition:
				if newPosition.x > LastMousePosition.x:
					CurrentDirection = CurrentDirection.rotated(Vector3.UP, -RotateSpeed * delta)
				elif newPosition.x < LastMousePosition.x:
					CurrentDirection = CurrentDirection.rotated(Vector3.UP, RotateSpeed * delta)
				MoveToBall()
			LastMousePosition = newPosition
	else:
		
		look_at(Finder.GetMainBall().global_position)
func CanShoot():
	return CurrentState == STATE.DECIDING
	
func _input(event: InputEvent) -> void:		
	if event.is_action_pressed("left_click"):
		if CanShoot() == false:
			return
		CurrentState = STATE.HITTING
		OriginalPosition = $stick.global_position
		var tween = get_tree().create_tween()
		tween.tween_property($stick, "global_position", lerp($stick.global_position, Finder.GetMainBall().global_position, .1), .1)
		await tween.finished
		Finder.GetMainBall().apply_impulse(GetPower())
		tween = get_tree().create_tween()
		tween.tween_property($stick, "global_position", OriginalPosition, .1)
		await tween.finished
		
			
		
func GetPower():
	var direction = -transform.basis.z
	direction.y = 0
	direction = direction.normalized()
	return direction * 1
		
func OnStateUpdate(state : Ball.MOVE_STATE):
	if state == Ball.MOVE_STATE.IDLE:
		MoveToBall()
		print("moved to ball")
		CurrentState = STATE.DECIDING
	
	
