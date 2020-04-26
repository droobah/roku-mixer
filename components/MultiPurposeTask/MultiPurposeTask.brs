Sub Init()
  m.top.functionName = "startRegistryTask"
End Sub

Sub startRegistryTask()
  actions = m.top.actions
  responses = []

  for each action in actions
    actionName = action.name
    actionResponse = invalid

    if actionName = "getmanifestversion"
      appInfo = CreateObject("roAppInfo")
      actionResponse = appInfo.GetVersion()
    else if actionName = "readregistry"
      value = readRegistry(action.data.registry, action.data.key)
      actionResponse = value
    else if actionName = "writeregistry"
      writeRegistry(action.data.registry, action.data.key, action.data.value)
    else if actionName = "deleteregistry"
      deleteRegistry(action.data.registry, action.data.key)
    end if

    responses.Push(actionResponse)
  end for

  m.top.response = responses
  m.top.control = "STOP"
End Sub