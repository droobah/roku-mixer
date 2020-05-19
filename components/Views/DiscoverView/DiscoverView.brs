Sub Init()
    m.fetchDataTries = 0

    m.verticalScroller = m.top.findNode("VerticalScroller")
    m.top.observeField("focusedChild", "OnFocusedChildChange")

    FetchData()
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.verticalScroller.setFocus(true)
    end if
End Sub

Sub FetchData()
    m.fetchDataTries += 1

    params = "hydrate=true"
    if m.global.auth.user_id <> "" and m.fetchDataTries < 3
        params += "&userId=" + m.global.auth.user_id
    end if

    MakeGETRequest("https://mixer.com/api/v1/delve/home?" + params, "DevelResponseTransformer", "FetchDataCallback")
End Sub

Sub FetchDataCallback(event as Object)
    if m.fetchDataTries >= 3 then return

    response = event.getData()

    if response.code = 403
        m.global.uriFetcher.observeFieldScoped("tokenRefreshed", "OnTokenRefreshed")
        m.global.uriFetcher.refreshToken = true
    else if response.transformedResponse <> invalid
        rowLists = []

        for each child in response.transformedResponse.getChildren(-1, 0)
            rowList = invalid

            if child.rowStyle = "carouselChannels"
                rowList = CreateRowList("ChannelsCarouselFeaturedRowListItem", {
                    "itemSize": [1784, 430],
                    "rowItemSize": [[620, 349]],
                    "rowItemFocusSize": [[620, 349]]
                })
            else if child.rowStyle = "partnerChannels"
                rowList = CreateRowList("ChannelsPartnerFeaturedRowListItem", {
                    "itemSize": [1784, 481],
                    "rowItemSize": [[280, 400]],
                    "rowItemFocusSize": [[280, 400]]
                })
            else if child.rowStyle = "channels"
                items = child.getChild(0)
                for i = items.getChildCount() - 1 to 0 step -1
                    if items.getChild(i).online = false
                        items.removeChildIndex(i)
                    end if
                end for
                rowList = CreateRowList("ChannelsFeaturedRowListItemLive", {
                    "itemSize": [1784, 583],
                    "rowItemSize": [[564, 502]],
                    "rowItemFocusSize": [[564, 318]]
                })
            else if child.rowStyle = "games"
                rowList = CreateRowList("GamesFeaturedRowListItem", {
                    "itemSize": [1784, 480],
                    "rowItemSize": [[300, 399]],
                    "rowItemFocusSize": [[300, 300]]
                })
            end if

            if rowList <> invalid
                rowList.content = child
                rowLists.Push(rowList)
            end if
        end for

        m.verticalScroller.addChildren = rowLists
    end if
    
    m.top.contentSet = true
End Sub

Sub OnTokenRefreshed(event as Object)
    m.global.uriFetcher.unobserveFieldScoped("tokenRefreshed")
    FetchData()
End Sub

Function CreateRowList(componentName as String, fields as Object) as Object
    font = CreateObject("roSGNode", "Font")
    font.uri = "pkg:/fonts/Rajdhani-Bold.ttf"
    font.size = 40

    rowList = CreateObject("roSGNode", "EnhancedRowList")
    rowList.setFields({
        "itemComponentName": componentName,
        "rowFocusAnimationStyle": "floatingFocus",
        "showRowLabel": [true],
        "rowItemSpacing": [[48, 0]],
        "numRows": 1,
        "focusBitmapUri": "pkg:/images/rounded_focus_$$RES$$.9.png",
        "rowLabelColor": "0xDBDBDB",
        "wrapDividerBitmapUri": "",
        "focusXOffset": [60],
        "rowLabelOffset": [[60, 30]],
        "rowLabelFont": font
    })
    rowList.setFields(fields)
    rowList.observeField("rowItemSelected", "OnRowItemSelected")
    return rowList
End Function

Sub OnRowItemSelected(event as Object)
    index = event.getData()
    node = event.getRoSGNode()
    rowStyle = node.content.rowStyle

    if rowStyle = invalid then return

    item = node.content.getChild(index[0]).getChild(index[1])

    if item = invalid or item.model_id = invalid then return

    if rowStyle = "carouselChannels" or rowStyle = "channels" or rowStyle = "partnerChannels"
        m.global.route = "/stream/" + item.model_id.ToStr()
    else if rowStyle = "games"
        m.global.routeWithExtra = {
            route: "/game/" + item.model_id.ToStr(),
            extra: {
                modelData: item
            }
        }
    end if
End Sub
