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
    headers["Client-ID"] = "981b6ea733bf504e9916ffe74e24a9e242f68f0e57a138bf"
    if m.global.auth.token <> invalid
      headers["Authorization"] = "Bearer " + m.global.auth.token
    end if
  end if

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

  if msg.getResponseCode() <> 200
    ? msg
    ? msg.getResponseCode()
    ? msg.GetFailureReason()
    ? msg.getResponseHeaders()
    ? msg.GetString()
  end if

  content = msg.GetString()

  transformedResponse = invalid
  if responseTransformer <> invalid and responseTransformer <> ""
    transformedResponse = CallTransformerFunction(responseTransformer, content)
  end if

  result = {
    code: msg.getResponseCode(),
    headers: msg.getResponseHeaders(),
    content: content,
    transformedResponse: transformedResponse,
    callbackParams: callbackParams
  }

  ' Token expired, queue the failed request and refresh the token
  if msg.getResponseCode() = 401
    m.top.addToPendingRequests = context
    if m.top.tokenRefreshing = false
      m.top.tokenRefreshing = true
      refreshToken()
    end if

    return
  end if

  context.response = result
End Sub

Sub refreshToken()
  uri = "https://api.ttvstream.com/refresh_token?access_token="
  uri += m.global.token
  uri += "&refresh_token="
  uri += m.global.refresh_token

  MakeGETRequest(uri, "JsonTransformer", "refreshTokenCallback")
End Sub

Sub refreshTokenCallback(msg as Object)
  response = msg.getData().content

  m.top.tokenRefreshing = false

  registry = CreateObject("roRegistrySection", "Authentication")
  if response <> invalid and response.success = true
    m.global.token = response.token
    m.global.refresh_token = response.refresh_token

    registry.Write("Token", response.token)
    registry.Write("RefreshToken", response.refresh_token)
    registry.Flush()

    m.top.runPendingRequests = true
  else
    m.global.token = ""
    m.global.refresh_token = ""

    registry.Delete("Token")
    registry.Delete("RefreshToken")
    registry.Flush()

    m.global.refreshFailed = true
  end if
End Sub

Sub processPendingRequests()
  for each context in m.pendingRequests
    addRequest({ context: context })
  end for
  m.pendingRequests.Clear()
End Sub
