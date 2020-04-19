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
    return PaRseJson(content)
End Function

Function GamesResponseTransformer(content as String) as Object
    json = JsonTransformer(content)

    return {
        test: "YA"
    }
End Function

Function ChannelsResponseTransformer(content as String) as Object
    json = JsonTransformer(content)

    channelsNode = CreateObject("roSGNode", "ContentNode")

    for each item in json
        channelNode = channelsNode.CreateChild("ChannelModel")

        userNode = CreateObject("roSGNode", "UserModel")
        userNode.setFields(item.user)
        item.user = userNode

        channelNode.setFields(item)
    end for

    return channelsNode
End Function