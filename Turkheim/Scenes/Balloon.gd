extends CharacterBody3D

@onready var propsLeft: AudioStreamPlayer3D = $PropLeft/Props
@onready var propsRight: AudioStreamPlayer3D = $PropRight/Props2
@onready var crank: AudioStreamPlayer3D = $LeverOriginCrank/Crank
@onready var burnersound: AudioStreamPlayer3D = $Burner


@onready var hook: Node3D = $Hook

var LeverLeft: float = 0
var LeverRight: float = 0
@export var SPEED = 5
@export var ANGLE = 45
#@export var GRAVITY = 1
#@export var BURNER_POWER = 5
@export var RISE_SPEED: float = 3.0   # Speed when pulling the chain
@export var FALL_SPEED: float = -0.5  # Gentle descent speed when released
#@export var DAMPING: float = .1      # Air resistance/drag to stop infinite rising
#@export var MAX_FALL_SPEED: float = -8.0
#@export var MAX_RISE_SPEED: float = 6.0
var Burner = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var burner_light: OmniLight3D = $"Burner light"

func _process(delta: float) -> void:
	$PropRight.rotate_z (LeverLeft * delta * -50)
	propsLeft.pitch_scale = abs(LeverLeft)
	$PropLeft.rotate_z (LeverRight * delta * -50)
	propsRight.pitch_scale = abs(LeverRight)

# Set volume continuously (linear_to_db safely handles 0.0 by returning -80 dB)
	burnersound.volume_db = linear_to_db(max(Burner, 0.0001))

	burner_light.light_energy = Burner
	
func _physics_process(delta: float) -> void:
	translate (Vector3.FORWARD * SPEED *(LeverLeft + LeverRight)/2 * delta)
	rotate_object_local(Vector3.UP, deg_to_rad( ANGLE * ((LeverRight+1)/2 - (LeverLeft+1)/2) ) * delta)
	
# Direct Vertical Control
	if Burner > 0.05:
		# Pulling chain -> Rise steadily
		velocity.y = Burner * RISE_SPEED
	elif not is_on_floor():
		# Chain released & in air -> Fall gently at constant rate
		velocity.y = FALL_SPEED
		
	else:
		# On ground -> Stop vertical movement
		velocity.y = 0.0

	move_and_slide()

func _on_interactable_lever_right_hinge_moved(angle: Variant) -> void:
	LeverRight = (angle / 45) * -1

func _on_interactable_lever_hinge_moved(angle: Variant) -> void:
	LeverLeft = (angle / 45) * -1


func _on_interactable_slider_slider_moved(position: Variant) -> void:
	Burner = float(((position/ 0.3) *-1) +1)
	print(Burner)


func _on_interactable_winch_hinge_moved(angle: Variant) -> void:
	hook.position.y = angle/360*-1
	var ropeScale = angle/360*-1
	$Hook/Rope.scale.y = ropeScale
