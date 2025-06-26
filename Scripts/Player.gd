extends Node3D

var OffsetAmount = .12

signal StoppedMoving

enum STATE {
	DECIDING,
	START,
	WAITING
}
var OriginalPosition = Vector3.ZERO
var CurrentState = STATE.DECIDING
var CurrentDirection = Vector3(1,0,0)

var LastMousePosition = Vector2.ZERO
var RotateSpeed = 2

var CameraRotationLimit = Vector2(-20, -5)
var ScrollSpeed = 200

var MinStrength = 0
var MaxStrength = 100
var bGrowing = true
var CurrentStrength = 0
var StrengthRate = 200

func _ready() -> void:
	MoveToBall()
	Finder.GetMainBall().StateUpdate.connect(OnStateUpdate)
	OriginalPosition = $stick.position
	
func MoveToBall():
	$Camera3D.rotation_degrees.x = CameraRotationLimit.x
	$stick.rotation = Vector3.ZERO
	var newPosition = Finder.GetMainBall().global_position
	global_position = newPosition
	global_position += Vector3(0, .01, .0)
	global_position -= CurrentDirection * OffsetAmount
	var newDirection = (Finder.GetMainBall().global_position - newPosition).normalized()
	
	look_at(Finder.GetMainBall().global_position)
	print(CurrentDirection)
	
func IsShootingTime():
	return CurrentState == STATE.START
	
func _process(delta: float) -> void:
	UpdateProgressBar()
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
			
		if Input.is_action_just_released("left_click"):
			CurrentState = STATE.START
			CurrentStrength = MinStrength
			bGrowing = true
			$Camera3D.rotation_degrees.x = CameraRotationLimit.x
	else:
		look_at(Finder.GetMainBall().global_position)
		
	if IsShootingTime():
		if bGrowing:
			CurrentStrength += delta * StrengthRate
			if CurrentStrength > MaxStrength:
				CurrentStrength = MaxStrength
				bGrowing = false
		else:
			CurrentStrength -= delta * StrengthRate
			if CurrentStrength < MinStrength:
				CurrentStrength = MinStrength
				bGrowing = true
				
		if Input.is_action_just_pressed("right_click"):
			CurrentState = STATE.DECIDING
		if Input.is_action_just_pressed("left_click"):
			ShootBall()

func UpdateProgressBar():
	if IsShootingTime():
		$CanvasLayer/ProgressBar.visible = true
	else:
		$CanvasLayer/ProgressBar.visible = false
	$CanvasLayer/ProgressBar.value = CurrentStrength
	
func CanShoot():
	return CurrentState == STATE.DECIDING
	
func ShootBall():
		CurrentState = STATE.WAITING
		var tween = get_tree().create_tween()
		tween.tween_property($stick, "position", lerp($stick.position, $stick.position + Vector3.FORWARD * 2, .1), .1)
		await tween.finished
		Finder.GetMainBall().apply_impulse(GetPower())
		tween = get_tree().create_tween()
		tween.tween_property($stick, "position", OriginalPosition, .1)
		await tween.finished
		$stick.rotation = Vector3.UP
		
func GetPower():
	var direction = -transform.basis.z
	direction.y = 0
	direction = direction.normalized()
	var value = lerp(3, 20, CurrentStrength/MaxStrength)
	return direction * value
		
func OnStateUpdate(state : Ball.MOVE_STATE):
	if state == Ball.MOVE_STATE.IDLE:
		MoveToBall()
		print("moved to ball")
		CurrentState = STATE.DECIDING
	
	
