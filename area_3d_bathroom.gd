extends Area3D
@export var jumpscar_model: Node3D
@export var whisper_text: String = "behind you..."

var dialogue_label: Label
var has_triggered := false
@onready var whisper_sfx: AudioStreamPlayer = get_node_or_null("whisper") 

func _ready():
	if jumpscar_model:
		jumpscar_model.visible = false
	monitoring = true
	var root = get_tree().current_scene
	if root:
		dialogue_label = root.find_child("DialogueLabel", true, false) as Label
		if dialogue_label:
			dialogue_label.visible = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body is CharacterBody3D: return
	if has_triggered: return
	if jumpscar_model and jumpscar_model.visible: return
	has_triggered = true
	
	
	if dialogue_label:
		dialogue_label.visible = true
		dialogue_label.text = whisper_text
		if whisper_sfx:
			whisper_sfx.play()
		await get_tree().create_timer(1.5).timeout
		dialogue_label.visible = false
	
	
	if body.has_method("start_flashlight_flicker"):
		body.start_flashlight_flicker()
	
	if jumpscar_model:
		jumpscar_model.visible = true
		print("BATHROOM: behind you + flicker ON")
	
	set_deferred("monitoring", false)
