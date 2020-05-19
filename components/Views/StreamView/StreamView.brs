Sub Init()
    ? "[GameView] Init()"

    m.fetchDataLeft = 3

    m.liveComponent = invalid
    m.recordingsRowList = invalid
    m.clipsRowList = invalid

    m.coverPoster = m.top.findNode("CoverPoster")
    m.coverPosterFadeInAnimation = m.top.findNode("CoverFadeInAnimation")
    m.avatarPoster = m.top.findNode("AvatarPoster")
    m.nameLabel = m.top.findNode("NameLabel")
    m.descriptionLabel = m.top.findNode("DescriptionLabel")
    m.thumbnailRoundedMaskGroup = m.top.findNode("ThumbnailRoundedMaskGroup")
    m.verticalScroller = m.top.findNode("VerticalScroller")

    ' correctly set rounded maskgroup for 720p UI devices
    maskSize = doScale(256, m.global.scaleFactor)
    m.thumbnailRoundedMaskGroup.maskSize = [maskSize, maskSize]

    m.top.observeField("focusedChild", "OnFocusedChildChange")

    CreateComponents()
End Sub

Sub CreateComponents()
    m.liveComponent = CreateObject("roSGNode", "StreamRow")
    m.liveComponent.TITLE = "Live Stream"
    m.liveComponent.observeField("selected", "OnStreamItemSelected")

    font = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Rajdhani-Bold.ttf"
    font.size = 40

    m.recordingsRowList = CreateObject("roSGNode", "EnhancedRowList")
    m.recordingsRowList.setFields({
        "itemComponentName": "RecordingsRowListItem",
        "rowFocusAnimationStyle": "floatingFocus",
        "showRowLabel": [true],
        "rowItemSpacing": [[30, 0]],
        "itemSize": [1920, 424],
        "rowItemSize": [[430, 343]],
        "rowItemFocusSize": [[430, 242]],
        "numRows": 1,
        "focusBitmapUri": "pkg:/images/rounded_focus_$$RES$$.9.png",
        "rowLabelColor": "0xDBDBDB",
        "wrapDividerBitmapUri": "",
        "focusXOffset": [60],
        "rowLabelOffset": [[60, 30]],
        "rowLabelFont": font
    })
    m.recordingsRowList.content = CreateObject("roSGNode", "ContentNode")
    m.recordingsRowList.content.createChild("ContentNode")
    m.recordingsRowList.content.getChild(0).TITLE = "Past Broadcasts"
    m.recordingsRowList.observeField("rowItemSelected", "OnVodItemSelected")

    m.clipsRowList = CreateObject("roSGNode", "EnhancedRowList")
    m.clipsRowList.setFields({
        "itemComponentName": "ClipsRowListItem",
        "rowFocusAnimationStyle": "floatingFocus",
        "showRowLabel": [true],
        "rowItemSpacing": [[30, 0]],
        "itemSize": [1920, 424],
        "rowItemSize": [[430, 343]],
        "rowItemFocusSize": [[430, 242]],
        "numRows": 1,
        "focusBitmapUri": "pkg:/images/rounded_focus_$$RES$$.9.png",
        "rowLabelColor": "0xDBDBDB",
        "wrapDividerBitmapUri": "",
        "focusXOffset": [60],
        "rowLabelOffset": [[60, 30]],
        "rowLabelFont": font
    })
    m.clipsRowList.content = CreateObject("roSGNode", "ContentNode")
    m.clipsRowList.content.createChild("ContentNode")
    m.clipsRowList.content.getChild(0).TITLE = "Clips"
    m.clipsRowList.observeField("rowItemSelected", "OnClipItemSelected")

    m.verticalScroller.addChildren = [
        m.liveComponent,
        m.recordingsRowList,
        m.clipsRowList
    ]
End Sub

Sub OnChannelIdSet(event as Object)
    m.top.unobserveField("channelId")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.verticalScroller.setFocus(true)
    end if
End Sub

Sub OnCoverPosterLoadStatusChange(event as Object)
    status = event.getData()

    if status = "ready"
        m.coverPosterFadeInAnimation.control = "start"
    end if
End Sub

Sub OnStreamItemSelected(event as Object)
    if m.liveComponent.content <> invalid and m.liveComponent.content.online = true
        PlayLiveStream(m.liveComponent.content.model_id)
    end if
End Sub

Sub OnVodItemSelected(event as Object)
    index = event.getData()[1]

    if m.recordingsRowList.content <> invalid
        vod = m.recordingsRowList.content.getChild(0).getChild(index)
        if vod <> invalid
            for each vodResource in vod.vods
                if vodResource.format = "hls"
                    PlayVod(vodResource.baseUrl + "manifest.m3u8")
                    return
                end if
            end for
        end if
    end if
End Sub

Sub OnClipItemSelected(event as Object)
    index = event.getData()[1]

    if m.clipsRowList.content <> invalid
        clip = m.clipsRowList.content.getChild(0).getChild(index)
        if clip <> invalid
            for each clipResource in clip.contentLocators
                if clipResource.locatorType = "HlsStreaming"
                    PlayVod(clipResource.uri)
                    return
                end if
            end for
        end if
    end if
End Sub

Sub OnPlayerDestroyed()
    m.verticalScroller.setFocus(true)
End Sub

Sub FetchData()
    MakeGETRequest("https://mixer.com/api/v1/channels/" + m.top.channelId, "ChannelResponseTransformer", "FetchStreamCallback")
    MakeGETRequest("https://mixer.com/api/v1/channels/" + m.top.channelId + "/recordings?order=createdAt:DESC&limit=20", "RecordingsResponseTransformer", "FetchRecordingsCallback")
    MakeGETRequest("https://mixer.com/api/v1/clips/channels/" + m.top.channelId, "ClipsResponseTransformer", "FetchClipsCallback")
End Sub

Sub FetchDataFinished()
    m.fetchDataLeft -= 1
    if m.fetchDataLeft <= 0
        m.top.contentSet = true
    end if
End Sub

Sub FetchStreamCallback(event as Object)
    response = event.getData()

    if response.transformedResponse <> invalid
        content = response.transformedResponse

        if content.user = invalid or content.user.avatarUrl = invalid or content.user.avatarUrl = ""
            m.avatarPoster.uri = "pkg:/images/default_avatar.png"
        else
            m.avatarPoster.uri = content.user.avatarUrl
        end if

        m.nameLabel.text = content.token

        if content.user <> invalid and content.user.bio <> invalid
            m.descriptionLabel.text = content.user.bio
        end if

        m.liveComponent.content = content
    end if

    FetchDataFinished()
End Sub

Sub FetchRecordingsCallback(event as Object)
    response = event.getData()

    if response.transformedResponse <> invalid
        m.recordingsRowList.content.getChild(0).appendChildren(response.transformedResponse.getChildren(-1, 0))
    end if

    FetchDataFinished()
End Sub

Sub FetchClipsCallback(event as Object)
    response = event.getData()

    if response.transformedResponse <> invalid
        m.clipsRowList.content.getChild(0).appendChildren(response.transformedResponse.getChildren(-1, 0))
    end if

    FetchDataFinished()
End Sub

Function doScale(number as Integer, scaleFactor as Integer) as Integer
    if scaleFactor = 0 or number = 0
        return number
    end if

    scaledValue = number - number / scaleFactor
    return scaledValue
End Function

Function onKeyEvent(key, press) as Boolean
    ? ">>> StreamView >> OnkeyEvent"

    if not press then return false

    return false
End Function