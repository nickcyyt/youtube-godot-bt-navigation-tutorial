extends Human
class_name Enemy

onready var _nav2d : Navigation2D = get_tree().get_root().get_node("Main/Nav2D")
onready var _player : Player = get_tree().get_root().get_node("Main/Player")
onready var _line2D : Line2D = get_tree().get_root().get_node("Main/Line2D")

var _nav_path : PoolVector2Array;
var _nav_has_destination :bool;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;

func _physics_process(delta):
	if(_nav_has_destination):
		var prev_position = self.get_global_position();
		_move_along_path(MAX_SPEED * delta);
		_velocity = prev_position.direction_to(self.get_global_position()) / delta;
		_face_velocity_direction();
	
func _move_along_path(dist : float)->void:
	var position = self.get_global_position();
	for i in range(_nav_path.size()):
		var dist_to_next_node = position.distance_to(_nav_path[0]);
		if(dist < dist_to_next_node):
			self.global_position = position.linear_interpolate(_nav_path[0], dist / dist_to_next_node);
			break;
		else:
			dist -= dist_to_next_node;
			position = _nav_path[0];
			_nav_path.remove(0);

# behavior tree functions
func task_move(task):
	print("task_move");
	if(_nav_path.size() == 0):
		_nav_has_destination = false;
		task.succeed();

func task_find_path(task):
	print("task_find_path");
	_nav_path = _nav2d.get_simple_path(self.get_global_position(), _player.get_global_position());
	if(_nav_path.size() == 0):
		task.failed();
	else:
		_line2D.points = _nav_path;
		_nav_has_destination = true;
		task.succeed();
