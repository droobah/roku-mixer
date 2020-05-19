Sub init()
    ' Long running task to execute HTTP requests, transforms the responses to
    ' ready-to-use format (ex. MarkupGrid.content)

    m.maxPoolConnections = 15
    m.pool = []
    AddFreshConnectionsToPool(5)

    m.cacheBuster = CreateObject("roDateTime").AsSeconds()

    m.port = createObject("roMessagePort")
    m.top.observeField("request", m.port)
    m.top.observeField("addToPendingRequests", m.port)
    m.top.observeField("refreshToken", m.port)
    m.top.observeField("runPendingRequests", m.port)

    m.top.functionName = "go"
    m.top.control = "RUN"
End Sub

Sub AddFreshConnectionsToPool(quantity=1 as Integer)
    for i = 1 to quantity
        m.pool.Push({
            roUrl: createObject("roUrlTransfer"),
            ready: true
        })
        m.pool.Peek().roUrl.SetCertificatesFile("common:/certs/ca-bundle.crt")
        m.pool.Peek().roUrl.InitClientCertificates()
        m.pool.Peek().roUrl.EnableEncodings(true)
    end for
End Sub

Sub go()
    m.jobsById = {}

    ' contains requests that got token expired response
    ' re-run them after successfully refreshing token
    m.pendingRequests = []

    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGNodeEvent"
            if msg.getField() = "request"
                addRequest(msg.getData())
            else if msg.getField() = "addToPendingRequests"
                m.pendingRequests.Push(msg.getData())
            else if msg.getField() = "runPendingRequests"
                processPendingRequests()
            else if msg.getField() = "refreshToken"
                RefreshToken()
            else
                print "UriFetcher: unrecognized field '"; msg.getField(); "'"
            end if
        else if msgType = "roUrlEvent"
            ' processResponse always runs in a task-thread
            processResponse(msg)
        else
            print "UriFetcher: unrecognized event type '"; msgType; "'"
        end if
    end while
End Sub

Function getNextUnusedPoolIndex() as Integer
    for i = 0 to m.pool.Count() - 1
        if m.pool.GetEntry(i).ready = true
            return i
        end if
    end for

    ' no ready pool found, add new
    if m.pool.Count() < m.maxPoolConnections
        AddFreshConnectionsToPool(1)
        return m.pool.Count() - 1
    end if

    return -1
End Function

Function addRequest(request as Object) as Boolean
    if type(request) <> "roAssociativeArray" then return true

    context = request.context
    ' AA copy of the context. Don't write/change fields to this, only read.
    contextFields = context.getFields()

    if type(context) <> "roSGNode" then return true

    uri = contextFields.uri

    if uri.Len() = 0 then return true

    context.addFields({
        uri: uri
    })

    headers = contextFields.headers

    if headers = invalid
        headers = {}
    end if

    if InStr(uri, "mixer.com/api") > 0
        headers["Accept"] = "application/json"
        headers["Client-ID"] = m.global.client_id
        if m.global.auth.access_token <> ""
            headers["Authorization"] = "Bearer " + m.global.auth.access_token
        end if
    end if

    ? "REQUEST HEADERS"; headers

    method = contextFields.method
    if method = invalid
        method = "GET"
    end if
    method = UCase(method)

    body = contextFields.body
    if body = invalid
        body = ""
    end if

    now = CreateObject("roDateTime").AsSeconds()
    if now - m.cacheBuster > 60
        m.cacheBuster = now
    end if

    nextPoolIndex = getNextUnusedPoolIndex()

    connection = m.pool.GetEntry(nextPoolIndex)
    if connection = invalid
        ? "POOL IS FULL"
        return false
    end if
    connection.ready = false
    connection.roUrl.SetRequest(method)
    connection.roUrl.SetUrl(uri)
    connection.roUrl.SetPort(m.port)
    connection.roUrl.SetHeaders(headers)
    connection.roUrl.EnableFreshConnection(true)
    connection.roUrl.RetainBodyOnError(true)

    idKey = stri(connection.roUrl.getIdentity()).trim()
    if method = "POST" or method = "PUT" or method = "DELETE"
        ok = connection.roUrl.AsyncPostFromString(body)
    else
        ok = connection.roUrl.AsyncGetToString()
    end if

    if ok
        m.jobsById[idKey] = { context: context, xfer: m.pool, poolIndex: nextPoolIndex }
        print "UriFetcher: initiating transfer '"; idkey; "' for URI '"; uri.Left(80); "'"; " succeeded"
        return true
    else
        connection.ready = true
        ? "POOL CONNECTION ERROR! "; nextPoolIndex; " "; connection.roUrl.GetFailureReason()
    end if

    return false
End Function

Sub processResponse(msg as Object)
    idKey = StrI(msg.GetSourceIdentity()).Trim()
    job = m.jobsById[idKey]

    if job = invalid
        print "UriFetcher: event for unknown job "; idkey
        return
    end if

    m.pool.GetEntry(job.poolIndex).ready = true
    m.jobsById.Delete(idKey)

    context = job.context
    ' AA copy of the context. Don't write/change fields to this, only read.
    contextFields = context.getFields()
    uri = contextFields.uri
    callbackParams = contextFields.callbackParams
    responseTransformer = contextFields.responseTransformer

    print "UriFetcher: response for transfer '"; idkey; "' for URI '"; uri; "'"

    ' Token expired, queue the failed request and refresh the token
    if msg.getResponseCode() = 401
        m.top.addToPendingRequests = context
        RefreshToken()
        return
    end if

    headers = msg.GetResponseHeaders()

    if msg.getResponseCode() >= 400
        ? msg
        ? msg.getResponseCode()
        ? msg.GetFailureReason()
        ? headers
        ? msg.GetString()
    end if

    ' Link Headers that contains continuation links for paginated resulsts (there's no "continue" in brs, so bShrug)
    links = {}
    if headers.DoesExist("link")
        parts = headers.Lookup("link").Split(",")
        for each part in parts
            segments = part.Split(";")
            if segments.Count() >= 2
                linkPart = segments[0].Trim()

                if linkPart.Left(1) = "<" and linkPart.Right(1) = ">"
                    linkPart = linkPart.Mid(1, linkPart.Len() - 2)

                    for i = 1 to segments.Count() - 1
                        rel = segments[i].Trim().Split("=")
                        if rel.Count() >= 2
                            relValue = rel[1]

                            if relValue.Left(2) = """" and relValue.Right(2) = """"
                                relValue = relValue.Mid(2, relValue.Len() - 3)
                            end if

                            links.AddReplace(relValue, linkPart)
                        end if
                    end for
                end if
            end if
        end for
    end if

    content = msg.GetString()

    transformedResponse = invalid
    if responseTransformer <> invalid and responseTransformer <> "" and msg.getResponseCode() <> 204 and msg.getResponseCode() < 500
        transformedResponse = CallTransformerFunction(responseTransformer, content)
    end if

    result = {
        code: msg.getResponseCode(),
        headers: headers,
        links: links,
        content: content,
        transformedResponse: transformedResponse,
        callbackParams: callbackParams
    }

    context.response = result
End Sub

Sub RefreshToken()
    if m.top.tokenRefreshing = true then return
    if m.global.auth.refresh_token = "" then return
    m.top.tokenRefreshing = true

    ? "Refreshing Token"

    body = "client_id=" + m.global.client_id
    body += "&refresh_token=" + m.global.auth.refresh_token
    body += "&grant_type=refresh_token"

    MakePOSTRequest("https://mixer.com/api/v1/oauth/token", body, "JsonTransformer", "OnRefreshTokenResponse")
End Sub

Sub OnRefreshTokenResponse(event as Object)
    response = event.getData()

    if response.code = 200 and response.transformedResponse.access_token <> invalid
        Login(response.transformedResponse.access_token, response.transformedResponse.refresh_token)
    else
        Logout()
    end if

    m.top.tokenRefreshing = false
    m.top.tokenRefreshed = true
    m.top.runPendingRequests = true
End Sub

Sub processPendingRequests()
    for each context in m.pendingRequests
        addRequest({ context: context })
    end for
    m.pendingRequests.Clear()
End Sub
