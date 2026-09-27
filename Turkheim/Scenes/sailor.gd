extends CharacterBody3D

var STATE = "floating"
var Hook: Area3D = null
var canHook = false
@onready var sailor_hook: MeshInstance3D = $SailorHook
@onready var sailor_saved: MeshInstance3D = $SailorSaved
@onready var sailor_floating: MeshInstance3D = $SailorFloating

signal SailorSaved

func _ready() -> void:
	canHook = true
	sailor_floating.visible = true
	sailor_hook.visible = false
	sailor_saved.visible = false
func _physics_process(delta: float) -> void:
	match STATE:
		"floating":
			# Idle in place, wait for hook
			velocity = Vector3.ZERO
			sailor_floating.visible = true
			sailor_hook.visible = false
			sailor_saved.visible = false
		"hooked":
			# Follow hook in world space
			if is_instance_valid(Hook):
				global_position = Hook.global_position
			velocity = Vector3.ZERO
			sailor_floating.visible = false
			sailor_hook.visible = true
			sailor_saved.visible = false
		"saved":
			# Fall onto beach/floor via gravity
			if not is_on_floor():
				velocity += get_gravity() * delta
			else:
				velocity.y = 0.0
			sailor_floating.visible = false
			sailor_hook.visible = false
			sailor_saved.visible = true
			$Sailor.process_mode = Node.PROCESS_MODE_DISABLED
	move_and_slide()


func _on_sailor_area_entered(area: Area3D) -> void:
	if area.is_in_group("hook") and canHook:
		Hook = area
		STATE = "hooked"
		canHook = false

	elif area.is_in_group("beach"):
		STATE = "saved"
		Hook = null  # Release reference to hook
		canHook = false
		$Timer.start()
		SailorSaved.emit()

func _on_timer_timeout() -> void:
	canHook = true
