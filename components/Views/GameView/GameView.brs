Sub Init()
    ? "[GameView] Init()"

    m.top.contentSet = true

    m.page = 0
    m.perPage = 30
    m.canFetchData = false
    m.fetchingData = false

    m.coverPoster = m.top.findNode("CoverPoster")
    m.coverPosterFadeInAnimation = m.top.findNode("CoverFadeInAnimation")
    m.gamePoster = m.top.findNode("GamePoster")
    m.viewerCountBadge = m.top.findNode("ViewerCountBadge")
    m.nameLabel = m.top.findNode("NameLabel")
    m.descriptionLabel = m.top.findNode("DescriptionLabel")
    m.gameStreamsGridList = m.top.findNode("GameStreamsGridList")
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.maskGroupShrinkInterp = m.top.findNode("MaskGroupShrinkInterp")
    m.maskGroupExpandInterp = m.top.findNode("MaskGroupExpandInterp")
    m.headerShrinkAnimation = m.top.findNode("HeaderShrinkAnimation")
    m.headerExpandAnimation = m.top.findNode("HeaderExpandAnimation")

    m.headerShrinked = false

    m.gameStreamsGridListContent = CreateObject("roSGNode", "ContentNode")
    m.gameStreamsGridList.content = m.gameStreamsGridListContent

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(300, m.global.scaleFactor)
    maskSizeShrinked = doScale(120, m.global.scaleFactor)
    m.thumbnailRoundedMaskGroup.maskSize = [maskSize, maskSize]
    m.maskGroupShrinkInterp.keyValue = [[maskSize, maskSize], [maskSizeShrinked, maskSizeShrinked]]
    m.maskGroupExpandInterp.keyValue = [[maskSizeShrinked, maskSizeShrinked], [maskSize, maskSize]]

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
        m.coverPoster.observeField("loadStatus", "OnCoverPosterLoadStatusChange")
        m.coverPoster.uri = modelData.backgroundUrl
    end if

    if modelData.viewersCurrent <> invalid
        m.viewerCountBadge.text = modelData.viewersCurrent.ToStr()
    else
        m.viewerCountBadge.text = ""
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

Sub OnCoverPosterLoadStatusChange(event as Object)
    status = event.getData()

    if status = "ready"
        m.coverPosterFadeInAnimation.control = "start"
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

    if index <= 2 and m.headerShrinked
        m.headerShrinkAnimation.control = "finish"
        m.headerExpandAnimation.control = "start"
        m.headerShrinked = false
    else if index >= 3 and not m.headerShrinked
        m.headerShrinkAnimation.control = "finish"
        m.headerShrinkAnimation.control = "start"
        m.headerShrinked = true
    end if

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

Function doScale(number as Integer, scaleFactor as Integer) as Integer
    if scaleFactor = 0 or number = 0
        return number
    end if

    scaledValue = number - number / scaleFactor
    return scaledValue
End Function

Function onKeyEvent(key, press) as Boolean
    ? ">>> GameView >> OnkeyEvent"

    if not press then return false

    return false
End Function