extends CharacterBody3D

var LeverA: float = 0
var LeverB: float = 0
var SPEED = 15
var ANGLE = 45
var WheelPitch = 0.0
var WheelJaw = 0.0
var canShoot = true
var playedHitSound = false
@onready var hand_handle_r = $BoatInteractables/LeverSnapRight/LeverOrigin/InteractableLeverB/HingeBody/NavigationLeverRight/Hand_Nails_low_R/Armature/Skeleton3D/mesh_Hand_Nails_low_R
@onready var hand_handle_l = $BoatInteractables/LeverSnapLeft/LeverOrigin/InteractableLeverA/HingeBody/NavigationLeverLeft/Hand_Nails_low_L/Armature/Skeleton3D/mesh_Hand_Nails_low_L
@onready var hand_l = $XROrigin3D/XRController_Left/LeftHandTurk/Hand_Nails_low_L/Armature/Skeleton3D/mesh_Hand_Nails_low_L
@onready var hand_r = $XROrigin3D/XRController_Right/RightHandTurk/Hand_Nails_low_R/Armature/Skeleton3D/mesh_Hand_Nails_low_R
@onready var hand_wheel_r =$BoatInteractables/CannonWheelPitch/LeverOrigin/InteractableHingePitch/HingeBody/Hand_Nails_low_R2/Armature/Skeleton3D/mesh_Hand_Nails_low_R
@onready var hand_wheel_l =$BoatInteractables/CannonWheelJaw/LeverOrigin/InteractableHingeJaw/HingeBody/Hand_Nails_low_L2/Armature/Skeleton3D/mesh_Hand_Nails_low_L
@onready var muzzle = $BoatAnimated/CannonAxis/CAnnon/Pipe/Muzzle
@onready var cannon_action = $BoatAnimated/CannonAxis/CAnnon/CannonAction



@export var bullet = load("res://Scenes/bullet.tscn")
@export var engineA : AudioStreamPlayer3D
@export var engineB : AudioStreamPlayer3D

func _ready():
	engineA.play()
	engineB.play()
	
	
func _physics_process(delta):
	


	engineA.volume_db = (pow(abs(LeverA),0.1)*80 - 80)
	engineA.pitch_scale = 0.5 * abs(LeverA) + 0.5
	engineB.volume_db = (pow(abs(LeverB),0.1)*80 - 80)
	engineB.pitch_scale = 0.5 * abs(LeverB) + 0.5
	
	translate (Vector3.FORWARD * SPEED *(LeverA + LeverB)/2 * delta)
	rotate_object_local(Vector3.UP, deg_to_rad( ANGLE * ((LeverB+1)/2 - (LeverA+1)/2) ) * delta)
	#velocity.z =  SPEED *(LeverA + LeverB)/2 * delta *-1
	$BoatAnimated/CannonAxis.rotation_degrees.y = WheelJaw * 180
	$BoatAnimated/CannonAxis/CAnnon.rotation_degrees.x = WheelPitch * 45 - 22.5
	
	$BoatAnimated/PaddleWheelRight/RollRight.speed_scale = LeverB *.8
	$BoatAnimated/PaddleWheelLeft/RollLeft.speed_scale = LeverA *.8
	

	move_and_slide()
	if get_slide_collision_count() > 0:
		if !playedHitSound:
			$Collision.play()
		playedHitSound = true
	else:
		playedHitSound = false
	
	
	
func _on_interactable_lever_b_hinge_moved(angle):
	LeverB = (angle / 45) * -1 


func _on_interactable_lever_a_hinge_moved(angle):
	LeverA = (angle / 45) * -1



func _on_interactable_hinge_pitch_hinge_moved(angle):
	WheelPitch = angle / 1440


func _on_interactable_hinge_jaw_hinge_moved(angle):
	WheelJaw = angle / 1440


func _on_interactable_area_button_button_pressed(button):
	if canShoot == true:
		#print("boom")
		crearProyectil()
		$Fire.play()
		canShoot =false
		$Timer.start()
		muzzle.restart()
		cannon_action.play("CannonShoot")
		
func crearProyectil():
	var instance
	instance = bullet.instantiate()
	get_tree().get_current_scene().add_child(instance)
	
	#Movemos el proyectil al origen del disparo
	instance.position = ($BoatAnimated/CannonAxis/CAnnon/Marker3D.global_position)
	
	#Empujamos el proyectil con fuerza para adelante
	instance.apply_central_impulse($BoatAnimated/CannonAxis/CAnnon/Marker3D.global_transform.basis.z * 20)

#timer delay for the cannon
func _on_timer_timeout():
	canShoot = true


func _on_interactable_lever_b_grabbed(interactable):
	hand_handle_r.visible = true
	hand_r.visible = false

func _on_interactable_lever_b_released(interactable):
	hand_handle_r.visible = false
	hand_r.visible = true

func _on_interactable_lever_a_grabbed(interactable):
	hand_handle_l.visible = true
	hand_l.visible = false

func _on_interactable_lever_a_released(interactable):
	hand_handle_l.visible = false
	hand_l.visible = true


#func _on_interactable_hinge_jaw_grabbed(interactable):
	#hand_wheel_l.visible = true
	#hand_l.visible = false
	#
#func _on_interactable_hinge_jaw_released(interactable):
	#hand_wheel_l.visible = false
	#hand_l.visible = true
#
#func _on_interactable_hinge_pitch_grabbed(interactable):
	#hand_wheel_r.visible = true
	#hand_r.visible = false
#
#func _on_interactable_hinge_pitch_released(interactable):
	#hand_wheel_r.visible = false
	#hand_r.visible = true
