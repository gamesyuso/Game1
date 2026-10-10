extends SpotLight3D

@export var flicker_chance: float = 0.5
@export var min_interval: float = 2.0
@export var max_interval: float = 6.0

func _ready():
	await get_tree().create_timer(randf_range(0.2, 1.5)).timeout
	flicker_loop()

func flicker_loop():
	while true:
		await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout
		if randf() < flicker_chance:
			var orig_energy = light_energy
			for i in range(randi_range(3, 7)):
				light_energy = randf_range(0.0, 0.2)
				visible = randf() > 0.4
				await get_tree().create_timer(randf_range(0.05, 0.1)).timeout
			visible = true
			light_energy = orig_energy
