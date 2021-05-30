extends Human
class_name Enemy

onready var _nav2d : Navigation2D = get_tree().get_root().get_node("Main/Nav2D")
onready var _player : Player = get_tree().get_root().get_node("Main/Player")
onready var _line2D : Line2D = get_tree().get_root().get_node("Main/Line2D")
onready var _raycast_line2D : Line2D = get_tree().get_root().get_node("Main/RaycastLine2D")

var _nav_path : PoolVector2Array;
var _nav_has_destination :bool;
var _rng = RandomNumberGenerator.new();
var _nav_destination : Vector2;

export var wander_radius :float = 200; 

# Called when the node enters the scene tree for the first time.
func _ready():
	_rng.randomize();

func _physics_process(delta):
	if(_nav_has_destination):
		var prev_position = self.get_global_position();
		_move_along_path(MAX_SPEED * delta);
		_velocity = prev_position.direction_to(self.get_global_position()) * MAX_SPEED;
		_face_velocity_direction();
	
func _move_along_path(dist : float)->void:
	var position = self.get_global_position();
	for i in range(_nav_path.size()):
		var dist_to_next_node = position.distance_to(_nav_path[0]);
		if(dist < dist_to_next_node):
			self.global_position = position.linear_interpolate(_nav_path[0], dist / dist_to_next_node);
			break;
		elif(_nav_path.size() == 1):
			self.global_position = _nav_path[0];
			_nav_path.remove(0);
		else:
			dist -= dist_to_next_node;
			position = _nav_path[0];
			_nav_path.remove(0);

func _get_random_position()->Vector2:
	var rand_radian = _rng.randf_range(0, 2 * PI);
	var rand_radius = _rng.randf_range(0.1, 1) * wander_radius;
	var random_position : Vector2 = Vector2(rand_radius * cos(rand_radian), rand_radius * sin(rand_radian));
	return random_position + get_global_position();

# behavior tree functions
func task_move(task):
	print("task_move");
	if(_nav_path.size() == 0):
		_nav_has_destination = false;
		task.succeed();

func task_set_player_target(task):
	if(_player != null):
		_nav_destination = _player.get_global_position();
		task.succeed();
	else:
		task.failed();

func task_find_random_target(task):
	var random_position = _get_random_position();
	_nav_destination = _nav2d.get_closest_point(random_position);
	task.succeed();

func task_find_path(task):
	print("task_find_path");
	_nav_path = _nav2d.get_simple_path(self.get_global_position(), _nav_destination);
	if(_nav_path.size() == 0):
		task.failed();
	else:
		_line2D.points = _nav_path;
		_nav_has_destination = true;
		task.succeed();

func task_has_path(task):
	if(_nav_path.size() == 0):
		task.failed();
	else:
		task.succeed();

func task_has_los(task):
	var inverse : bool = task.get_param(0);
	var succeed = inverse;
	var space_state = get_world_2d().direct_space_state;
	var raycast_mask : int = 1;
	var result = space_state.intersect_ray(get_global_position(), _player.get_global_position(), [self], raycast_mask);
	var points = [get_global_position()];
	if(result.empty()):
		# didn't hit anything, has los to player
		points.append(_player.get_global_position());
		succeed = !inverse;
	else:
		points.append(result.position);
	_raycast_line2D.points = points;
	if(succeed):
		task.succeed();
	else:
		task.failed();
