extends Node3D

func _ready():
	
	var mirror = get_node_or_null("../MirrorViewport")
	if mirror:
		mirror.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	
	for child in get_all_meshes(self):
		var n = child.name.to_lower()
		
		if "floor" in n or "ground" in n or "plane" in n:
			for i in range(child.mesh.get_surface_count()):
				var mat = child.get_active_material(i)
				if mat is StandardMaterial3D:
					var m = mat.duplicate()
					m.roughness_texture = null
					m.roughness = 0.2
					m.metallic = 0.0
					child.set_surface_override_material(i, m)

func get_all_meshes(node: Node) -> Array:
	var list = []
	for c in node.get_children():
		if c is MeshInstance3D:
			list.append(c)
		list.append_array(get_all_meshes(c))
	return list
