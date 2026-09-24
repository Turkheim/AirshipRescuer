extends Node3D
@onready var cannon_base: MeshInstance3D = $Basket/Turret/CannonBase
@onready var cannon_timer: Timer = $CannonTimer
@export var bullet : PackedScene
var can_fire = true
@onready var bullet_spawn: Marker3D = $Basket/Turret/CannonBase/Cannon/BulletSpawn
@export var bullet_speed = 20.0
@onready var muzzle: GPUParticles3D = $Basket/Turret/CannonBase/Cannon/BulletSpawn/Muzzle
@onready var bang: AudioStreamPlayer3D = $Basket/Turret/CannonBase/Cannon/BulletSpawn/Bang
@onready var animation_player: AnimationPlayer = $Basket/Turret/CannonBase/AnimationPlayer



func _on_wheel_turret_hinge_moved(angle: Variant) -> void:
	rotation_degrees.y = angle /8

func _on_wheel_cannon_hinge_moved(angle: Variant) -> void:
	cannon_base.rotation_degrees.x = angle/28
	

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_accept"):
		_fire_gun()

func _on_cannon_fire_hinge_moved(angle: Variant) -> void:
	if angle > 20 and can_fire:
		_fire_gun()
		can_fire = false
		cannon_timer.start()
func _on_cannon_timer_timeout() -> void:
	can_fire = true

func _fire_gun():

	if bullet:
		muzzle.restart()
		bang.play()
		animation_player.play("Cannon_Fire")
		var new_bullet : RigidBody3D = bullet.instantiate()
		if new_bullet:
			new_bullet.set_as_top_level(true)
			add_child(new_bullet)
			new_bullet.transform = bullet_spawn.global_transform
			new_bullet.linear_velocity = new_bullet.transform.basis.z * bullet_speed * -1
