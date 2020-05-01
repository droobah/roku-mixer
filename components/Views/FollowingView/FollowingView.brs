Sub Init()
    m.page = 0
    m.perPage = 30
    m.canFetchData = true
    m.fetchingData = false

    m.drawer = m.top.findNode("Drawer")
    m.followingGridList = m.top.findNode("FollowingGridList")
    m.notLoggedInLabel = m.top.findNode("NotLoggedInLabel")

    m.followingGridListContent = CreateObject("roSGNode", "ContentNode")
    m.followingGridList.content = m.followingGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.followingGridList.observeField("itemSelected", "OnItemSelected")

    if not IsLoggedIn()
        m.notLoggedInLabel.visible = true
        m.top.contentSet = true
    else
        FetchData()
    end if
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.followingGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.followingGridListContent.getChild(index)

    if item <> invalid and item.model_id <> invalid and item.online = true
        PlayLiveStream(item.model_id)
    end if
End Sub

Sub OnPlayerDestroyed()
    m.followingGridList.setFocus(true)
End Sub

Sub FetchData()
    if m.canFetchData = false or m.fetchingData then return

    m.fetchingData = true
    m.followingGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/users/" + m.global.auth.user_id +  "/follows?limit=" + m.perPage.ToStr() + "&order=online:DESC,viewersCurrent:DESC,token:DESC&page=" + m.page.ToStr(), "ChannelsResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.followingGridList.setLoading = false
    hasNextPage = true
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)
        if responseItems.Count() < m.perPage then hasNextPage = false
        m.followingGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    m.page += 1
    m.fetchingData = false
    m.canFetchData = hasNextPage
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> FollowingView >> OnkeyEvent"

    if not press then return false

    if key = "left" and m.followingGridList.isInFocusChain()
        m.drawer.toggle = true
        m.drawer.setFocus(true)
        return true
    else if (key = "right" or key = "back") and m.drawer.isInFocusChain()
        m.drawer.toggle = false
        m.followingGridList.setFocus(true)
        return true
    end if

    return false
End Function