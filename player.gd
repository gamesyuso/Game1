extends CharacterBody3D
@export var move_speed := 4.0
@export var look_sensitivity := 0.004
@export var gravity := 12.0
@export var interact_range := 2.5
@onready var camera: Camera3D = $PlayerCamera
@onready var held_mesh: MeshInstance3D = $PlayerCamera.get_node_or_null("FlashlightMesh")
@onready var held_light: SpotLight3D = $PlayerCamera.get_node_or_null("Flashlight")
@onready var ray: RayCast3D = $PlayerCamera.get_node_or_null("InteractionRay")
@onready var pickup_sfx: AudioStreamPlayer = get_tree().current_scene.get_node_or_null("PickupSound")
var pickup_btn: Button
var flashlight_btn: Button
var near_item: Node3D = null
var has_flashlight := false
var glitch_rect: ColorRect
var move_input := Vector2.ZERO
var move_touch_id := -1
var move_center := Vector2.ZERO
var look_touch_id := -1
var last_look_pos := Vector2.ZERO
var pitch := 0.0
var flicker_active := false

func _ready():
	var root = get_tree().current_scene
	if root:
		pickup_btn = root.find_child("PickupButton", true, false) as Button
		flashlight_btn = root.find_child("FlashlightButton", true, false) as Button
		if pickup_sfx == null:
			pickup_sfx = root.find_child("PickupSound", true, false) as AudioStreamPlayer
		var gl = root.find_child("GlitchLayer", true, false)
		if gl:
			glitch_rect = gl.find_child("GlitchOverlay", true, false) as ColorRect
			if glitch_rect:
				glitch_rect.visible = false
	if pickup_btn == null:
		_create_button_deferred()
	else:
		_setup_after_button()
	if flashlight_btn:
		flashlight_btn.visible = false
	if held_mesh:
		held_mesh.visible = false
	if held_light:
		held_light.visible = false
	if ray:
		ray.enabled = true
		ray.collide_with_areas = true
		ray.collide_with_bodies = true
		ray.target_position = Vector3(0, 0, -2.5)

func _create_button_deferred():
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	var btn = Button.new()
	btn.name = "PickupButton"
	btn.text = "PICKUP"
	btn.custom_minimum_size = Vector2(280, 80)
	btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	btn.position = Vector2(-140, -130)
	canvas.add_child(btn)
	get_tree().current_scene.call_deferred("add_child", canvas)
	call_deferred("_setup_deferred_button", btn)

func _setup_deferred_button(btn: Button):
	pickup_btn = btn
	_setup_after_button()

func _setup_after_button():
	if pickup_btn:
		pickup_btn.visible = false
		if not pickup_btn.pressed.is_connected(_on_pickup_pressed):
			pickup_btn.pressed.connect(_on_pickup_pressed)
	if flashlight_btn:
		flashlight_btn.visible = false
		flashlight_btn.text = "LIGHT"
		if not flashlight_btn.pressed.is_connected(_on_flashlight_toggled):
			flashlight_btn.pressed.connect(_on_flashlight_toggled)

func _physics_process(delta):
	var found = null
	for item in get_tree().get_nodes_in_group("pickup_item"):
		if not item is Node3D: continue
		if not is_instance_valid(item): continue
		if is_ancestor_of(item): continue
		var dist = global_position.distance_to(item.global_position)
		if dist > interact_range: continue
		var to_item = (item.global_position - camera.global_position).normalized()
		var fwd = -camera.global_transform.basis.z
		var fwd2 = camera.global_transform.basis.z
		var dot = max(fwd.dot(to_item), fwd2.dot(to_item))
		if dot < 0.6: continue
		if ray and ray.is_colliding():
			var col = ray.get_collider()
			var p = col
			while p:
				if p == item or p.is_in_group("pickup_item"):
					found = item
					break
				p = p.get_parent()
			if found: break
		else:
			if dist <= interact_range:
				found = item
				break
	near_item = found
	if pickup_btn:
		pickup_btn.visible = found != null and not has_flashlight
	var right = global_transform.basis.x
	var forward = -global_transform.basis.z
	var dir = right * move_input.x + forward * move_input.y
	dir.y = 0
	if dir.length() > 0.01:
		dir = dir.normalized()
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	velocity.y = velocity.y - gravity * delta if not is_on_floor() else -0.1
	move_and_slide()

func _on_pickup_pressed():
	if near_item and is_instance_valid(near_item):
		if pickup_sfx:
			pickup_sfx.play()
		has_flashlight = true
		if held_mesh: held_mesh.visible = true
		if held_light: held_light.visible = true
		near_item.queue_free()
		if pickup_btn: pickup_btn.visible = false
		if flashlight_btn: flashlight_btn.visible = true

func _on_flashlight_toggled():
	if flicker_active: return 
	if has_flashlight and held_light:
		held_light.visible = !held_light.visible
	if flashlight_btn:
		flashlight_btn.text = "ON" if held_light.visible else "OFF"

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < get_viewport().get_visible_rect().size.x * 0.4:
				move_touch_id = event.index
				move_center = event.position
			else:
				look_touch_id = event.index
				last_look_pos = event.position
		else:
			if event.index == move_touch_id:
				move_touch_id = -1
				move_input = Vector2.ZERO
			if event.index == look_touch_id:
				look_touch_id = -1
	if event is InputEventScreenDrag:
		if event.index == move_touch_id:
			var v = (event.position - move_center) / 60.0
			move_input = Vector2(-v.x, v.y).limit_length(1.0)
		elif event.index == look_touch_id:
			var d = event.position - last_look_pos
			last_look_pos = event.position
			rotate_y(-d.x * look_sensitivity)
			pitch = clamp(pitch - d.y * look_sensitivity, deg_to_rad(-80), deg_to_rad(80))
			camera.rotation.x = pitch


func glitch_camera(duration: float = 1.0, strength: float = 1.0):
	var original_fov = camera.fov
	var original_rot = camera.rotation
	var elapsed := 0.0
	if glitch_rect:
		glitch_rect.visible = true
	while elapsed < duration:
		camera.fov = original_fov + randf_range(-strength * 12.0, strength * 12.0)
		camera.rotation.x = original_rot.x + randf_range(-0.08, 0.08) * strength
		camera.rotation.y = original_rot.y + randf_range(-0.08, 0.08) * strength
		camera.h_offset = randf_range(-0.04, 0.04) * strength
		if glitch_rect and glitch_rect.material:
			glitch_rect.material.set_shader_parameter("intensity", randf_range(0.5, 1.5) * strength)
			glitch_rect.material.set_shader_parameter("time", elapsed * 20.0)
		await get_tree().create_timer(0.04).timeout
		elapsed += 0.04
	camera.fov = original_fov
	camera.rotation = original_rot
	camera.h_offset = 0
	if glitch_rect:
		glitch_rect.visible = false


func start_flashlight_flicker():
	if not has_flashlight: return
	if flicker_active: return
	flicker_active = true
	if flashlight_btn:
		flashlight_btn.text = "!!"
	var orig_energy = 1.5
	if held_light:
		orig_energy = held_light.light_energy
	while flicker_active:
		if held_light:
			held_light.visible = randf() > 0.45
			held_light.light_energy = randf_range(0.1, 2.8) if held_light.visible else 0.0
		await get_tree().create_timer(randf_range(0.05, 0.2)).timeout
	if held_light:
		held_light.visible = true
		held_light.light_energy = orig_energy
	if flashlight_btn:
		flashlight_btn.text = "ON"

func stop_flashlight_flicker():
	flicker_active = false
