extends XRController3D

@export var thruster_node_path: NodePath
@export var trigger_action: String = "trigger"
@export var force_multiplier: float = 10.0
@export var smoothing: float = 0.1

var velocity := Vector3.ZERO
var smoothed_direction := Vector3.ZERO

func _physics_process(delta):
	var origin = get_parent() # controller -> XROrigin3D
	var thruster_node = get_node_or_null(thruster_node_path)
	
	if origin == null:
		return

	var trigger_strength = get_float(trigger_action)
	
	if trigger_strength > 0.01:
		var local_direction = -thruster_node.transform.basis.z.normalized()
		smoothed_direction = smoothed_direction.lerp(local_direction, smoothing)
		var thrust_world = thruster_node.global_transform.basis * smoothed_direction
		var force = thrust_world * trigger_strength * force_multiplier
		velocity += force * delta
	else:
		velocity *= 0.99  # Damping

	origin.global_position += velocity * delta
