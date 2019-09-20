extends Node

func lug(message):
    var datetime = OS.get_datetime()
    var datetimeStr = "%s-%02d-%02d %02d:%02d:%02d " % [
        datetime.year, datetime.month, datetime.day, datetime.hour, datetime.minute, datetime.second
    ]

    print(datetimeStr + message)

    if (OS.get_name() == "Server"):
        var logFile = File.new()
        logFile.open("./log.txt", File.READ_WRITE)
        logFile.seek_end()
        logFile.store_line(datetimeStr + message)
        logFile.close()
