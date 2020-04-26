Sub Init()
    m.currentCode = invalid
    m.currentHandle = invalid
    m.requestingNewCode = false

    m.codeLabel = m.top.findNode("CodeLabel")
    m.loadingIndicator = m.top.findNode("LoadingIndicator")
    m.pollTimer = m.top.findNode("PollTimer")

    m.pollTimer.observeField("fire", "CheckHandle")

    RequestNewCode()
End Sub

Sub RequestNewCode()
    m.currentCode = invalid
    m.currentHandle = invalid
    m.codeLabel.text = ""
    m.pollTimer.control = "stop"
    m.loadingIndicator.control = "start"
    m.requestingNewCode = true

    body = "client_id=" + m.global.client_id
    body += "&scope=user:details:self channel:follow:self chat:chat chat:connect chat:poll_vote delve:view:self subscription:view:self user:notification:self user:seen:self"
    MakePOSTRequest("https://mixer.com/api/v1/oauth/shortcode", body, "JsonTransformer", "OnNewCodeResponse")
End Sub

Sub OnNewCodeResponse(event as Object)
    response = event.getData()

    m.loadingIndicator.control = "stop"

    if response.code = 200 and response.transformedResponse <> invalid and response.transformedResponse.handle <> invalid
        m.currentCode = response.transformedResponse.code
        m.currentHandle = response.transformedResponse.handle
        m.codeLabel.text = m.currentCode
        m.pollTimer.control = "start"
    else
        m.codeLabel.text = "COD_EERR_TRYAGAIN"
    end if
    m.requestingNewCode = false
End Sub

Sub CheckHandle()
    if m.currentHandle = invalid then return

    MakeGETRequest("https://mixer.com/api/v1/oauth/shortcode/check/" + m.currentHandle, "JsonTransformer", "OnCheckHandleResponse")
End Sub

Sub OnCheckHandleResponse(event as Object)
    response = event.getData()

    if response.code = 403 or response.code = 404
        m.currentCode = invalid
        m.currentHandle = invalid
        m.codeLabel.text = "EXPIRED_OR_DENIED_TRYAGAIN"
        m.pollTimer.control = "stop"
    else if response.code = 200 and response.transformedResponse <> invalid and response.transformedResponse.code <> invalid
        m.pollTimer.control = "stop"
        authorizationCode = response.transformedResponse.code
        ExchangeAuthorizationCodeForAccessToken(authorizationCode)
    end if

    ' response.code = 204 == WAITING
End Sub

Sub ExchangeAuthorizationCodeForAccessToken(code as String)
    body = "client_id=" + m.global.client_id
    body += "&code=" + code
    body += "&grant_type=authorization_code"
    MakePOSTRequest("https://mixer.com/api/v1/oauth/token", body, "JsonTransformer", "OnExchangeTokenResponse")
End Sub

Sub OnExchangeTokenResponse(event as Object)
    response = event.getData()

    if response.code = 200 and response.transformedResponse.access_token <> invalid
        Login(response.transformedResponse.access_token, response.transformedResponse.refresh_token)
    else
        m.currentCode = invalid
        m.currentHandle = invalid
        m.codeLabel.text = "EXCHANGE_ERR_TRYAGAIN"
    end if
End Sub
