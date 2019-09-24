extends Spatial

var camera

func _ready():
    camera = $CameraPivot
    camera.rotation.x = -.5
