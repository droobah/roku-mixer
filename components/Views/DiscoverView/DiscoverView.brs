Sub Init()
    m.fetchDataTries = 0

    m.featuredCarouselTargetList = m.top.findNode("FeaturedCarouselTargetList")
    m.featuredCarouselTargetListContent = CreateObject("roSGNode", "ContentNode")
    m.featuredCarouselTargetList.content = m.featuredCarouselTargetListContent

    m.top.observeField("focusedChild", "OnFocusedChildChange")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.featuredCarouselTargetList.setFocus(true)
    end if
End Sub

Sub ConfigureFeaturedCarouselTargetList(data as Object)
    sizes = {
        unfocusedWidth: 600,
        unfocusedHeight: 337,
        unfocusedMargin: 60,
        focusedWidth: 800,
        focusedHeight: 450,
        focusedMargin: 90
    }

    focusedTargetSet = CreateObject("roSGNode", "TargetSet")
    middleRectX = (1920 - sizes.focusedWidth) / 2
    focusedTargetSet.targetRects = [
        [
            middleRectX - sizes.focusedMargin * 2 - sizes.unfocusedWidth * 2,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX - sizes.focusedMargin - sizes.unfocusedWidth,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX,
            0,
            sizes.focusedWidth,
            sizes.focusedHeight
        ],
        [
            middleRectX + sizes.focusedWidth + sizes.focusedMargin,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX + sizes.focusedWidth + sizes.focusedMargin * 2 + sizes.unfocusedWidth,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ]
    ]
    m.featuredCarouselTargetList.focusedTargetSet = focusedTargetSet
    
    for each t in focusedTargetSet.targetRects
        ? t
    end for

    unfocusedTargetSet = CreateObject("roSGNode", "TargetSet")
    middleRectX = (1920 - sizes.unfocusedWidth) / 2
    unfocusedTargetSet.targetRects = [
        [
            middleRectX - sizes.unfocusedMargin * 2 -sizes.unfocusedWidth * 2,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX - sizes.unfocusedMargin -sizes.unfocusedWidth,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX + sizes.unfocusedWidth + sizes.unfocusedMargin,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ],
        [
            middleRectX + sizes.unfocusedWidth * 2 + sizes.unfocusedMargin * 2,
            (sizes.focusedHeight - sizes.unfocusedHeight) / 2,
            sizes.unfocusedWidth,
            sizes.unfocusedHeight
        ]
    ]
    m.featuredCarouselTargetList.unfocusedTargetSet = unfocusedTargetSet

    m.featuredCarouselTargetList.targetSet = focusedTargetSet
    ' m.featuredCarouselTargetList.showTargetRects = true

    for each channel in data.channels
        channel.streamThumbnailSmall = "https://thumbs.mixer.com/channel/" + channel.id.ToStr() + ".small.jpg"
        channel.streamThumbnailLarge = "https://thumbs.mixer.com/channel/" + channel.id.ToStr() + ".big.jpg"
        node = CreateObject("roSGNode", "ContentNode")
        node.addFields(channel)
        m.featuredCarouselTargetListContent.appendChild(node)
    end for
End Sub

Sub FetchData()
    m.fetchDataTries += 1

    ? "FETCH TRY "; m.fetchDataTries

    params = "hydrate=true"
    if m.global.auth.user_id <> "" and m.fetchDataTries < 3
        params += "&userId=" + m.global.auth.user_id
    end if

    MakeGETRequest("https://mixer.com/api/v1/delve/home?" + params, "JsonTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    if m.fetchDataTries >= 3 then return

    response = event.getData()

    if response.code = 403
        m.global.uriFetcher.observeFieldScoped("tokenRefreshed", "OnTokenRefreshed")
        m.global.uriFetcher.refreshToken = true
    else
        ? response.transformedResponse
        for each item in response.transformedResponse.rows
            if item.type = "carousel"
                ConfigureFeaturedCarouselTargetList(item)
            end if
        end for
    end if
    
    m.top.contentSet = true
End Sub

Sub OnTokenRefreshed(event as Object)
    m.global.uriFetcher.unobserveFieldScoped("tokenRefreshed")
    FetchData()
End Sub