extends GPUParticles3D

func _ready():
	amount = 150
	lifetime = 10.0
	emitting = true
	visibility_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
	
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(4, 2, 4)
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 0.05
	mat.initial_velocity_max = 0.15
	mat.gravity = Vector3(0, -0.01, 0)
	mat.scale_min = 0.1
	mat.scale_max = 0.2
	process_material = mat
	
	var quad = QuadMesh.new()
	quad.size = Vector2(0.15, 0.15)
	
	var quad_mat = StandardMaterial3D.new()
	quad_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad_mat.albedo_color = Color(1, 1, 1, 0.9)
	quad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	quad_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	quad_mat.no_depth_test = true
	
	quad.material = quad_mat
	draw_pass_1 = quad
	
	global_position.y += 1.5
	print("Dust SIMPLE OK")
