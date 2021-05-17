extends KinematicBody2D
class_name Human

export var MAX_SPEED = 150;

var _velocity :Vector2 = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _face_velocity_direction():
	var rotation_radian :float = atan2(_velocity.y, _velocity.x);
	self.set_rotation(rotation_radian);
