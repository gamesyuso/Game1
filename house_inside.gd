extends Node3D

func _ready():
	var mat_cache: Dictionary = {}
	
	for mesh in find_children("", "MeshInstance3D", true, false):
		for i in range(mesh.mesh.get_surface_count()):
			var orig = mesh.mesh.surface_get_material(i)
			var albedo_tex = null
			var albedo_col = Color(1, 1, 1)
			
			if orig and orig is StandardMaterial3D:
				albedo_tex = orig.albedo_texture
				albedo_col = orig.albedo_color
				
			if albedo_tex and mat_cache.has(albedo_tex):
				mesh.set_surface_override_material(i, mat_cache[albedo_tex])
			else:
				var override = StandardMaterial3D.new()
				override.roughness = 0.18
				override.metallic = 0.05
				override.metallic_specular = 1.0
				override.albedo_color = albedo_col
				if albedo_tex:
					override.albedo_texture = albedo_tex
					mat_cache[albedo_tex] = override
				mesh.set_surface_override_material(i, override)
	
	var probe = ReflectionProbe.new()
	probe.size = Vector3(30, 15, 30)
	probe.origin_offset = Vector3(0, 5, 0)
	probe.box_projection = true
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	add_child(probe)
	print("Reflection ON kahit locked GLB")
