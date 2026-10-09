extends Camera3D
@export var player_cam: Camera3D
@export var mirror: MeshInstance3D

func _process(_d):
	if player_cam == null or mirror == null: return
	var m_pos = mirror.global_position
	var m_n = -mirror.global_transform.basis.z.normalized()
	var cam_pos = player_cam.global_position
	var diff = cam_pos - m_pos
	global_position = m_pos + diff - 2.0 * diff.dot(m_n) * m_n
	look_at(m_pos, Vector3.UP)
