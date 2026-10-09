extends Node3D

func _ready():
	
	for mesh in find_children("", "MeshInstance3D", true, false):
		for i in range(mesh.mesh.get_surface_count()):
			var override = StandardMaterial3D.new()
			override.roughness = 0.18
			override.metallic = 0.05
			override.metallic_specular = 1.0
			override.albedo_color = Color(1,1,1) 
			
			var orig = mesh.mesh.surface_get_material(i)
			if orig and orig is StandardMaterial3D and orig.albedo_texture:
				override.albedo_texture = orig.albedo_texture
				override.albedo_color = orig.albedo_color
			
			mesh.set_surface_override_material(i, override)
	
	
	var probe = ReflectionProbe.new()
	probe.size = Vector3(30, 15, 30)
	probe.origin_offset = Vector3(0, 5, 0)
	probe.box_projection = true
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	add_child(probe)
	print("Reflection ON kahit locked GLB")
