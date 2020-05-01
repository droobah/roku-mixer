Sub Init()
    ? "[FilterDrawer] Init()"

    m.top.inheritParentTransform = false
    scaleFactor = m.global.scaleFactor

    m.searchValue = ""
    m.languageValue = ""
    m.audienceValue = ""

    m.dimmer = m.top.findNode("Dimmer")
    m.drawer = m.top.findNode("Drawer")
    m.drawerBackground = m.top.findNode("DrawerBackground")
    m.drawerPeekerPoster = m.top.findNode("DrawerPeekerPoster")
    m.filterLabel = m.top.findNode("FilterLabel")
    m.collapseAnimation = m.top.findNode("CollapseAnimation")
    m.expandAnimation = m.top.findNode("ExpandAnimation")
    m.collapsedAnimationInterpolator = m.top.findNode("CollapsedAnimationInterpolator")
    m.expandAnimationInterpolator = m.top.findNode("ExpandAnimationInterpolator")

    ' manually scaling because roku automatic scaling doesn't work correctly on
    ' 720p UI devices when inheritParentTransform is true
    m.drawer.translation = [doScale(-400, scaleFactor), 0]
    m.dimmer.width = doScale(1920, scaleFactor)
    m.dimmer.height = doScale(1080, scaleFactor)
    m.drawerBackground.width = doScale(400, scaleFactor)
    m.drawerBackground.height = doScale(1080, scaleFactor)
    m.drawerPeekerPoster.width = doScale(54, scaleFactor)
    m.drawerPeekerPoster.height = doScale(140, scaleFactor)
    m.drawerPeekerPoster.translation = [doScale(400, scaleFactor), doScale(144, scaleFactor)]
    m.filterLabel.translation = [doScale(3, scaleFactor), doScale(123, scaleFactor)]
    m.collapsedAnimationInterpolator.keyValue = [[0.0, 0.0], [doScale(-400, scaleFactor), 0]]
    m.expandAnimationInterpolator.keyValue = [[doScale(-400, scaleFactor), 0], [0.0, 0.0]]

    m.top.observeField("focusedChild", "OnFocusedChildChange")
End Sub

Sub OnFocusedChildChange()
'   if m.top.isInFocusChain() and not m.drawerBackground.hasFocus()
'     m.drawerBackground.setFocus(true)
'   end if
End Sub

Sub EnabledFiltersSet(event as Object)
    m.top.unobserveField("enabledFilters")

    filters = event.getData()
    for each filter in filters
        if filter = "search"
            BuildSearchFilter()
        else if filter = "language"
            BuildLanguageFilter()
        else if filter = "audience"
            BuildAudienceFilter()
        end if
    end for
End Sub

Sub BuildSearchFilter()

End Sub

Sub BuildLanguageFilter()

End Sub

Sub BuildAudienceFilter()

End Sub

Sub ToggleDrawer(event as Object)
    toggle = event.getData()
    
    if toggle = true
        m.dimmer.opacity = 1.0
        m.expandAnimation.control = "start"
    else
        m.dimmer.opacity = 0.0
        m.collapseAnimation.control = "start"
    end if
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> FilterDrawer >> OnkeyEvent"

    if not press then return false

    ' TODO: don't pass down UP or DOWN key events

    return false
End Function