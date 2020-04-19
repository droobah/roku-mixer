Sub Init()
    MakeGETRequest("https://ifconfig.co/json", "GamesResponseTransformer", "CallbackTest")
End Sub

Sub CallbackTest(event as Object)
    response = event.getData()

    ? response
    ? response.transformedResponse
End Sub