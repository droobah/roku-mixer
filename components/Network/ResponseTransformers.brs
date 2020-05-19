Function CallTransformerFunction(functionName as String, content as Dynamic) as Dynamic
    map = {
        "JsonTransformer": JsonTransformer,
        "ChannelsResponseTransformer": ChannelsResponseTransformer,
        "ChannelResponseTransformer": ChannelResponseTransformer,
        "GamesResponseTransformer": GamesResponseTransformer,
        "GameResponseTransformer": GameResponseTransformer,
        "RecordingsResponseTransformer": RecordingsResponseTransformer,
        "RecordingResponseTransformer": RecordingResponseTransformer,
        "ClipsResponseTransformer": ClipsResponseTransformer,
        "ClipResponseTransformer": ClipResponseTransformer,
        "UserResponseTransformer": UserResponseTransformer,
        "DevelResponseTransformer": DevelResponseTransformer
    }

    if map[functionName] <> invalid
        return map[functionName](content)
    end if

    return invalid
End Function

Function JsonTransformer(content as String) as Object
    return ParseJson(content)
End Function

Function UserResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    userNode = CreateObject("roSGNode", "UserModel")
    json.model_id = json.id
    json.Delete("id")
    userNode.setFields(json)

    return userNode
End Function

Function GamesResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    gamesNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        gameNode = CallTransformerFunction("GameResponseTransformer", item)
        gamesNode.appendChild(gameNode)
    end for

    return gamesNode
End Function

Function GameResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    gameNode = CreateObject("roSGNode", "GameTypeModel")

    json.model_id = json.id
    json.Delete("id")

    gameNode.setFields(json)

    return gameNode
End Function

Function ChannelsResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    channelsNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        channelNode = CallTransformerFunction("ChannelResponseTransformer", item)
        channelsNode.appendChild(channelNode)
    end for

    return channelsNode
End Function

Function ChannelResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    channelNode = CreateObject("roSGNode", "ChannelModel")

    json.model_id = json.id
    json.Delete("id")

    json.streamThumbnailSmall = "https://thumbs.mixer.com/channel/" + json.model_id.ToStr() + ".small.jpg"
    json.streamThumbnailLarge = "https://thumbs.mixer.com/channel/" + json.model_id.ToStr() + ".big.jpg"

    channelNode.setFields(json)

    return channelNode
End Function

Function RecordingsResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    recordingsNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        recordingNode = CallTransformerFunction("RecordingResponseTransformer", item)
        recordingsNode.appendChild(recordingNode)
    end for

    return recordingsNode
End Function

Function RecordingResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    recordingNode = CreateObject("roSGNode", "RecordingModel")

    json.model_id = json.id
    json.Delete("id")

    recordingNode.setFields(json)

    return recordingNode
End Function

Function ClipsResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    clipsNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        clipNode = CallTransformerFunction("ClipResponseTransformer", item)
        clipsNode.appendChild(clipNode)
    end for

    return clipsNode
End Function

Function ClipResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    clipNode = CreateObject("roSGNode", "ClipModel")

    json.model_id = json.id
    json.Delete("id")

    clipNode.setFields(json)

    return clipNode
End Function

Function DevelResponseTransformer(content as Dynamic) as Object
    if type(content) = "String"
        json = JsonTransformer(content)
    else
        json = content
    end if

    rootNode = CreateObject("roSGNode", "ContentNode")

    for each row in json.rows
        rowStyle = invalid
        rowTitle = ""
        rowNode = CreateObject("roSGNode", "ContentNode")

        if row.title <> invalid and type(row.title) = "roAssociativeArray" and row.title.DoesExist("en-US")
            rowTitle = row.title.Lookup("en-US")
        else if row.subHeader <> invalid and type(row.subHeader) = "roAssociativeArray" and row.subHeader.DoesExist("en-US")
            rowTitle = row.subHeader.Lookup("en-US")
        end if

        if row.type = "carousel" and row.channels <> invalid
            rowStyle = "carouselChannels"
            rowNode.appendChild(CallTransformerFunction("ChannelsResponseTransformer", row.channels))
        else
            if row.hydration <> invalid and row.hydration.results <> invalid
                if row.type = "channels" and row.style = "onlyOnMixer"
                    rowStyle = "partnerChannels"
                    rowNode.appendChild(CallTransformerFunction("ChannelsResponseTransformer", row.hydration.results))
                else if row.type = "channels"
                    rowStyle = "channels"
                    rowNode.appendChild(CallTransformerFunction("ChannelsResponseTransformer", row.hydration.results))
                else if row.type = "games"
                    rowStyle = "games"
                    rowNode.appendChild(CallTransformerFunction("GamesResponseTransformer", row.hydration.results))
                end if
            end if
        end if

        if rowStyle <> invalid
            rowNode.getChild(0).TITLE = rowTitle
            rowNode.addFields({
                rowStyle: rowStyle,
            })
            rootNode.appendChild(rowNode)
        end if
    end for

    return rootNode
End Function
