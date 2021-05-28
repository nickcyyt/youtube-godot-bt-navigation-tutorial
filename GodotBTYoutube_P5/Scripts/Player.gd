extends Human
class_name Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var input_vector = Vector2.ZERO;
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	
	if(input_vector != Vector2.ZERO):
		input_vector = input_vector.normalized();
		_velocity = input_vector * MAX_SPEED * delta;
		_face_velocity_direction();
	else:
		_velocity = Vector2.ZERO;
	move_and_collide(_velocity);
