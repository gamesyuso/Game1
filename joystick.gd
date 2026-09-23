extends Control

var touch_index = -1
var center = Vector2.ZERO
var max_distance = 60.0
var output = Vector2.ZERO

@onready var knob = $knob

# Called when the node enters the scene tree for the first time.
func _ready():
	center = $base.position + $base.size / 2

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1 and $base.get_global_rect().has_point(event.position):
			touch_index = event.index
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			output = Vector2.ZERO
			knob.position = center - knob.size / 2
			
	if event is InputEventScreenDrag and event.index == touch_index:
		var delta = event.position - (global_position + center)
		output = delta / max_distance
		knob.position = center - knob.size / 2 + delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
