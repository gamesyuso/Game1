extends Node3D

func _ready():
	
	var mirror = get_node_or_null("../MirrorViewport")
	if mirror:
		mirror.render_target_update_mode = SubViewport.UPDATE_DISABLED

	
	print("--- LAHAT NG MESH ---")
	show_all_names(self)
	
	
	make_all_shiny(self)
	
	
	add_probe()

func show_all_names(node: Node):
	for c in node.get_children():
		if c is MeshInstance3D:
			print("Nakita mesh: ", c.name)
		show_all_names(c)

func make_all_shiny(node: Node):
	for c in node.get_children():
		if c is MeshInstance3D and c.mesh:
			for i in range(c.mesh.get_surface_count()):
				var mat = c.get_active_material(i)
				
				var m = StandardMaterial3D.new()
				if mat is StandardMaterial3D:
					m.albedo_texture = mat.albedo_texture
					m.albedo_color = mat.albedo_color
				m.roughness = 0.05 
				m.metallic = 0.0
				c.set_surface_override_material(i, m)
		make_all_shiny(c)

func add_probe():
	if has_node("FloorProbe"): get_node("FloorProbe").queue_free()
	await get_tree().process_frame
	var probe = ReflectionProbe.new()
	probe.name = "FloorProbe"
	probe.size = Vector3(30, 30, 30)
	probe.position = Vector3(0, 2, 0)
	probe.update_mode = ReflectionProbe.UPDATE_ONCE
	probe.intensity = 2.0
	add_child(probe)
