Sub Init()
    ? "[GameView] Init()"

    m.top.contentSet = true

    m.page = 0
    m.perPage = 30
    m.canFetchData = false
    m.fetchingData = false

    m.drawer = m.top.findNode("Drawer")
    m.coverPoster = m.top.findNode("CoverPoster")
    m.gamePoster = m.top.findNode("GamePoster")
    m.nameLabel = m.top.findNode("NameLabel")
    m.descriptionLabel = m.top.findNode("DescriptionLabel")
    m.gameStreamsGridList = m.top.findNode("GameStreamsGridList")

    m.gameStreamsGridListContent = CreateObject("roSGNode", "ContentNode")
    m.gameStreamsGridList.content = m.gameStreamsGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.gameStreamsGridList.observeField("itemSelected", "OnItemSelected")
    m.gameStreamsGridList.observeField("itemFocused", "OnItemFocused")
End Sub

Sub OnModelSet(event as Object)
    m.top.unobserveField("modeldata")
    modelData = event.getData()

    if modelData.coverUrl <> invalid and modelData.coverUrl <> ""
        m.gamePoster.uri = modelData.coverUrl
    else
        ' default cover
    end if

    if modelData.backgroundUrl <> invalid and modelData.backgroundUrl <> ""
        m.coverPoster.uri = modelData.backgroundUrl
    end if

    m.nameLabel.text = modelData.name
    m.descriptionLabel.text = modelData.description

    m.canFetchData = true
    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.gameStreamsGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.gameStreamsGridListContent.getChild(index)

    if item <> invalid and item.model_id <> invalid
        PlayLiveStream(item.model_id)
    end if
End Sub

Sub OnItemFocused(event as Object)
    index = event.getData()
    isItemInLastRow = m.gameStreamsGridListContent.getChildCount() - index <= 6
    if isItemInLastRow
        FetchData()
    end if
End Sub

Sub OnPlayerDestroyed()
    m.gameStreamsGridList.setFocus(true)
End Sub

Sub FetchData()
    if m.canFetchData = false or m.fetchingData then return

    m.fetchingData = true
    m.gameStreamsGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/types/" + m.top.modelData.model_id.ToStr() + "/channels?limit=" + m.perPage.ToStr() + "&order=viewersCurrent:DESC&page=" + m.page.ToStr(), "ChannelsResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.gameStreamsGridList.setLoading = false
    hasNextPage = true
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)
        if responseItems.Count() < m.perPage then hasNextPage = false
        m.gameStreamsGridListContent.appendChildren(responseItems)
    end if

    m.page += 1
    m.fetchingData = false
    m.canFetchData = hasNextPage
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> GameView >> OnkeyEvent"

    if not press then return false

    if key = "back" and m.gameStreamsGridList.isInFocusChain() and m.gameStreamsGridList.itemFocused >= 3
        m.gameStreamsGridList.jumpToItem = 0
        return true
    else if key = "left" and m.gameStreamsGridList.isInFocusChain()
        m.drawer.toggle = true
        m.drawer.setFocus(true)
        return true
    else if (key = "right" or key = "back") and m.drawer.isInFocusChain()
        m.drawer.toggle = false
        m.gameStreamsGridList.setFocus(true)
        return true
    end if

    return false
End Function