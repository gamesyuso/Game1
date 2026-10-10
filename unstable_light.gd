extends SpotLight3D

@export var min_energy: float = 0.2
@export var max_energy: float = 1.2

func _ready():
	while true:
		light_energy = randf_range(min_energy, max_energy)
		if randf() > 0.85:
			visible = false
			await get_tree().create_timer(randf_range(0.05, 0.2)).timeout
			visible = true
			light_energy = max_energy
		await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
