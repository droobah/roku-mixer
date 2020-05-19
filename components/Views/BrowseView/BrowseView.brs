Sub Init()
    ? "[BrowseView] Init()"

    m.searchFilter = false
    m.audienceFilter = false
    m.languageFilter = false
    m.partnerFilter = false

    m.page = 0
    m.perPage = 30
    m.canFetchData = true

    m.fetchingData = false

    m.browseGridList = m.top.findNode("BrowseGridList")

    m.browseGridListContent = CreateObject("roSGNode", "ContentNode")
    m.browseGridList.content = m.browseGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.browseGridList.observeField("itemSelected", "OnItemSelected")
    m.browseGridList.observeField("itemFocused", "OnItemFocused")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.browseGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.browseGridListContent.getChild(index)

    if item <> invalid and item.model_id <> invalid
        m.global.route = "/stream/" + item.model_id.ToStr()
    end if
End Sub

Sub OnItemFocused(event as Object)
    index = event.getData()

    isItemInLastRow = m.browseGridListContent.getChildCount() - index <= 3
    if isItemInLastRow
        FetchData()
    end if
End Sub

Sub FetchData()
    if m.canFetchData = false or m.fetchingData then return

    m.fetchingData = true
    m.browseGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/channels?limit=" + m.perPage.ToStr() + "&order=viewersCurrent:DESC&page=" + m.page.ToStr(), "ChannelsResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.browseGridList.setLoading = false
    hasNextPage = true
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)

        for each item in responseItems
            listItemComponentName = "ChannelsMarkupGridItemLive"
            if item.online = invalid or item.online = false
                listItemComponentName = "ChannelsMarkupGridItemOffline"
            end if
            item.addFields({
                dynamicComponentName: listItemComponentName
            })
        end for

        if responseItems.Count() < m.perPage then hasNextPage = false
        m.browseGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    m.page += 1
    m.fetchingData = false
    m.canFetchData = hasNextPage
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> BrowseView >> OnkeyEvent"

    if not press then return false

    return false
End Function