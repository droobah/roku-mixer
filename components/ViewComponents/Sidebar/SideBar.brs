Sub Init()
    m.backgroundRectangle = m.top.findNode("BackgroundRectangle")
    m.logo = m.top.findNode("Logo")
    m.logoExpanded = m.top.findNode("LogoExpanded")
    m.logoExpandedAdditional = m.top.findNode("LogoExpandedAdditional")
    m.menuMarkupList = m.top.findNode("MenuMarkupList")

    m.menuMarkupListContent = CreateObject("roSGNode", "ContentNode")
    m.menuMarkupList.content = m.menuMarkupListContent

    m.menuItems = [
        {
            itemIconUri: "pkg:/images/icons/home-f.svg.png",
            itemText: "HOME",
            routePath: "/discover",
            isActive: false,
            dynamicComponentName: "SidebarMenuItem"
        },
        {
            itemIconUri: "pkg:/images/icons/heart-f.svg.png",
            itemText: "FOLLOWING",
            routePath: "/following",
            isActive: false,
            dynamicComponentName: "SidebarMenuItem"
        },
        {
            itemIconUri: "pkg:/images/icons/basketball.svg.png",
            itemText: "GAMES",
            routePath: "/games",
            isActive: false,
            dynamicComponentName: "SidebarMenuItem"
        },
        {
            itemIconUri: "pkg:/images/icons/book.svg.png",
            itemText: "BROWSE",
            routePath: "/browse",
            isActive: false,
            dynamicComponentName: "SidebarMenuItem"
        },
        {
            itemIconUri: "pkg:/images/icons/cogs-f.svg.png",
            itemText: "SETTINGS",
            routePath: "/settings",
            isActive: false,
            dynamicComponentName: "SidebarMenuItem"
        },
        {
            itemIconUri: "pkg:/images/icons/user-circle.svg.png",
            itemText: "LOGIN",
            routePath: "/user",
            isActive: false,
            dynamicComponentName: "SidebarMenuItemUser"
        }
    ]

    for each item in m.menuItems
        node = CreateObject("roSGNode", "ContentNode")
        node.addFields(item)
        m.menuMarkupListContent.appendChild(node)
    end for

    ' select default item
    m.defaultSelection = 0
    m.menuMarkupList.jumpToItem = m.defaultSelection
    OnButtonClick(m.defaultSelection)

    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.menuMarkupList.observeField("itemSelected", "OnButtonClick")
    m.global.observeFieldScoped("showSidebar", "OnShowSidebarChange")
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        m.backgroundRectangle.width = 340
        m.logo.visible = false
        m.logoExpanded.visible = true
        m.logoExpandedAdditional.visible = true
        m.menuMarkupList.setFocus(true)
    else if not m.top.isInFocusChain()
        m.backgroundRectangle.width = 136
        m.logo.visible = true
        m.logoExpanded.visible = false
        m.logoExpandedAdditional.visible = false
    end if
End Sub

Sub OnButtonClick(event as Dynamic)
    if type(event) = "roInteger" or type(event) = "Integer"
        index = event
    else
        index = event.getData()
        m.defaultSelection = invalid
    end if

    for i = 0 to m.menuMarkupListContent.getChildCount() - 1
        menuItem = m.menuMarkupListContent.getChild(i)
        menuItem.isActive = i = index
    end for

    m.global.route = m.menuItems[index].routePath
End Sub

Sub OnShowSidebarChange(event as Object)
    m.top.visible = event.getData()
End Sub

Function onKeyEvent(key as String, press as Boolean) as Boolean
    ' Handle only key up event
    if not press then return false

    ? ">>> SideBar >> OnkeyEvent"

    if key = "right"
        itemSelected = m.defaultSelection
        if itemSelected = invalid
            itemSelected = m.menuMarkupList.itemSelected
        end if
        m.menuMarkupList.jumpToItem = itemSelected
    end if

    return false
End Function
