extends Area3D
@export var jumpscare_model: Node3D
@onready var scare_sound = get_node_or_null("JumpscareSound")

var dialogue_label: Label
var has_triggered = false

func _ready():
	monitoring = true
	var root = get_tree().current_scene
	if root:
		dialogue_label = root.find_child("DialogueLabel", true, false) as Label
		if dialogue_label: dialogue_label.visible = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body is CharacterBody3D: return
	if has_triggered: return
	if jumpscare_model and not jumpscare_model.visible: return
	has_triggered = true
	
	
	if jumpscare_model: jumpscare_model.visible = false
	if scare_sound: scare_sound.play()
	if body.has_method("glitch_camera"):
		body.glitch_camera(0.3, 0.8)
	
	await get_tree().create_timer(0.4).timeout
	
	
	if body.has_method("stop_flashlight_flicker"):
		body.stop_flashlight_flicker()
	
	if dialogue_label:
		dialogue_label.visible = true
		dialogue_label.text = "what the fuck is that thing?!"
		await get_tree().create_timer(2.5).timeout
		dialogue_label.visible = false
	
	set_deferred("monitoring", false)
