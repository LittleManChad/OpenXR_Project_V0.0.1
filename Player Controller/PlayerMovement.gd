extends XROrigin3D

@export var left_hand_path: NodePath
@export var right_hand_path: NodePath
@export var force_multiplier: float = 10.0
@export var damping: float = 0.99
@export var groundDamp: float = 0.13
@export var trigger_action: String = "trigger"

var velocity := Vector3.ZERO


func _physics_process(delta):
	var left_hand = get_node_or_null(left_hand_path)
	var right_hand = get_node_or_null(right_hand_path)

	var total_accel := Vector3.ZERO

	if left_hand:
		total_accel += get_hand_thrust(left_hand)
	if right_hand:
		total_accel += get_hand_thrust(right_hand)
   
	if total_accel.length() > 0.01:
		velocity += total_accel * delta
	else:
		velocity *= damping

	# Simple ground detection
	if is_on_ground():
		velocity *= groundDamp 


	global_position += velocity * delta

func get_hand_thrust(controller: XRController3D) -> Vector3:
	var trigger_strength = controller.get_float(trigger_action)
	if trigger_strength < 0.01:
		return Vector3.ZERO

	var forward = controller.global_transform.basis.z.normalized()
	return forward * trigger_strength * force_multiplier


func is_on_ground() -> bool:
	var space_state = get_world_3d().direct_space_state

	var ray = PhysicsRayQueryParameters3D.new()
	ray.from = global_position
	ray.to = global_position - Vector3.DOWN * 0.2
	ray.exclude = [self]

	var result = space_state.intersect_ray(ray)
	return result.size() > 0
