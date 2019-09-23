extends Node

const SERVER_PORT = 1337
const MAX_PLAYERS = 100

const game_scene = preload("res://Game.tscn")
const player_scene = preload("res://PlayerOther.tscn")

var delta_total = 0
var tick = 1
var players = {}

var game

func _ready():
    var peer = NetworkedMultiplayerENet.new()
    get_tree().connect("network_peer_connected", self, "network_peer_connected")
    get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")

    var result = peer.create_server(SERVER_PORT, MAX_PLAYERS)
    if (result != OK):
        lug.lug("create_server result %s" % result)
        return

    get_tree().set_network_peer(peer)

    lug.lug("Server Ready")
    
    game = game_scene.instance()
    game.hide()
    get_tree().get_root().add_child(game)


func _process(delta):
    delta_total += delta
    var ticks = 0
    
    while (delta_total > 1):
        ticks += 1
        delta_total -= 1
        lug.lug("processed tick %s" % tick)
        tick += 1

    if (ticks > 1):
        lug.lug("more than 1 tick processed in single _process call")

    if (ticks > 0 && get_tree().multiplayer.get_network_connected_peers().size() > 0): 
        var message = "%s" % tick
        for id in players:
            message += "|%s," % id
            var origin = players[id].node.get_global_transform().origin
            message += "%s," % origin.x
            message += "%s" % origin.z
        lug.lug("message %s" % message)
        
        get_tree().multiplayer.send_bytes(message.to_ascii(), 0, NetworkedMultiplayerPeer.TRANSFER_MODE_UNRELIABLE)
        
func network_peer_connected(id):
    lug.lug("server network_peer_connected peer_id %s" % id)
    var player = player_scene.instance()
    player.translate(Vector3(0, 0, players.size() * -1.5))
    players[id] = {"node": player, "up": false, "down": false, "left": false, "right": false}
    game.add_child(player)

func network_peer_disconnected(id):
    lug.lug("server network_peer_disconnected peer_id %s" % id)
    game.remove_child(players[id].node)
    players.erase(id)
