extends Node

const input_scene = preload("res://Input.tscn")
const player_scene = preload("res://Player.tscn")
const server_scene = preload("res://Server.tscn")

var input
var server
var player

func _ready():
    server = server_scene.instance()
    get_tree().get_root().add_child(server)
    
    var result = get_tree().connect("network_peer_connected", self, "network_peer_connected")
    if (result != OK):
        lug.lug("Input could not connect event: %s" % result)
        return
    
    player = player_scene.instance()
    server.game.players[1] = {"node": player, "speed": 0, "move_dir": 0}
    server.game.add_child(player)
    server.game.show()

    input = input_scene.instance()
    input.listener = self
    get_tree().get_root().add_child(input)

func network_peer_connected(id):
    lug.lug("client network_peer_connected peer_id %s" % id)

    if (id != 1):
        return
    
    input = input_scene.instance()
    get_tree().get_root().add_child(input)

func update_input(speed, move_dir):
    server.game.players[1].speed = speed
    server.game.players[1].move_dir = move_dir

func update_mouse(relative):
    player.rotate_y(-lerp(0, 0.1, relative.x/10))

    player.camera.rotate_x(-lerp(0, 0.1, relative.y/10))
    if (player.camera.rotation.x < deg2rad(-90)):
        player.camera.rotation.x = deg2rad(-90)
    elif (player.camera.rotation.x > -.1):
        player.camera.rotation.x = -.1
