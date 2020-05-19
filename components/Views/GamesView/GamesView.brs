Sub Init()
    ? "[GamesView] Init()"

    m.page = 0
    m.perPage = 30
    m.canFetchData = true
    m.fetchingData = false

    m.gamesGridList = m.top.findNode("GamesGridList")

    m.gamesGridListContent = CreateObject("roSGNode", "ContentNode")
    m.gamesGridList.content = m.gamesGridListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.gamesGridList.observeField("itemSelected", "OnItemSelected")
    m.gamesGridList.observeField("itemFocused", "OnItemFocused")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.gamesGridList.setFocus(true)
    end if
End Sub

Sub OnItemSelected(event as Object)
    index = event.getData()
    item = m.gamesGridListContent.getChild(index)

    if item <> invalid and item.model_id <> invalid
        m.global.routeWithExtra = {
            route: "/game/" + item.model_id.ToStr(),
            extra: {
                modelData: item
            }
        }
    end if
End Sub

Sub OnItemFocused(event as Object)
    index = event.getData()
    isItemInLastRow = m.gamesGridListContent.getChildCount() - index <= 6
    if isItemInLastRow
        FetchData()
    end if
End Sub

Sub FetchData()
    if m.canFetchData = false or m.fetchingData then return

    m.fetchingData = true
    m.gamesGridList.setLoading = true
    MakeGETRequest("https://mixer.com/api/v1/types?limit=" + m.perPage.ToStr() + "&order=viewersCurrent:DESC&page=" + m.page.ToStr(), "GamesResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    m.gamesGridList.setLoading = false
    hasNextPage = true
    response = event.getData()

    if response.transformedResponse <> invalid
        responseItems = response.transformedResponse.getChildren(-1, 0)

        for each item in responseItems
            item.addFields({
                dynamicComponentName: "GamesMarkupGridItem"
            })
        end for

        if responseItems.Count() < m.perPage then hasNextPage = false
        m.gamesGridListContent.appendChildren(responseItems)

        m.top.contentSet = true
    end if

    m.page += 1
    m.fetchingData = false
    m.canFetchData = hasNextPage
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> GamesView >> OnkeyEvent"

    if not press then return false

    return false
End Function