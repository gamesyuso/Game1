extends Node3D

func _ready():
	var mirror = get_node_or_null("../MirrorViewport")
	if mirror:
		mirror.render_target_update_mode = SubViewport.UPDATE_DISABLED

	make_all_shiny(self)

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
