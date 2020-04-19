Sub MakeGETRequest(url as String, transformerFunction as Dynamic, callbackFunctionName as String, callbackParams = {} as Object)
    context = CreateObject("roSGNode", "Node")
    context.addFields({
        uri: url,
        method: "GET",
        responseTransformer: transformerFunction,
        callbackParams: callbackParams,
        response: {}
    })
    context.observeField("response", callbackFunctionName)
    m.global.uriFetcher.request = { context: context }
End Sub

Sub MakePOSTRequest(url as String, body as String, transformerFunction as Dynamic, callbackFunctionName as String, callbackParams = {} as Object)
    context = CreateObject("roSGNode", "Node")
    context.addFields({
        uri: url,
        method: "POST",
        body: body,
        responseTransformer: transformerFunction,
        callbackParams: callbackParams,
        response: {}
    })
    context.observeField("response", callbackFunctionName)
    m.global.uriFetcher.request = { context: context }
End Sub