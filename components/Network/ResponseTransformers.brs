Function CallTransformerFunction(functionName as String, content as String) as Dynamic
    map = {
        "JsonTransformer": JsonTransformer,
        "ChannelsResponseTransformer": ChannelsResponseTransformer,
        "GamesResponseTransformer": GamesResponseTransformer
    }

    if map[functionName] <> invalid
        return map[functionName](content)
    end if

    return invalid
End Function

Function JsonTransformer(content as String) as Object
    return ParseJson(content)
End Function

Function GamesResponseTransformer(content as String) as Object
    json = JsonTransformer(content)

    gamesNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        item.model_id = item.id
        item.Delete("id")

        gameNode = gamesNode.CreateChild("GameTypeModel")
        gameNode.setFields(item)

        ' Use EnhancedMarkupGrid
        gameNode.addFields({
            dynamicComponentName: "GamesViewListItem"
        })
    end for

    return gamesNode
End Function

Function ChannelsResponseTransformer(content as String) as Object
    json = JsonTransformer(content)

    channelsNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        item.model_id = item.id
        item.Delete("id")

        channelNode = channelsNode.CreateChild("ChannelModel")
        item.streamThumbnailSmall = "https://thumbs.mixer.com/channel/" + item.model_id.ToStr() + ".small.jpg"
        item.streamThumbnailLarge = "https://thumbs.mixer.com/channel/" + item.model_id.ToStr() + ".big.jpg"
        channelNode.setFields(item)

        ' Use EnhancedMarkupGrid
        listItemComponentName = "ChannelItemLive"
        if item.online = invalid or item.online = false
            listItemComponentName = "ChannelItemOffline"
        end if
        channelNode.addFields({
            dynamicComponentName: listItemComponentName
        })
    end for

    return channelsNode
End Function