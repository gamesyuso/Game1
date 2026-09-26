extends Node3D

@export var mouse_sensitivity: float = 0.003
@export var touch_sensitivity: float = 0.01
@export var min_pitch:float = -60.0
@export var max_pitch:float = 60.0

@onready var spring_arm = $SpringArm3D

var touch_index = -1
var last_touch_pos = Vector2.ZERO

func _ready():
	if OS.has_feature("pc"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _unhandled_input(event):
	# PC: CAM MOVEMENT
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(min_pitch), deg_to_rad(max_pitch)
		)
		
	#PHONE CAM MOVEMENT
	if event is InputEventScreenTouch:
		var joystick = get_tree().get_first_node_in_group("joystick")
		var joystick_touch = joystick.touch_index if joystick else -1
		
		if event.pressed and touch_index == -1 and event.index != joystick_touch:
			touch_index = event.index
			last_touch_pos = event.position
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
		
	if event is InputEventScreenDrag and event.index == touch_index:
		var delta = event.position - last_touch_pos
		last_touch_pos = event.position
		rotate_y(-delta.x * mouse_sensitivity)
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x - delta.y * touch_sensitivity,
			deg_to_rad(min_pitch), deg_to_rad(max_pitch)
		)
			
	#release mouse
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
