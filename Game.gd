extends Spatial

var delta_accrued = 0
var players = {}
var is_server = false

func _ready():
    set_process(is_server)
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    lug.lug("Game ready")

func _process(delta):
    delta_accrued += delta
    
    while (delta_accrued > .1):
        delta_accrued -= .1
        for i in players:
            var player = players[i]
            if (player.speed):
                player.node.translate(Vector3(cos(player.move_dir), 0, sin(player.move_dir)))
