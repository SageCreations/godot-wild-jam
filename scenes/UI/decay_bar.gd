extends ProgressBar

func _ready() -> void:
	self.value = AirFilter.air

func _process(_delta: float) -> void:
	self.value = AirFilter.air
