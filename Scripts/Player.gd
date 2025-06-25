extends Node3D

var OffsetAmount = .01

signal StoppedMoving

enum STATE {
	DECIDING,
	HITTING
}
var OriginalPosition = Vector3.ZERO
var CurrentState = STATE.DECIDING

func _ready() -> void:
	MoveToBall()
	Finder.GetMainBall().StateUpdate.connect(OnStateUpdate)
	
func MoveToBall():
	
	var direction = (Finder.GetMainBall().global_position - global_position).normalized()
	direction.x = 0
	var newPosition = global_position + direction * OffsetAmount
	global_position = newPosition
	global_position -= Vector3(0,.01,0)
	var newDirection = (Finder.GetMainBall().global_position - newPosition).normalized()
	global_position = Finder.GetMainBall().global_position
	
	#rotation.x = 0
	
func _process(delta: float) -> void:
	pass
	$stick.look_at(Finder.GetMainBall().global_position)
	
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
	
	
