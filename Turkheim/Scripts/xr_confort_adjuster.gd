class_name XRComfortAdjuster
extends Node3D

## Drop this node as a DIRECT CHILD of an XROrigin3D.
##
## Controls (left/right Touch controller convention):
##   Left X + right stick -> move origin front/back and left/right
##   Left Y + right stick -> move origin up/down, hard left/right = snap turn
##   Both thumbstick clicks -> reloads the current scene
##
## If left_controller_path / right_controller_path are left empty, it will
## try to find them automatically among the XROrigin3D's children by their
## `tracker` property ("left_hand" / "right_hand").

@export var left_controller_path: NodePath
@export var right_controller_path: NodePath

@export_group("Movement")
@export var move_speed := 1.0        # meters / second while repositioning
@export var stick_deadzone := 0.2    # ignore small stick drift on movement axes

@export_group("Snap Turn")
@export var snap_turn_angle_deg := 15.0
@export var snap_turn_threshold := 0.7   # stick deflection needed to fire a turn

@export_group("Input Bindings")
@export var horizontal_move_button := "ax_button"   # X on left controller -> front/back + left/right
@export var vertical_move_button := "by_button"     # Y on left controller -> up/down + snap turn
@export var reset_button := "primary_click"         # thumbstick click, both hands

var xr_origin: XROrigin3D
var left_controller: XRController3D
var right_controller: XRController3D

var _reset_held_last_frame := false
var _snap_turn_ready := true


func _ready() -> void:
	xr_origin = get_parent() as XROrigin3D
	if not xr_origin:
		push_warning("XRComfortAdjuster expects to be a direct child of an XROrigin3D.")
		return

	left_controller = get_node_or_null(left_controller_path)
	right_controller = get_node_or_null(right_controller_path)

	if not left_controller or not right_controller:
		_auto_detect_controllers()

	if not left_controller or not right_controller:
		push_warning("XRComfortAdjuster: couldn't find both controllers. Set left_controller_path / right_controller_path explicitly.")


func _auto_detect_controllers() -> void:
	for child in xr_origin.get_children():
		if child is XRController3D:
			if child.tracker == "left_hand" and not left_controller:
				left_controller = child
			elif child.tracker == "right_hand" and not right_controller:
				right_controller = child


func _physics_process(delta: float) -> void:
	if not (left_controller and right_controller and xr_origin):
		return
	_handle_reset()
	_handle_adjustment(delta)


func _handle_reset() -> void:
	var both_pressed := left_controller.is_button_pressed(reset_button) \
		and right_controller.is_button_pressed(reset_button)

	if both_pressed and not _reset_held_last_frame:
		get_tree().reload_current_scene()

	_reset_held_last_frame = both_pressed


func _handle_adjustment(delta: float) -> void:
	var stick: Vector2 = right_controller.get_vector2("primary")
	var horizontal_held := left_controller.is_button_pressed(horizontal_move_button)
	var vertical_held := left_controller.is_button_pressed(vertical_move_button)

	if horizontal_held:
		if abs(stick.y) > stick_deadzone:
			xr_origin.position += -xr_origin.transform.basis.z * stick.y * move_speed * delta
		if abs(stick.x) > stick_deadzone:
			xr_origin.position += xr_origin.transform.basis.x * stick.x * move_speed * delta

	elif vertical_held:
		if abs(stick.y) > stick_deadzone:
			xr_origin.position.y += stick.y * move_speed * delta

		if abs(stick.x) > snap_turn_threshold:
			if _snap_turn_ready:
				xr_origin.rotate_y(deg_to_rad(-snap_turn_angle_deg * sign(stick.x)))
				_snap_turn_ready = false
		else:
			_snap_turn_ready = true
