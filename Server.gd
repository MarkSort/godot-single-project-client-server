extends Node

var delta_total = 0
var tick = 0

func _ready():
    lug.lug("Server Ready")

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
