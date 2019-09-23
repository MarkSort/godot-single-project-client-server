extends Node

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 1337

const game_scene = preload("res://Game.tscn")
const player_scene = preload("res://Player.tscn")

var players = {}

var game

func _ready():
    var peer = NetworkedMultiplayerENet.new()
    get_tree().connect("network_peer_connected", self, "network_peer_connected")
    get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")
    get_tree().multiplayer.connect("network_peer_packet", self, "network_peer_packet")

    var result = peer.create_client(SERVER_IP, SERVER_PORT)
    if (result != OK):
        lug.lug("create_client result %s" % result)
        return

    get_tree().set_network_peer(peer)
    
    set_process(false)

    lug.lug("Client Ready")

func network_peer_connected(id):
    lug.lug("client network_peer_connected peer_id %s" % id)
    
    set_process(true)

    game = game_scene.instance()
    get_tree().get_root().add_child(game)
    var player = player_scene.instance()
    players[get_tree().multiplayer.get_network_unique_id()] = player
    game.add_child(player)
    game.show()

func network_peer_disconnected(id):
    lug.lug("client network_peer_disconnected peer_id %s" % id)
    
    set_process(false)

func network_peer_packet(id, packet):
    var message = packet.get_string_from_ascii()
    lug.lug("got message %s" % message)

    var player_messages = message.split("|")

    var tick = player_messages[0]
    player_messages.remove(0)
    lug.lug("tick %s" % tick)
    
    for player_message in player_messages:
        var x = player_message.split(",")
        lug.lug("player id %s x %s z %s" % [x[0], x[1], x[2]])
