extends CharacterBody3D

var LeverLeft: float = 0
var LeverRigth: float = 0
var SPEED = 10
var ANGLE = 45

@onready var turret: MeshInstance3D = $Tank_Body/Turret
@onready var elevator_l: MeshInstance3D = $Tank_Body/Turret/ElevatorL
@onready var elevator_r: MeshInstance3D = $Tank_Body/Turret/ElevatorR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	translate (Vector3.FORWARD * SPEED *(LeverLeft + LeverRigth)/2 * delta)
	rotate_object_local(Vector3.UP, deg_to_rad( ANGLE * ((LeverRigth+1)/2 - (LeverLeft+1)/2) ) * delta)
	#velocity.z =  SPEED *(LeverLeft + LeverRigth)/2 * delta *-1
	if !is_on_floor():
		velocity.y -= 50 * delta

	move_and_slide()


func _on_interactable_lever_right_hinge_moved(angle: Variant) -> void:
	LeverRigth = (angle / 45) * -1

func _on_interactable_lever_left_hinge_moved(angle: Variant) -> void:
	LeverLeft = (angle / 45) * -1


func _on_turret_wheel_hinge_moved(angle: Variant) -> void:
	turret.rotation_degrees.y = angle /8

func _on_wheel_right_hinge_moved(angle: Variant) -> void:
	elevator_r.rotation_degrees.x = angle /28

func _on_wheel_left_hinge_moved(angle: Variant) -> void:
	elevator_l.rotation_degrees.x = angle /-28
