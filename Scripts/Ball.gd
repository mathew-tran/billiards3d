extends RigidBody3D

class_name Ball

enum MOVE_STATE {
	MOVING,
	IDLE
}

var CurrentState = MOVE_STATE.IDLE

signal StateUpdate(stateType)

func _ready() -> void:
	CurrentState = MOVE_STATE.MOVING
	
func _process(delta: float) -> void:
	var newState = CurrentState
	if linear_velocity.length() <= 0.01:
		newState = MOVE_STATE.IDLE
	else:
		newState = MOVE_STATE.MOVING
		#linear_velocity.z *= .99
		#linear_velocity.y *= .99
	BroadcastMoveState(newState)
		
func BroadcastMoveState(newState):
	if CurrentState == newState:
		return
	CurrentState = newState
	StateUpdate.emit(CurrentState)
