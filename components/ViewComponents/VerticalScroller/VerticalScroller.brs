Sub Init()
    ? "[VerticalScroller] Init()"
    m.currentY = 0
    
    m.lastPressedKey = ""

    m.containerGroup = m.top.findNode("ContainerGroup")
    m.animation = m.top.findNode("Animation")
    m.interpolator = m.top.findNode("Interpolator")
    m.longPressTickTimer = m.top.findNode("LongPressTickTimer")

    m.top.observeField("addChildren", "OnAddChildrenChange")
    m.top.observeField("focusedChild", "OnFocusedChildChange")
    m.longPressTickTimer.observeField("fire", "OnLongPressTick")
End Sub

Sub OnFocusedChildChange()
    if m.top.hasFocus()
        if m.top.itemFocused > -1
            moveToIndex(m.top.itemFocused, false)
        end if
    end if
End Sub

Sub RecalculatePositions()
    y = 0
    index = 0
    for each child in m.containerGroup.getChildren(-1 ,0)
        child.translation = [0, y]
        y += child.boundingRect().height

        if m.top.itemSpacing.Count() - 1 >= index
            y += m.top.itemSpacing[index]
        else if m.top.itemSpacing.Count() > 0
            y += m.top.itemSpacing.Peek()
        end if

        index += 1
    end for
End Sub

Sub OnAddChildrenChange(event as Object)
    children = event.getData()

    if children.Count() > 0
        m.containerGroup.appendChildren(children)

        RecalculatePositions()

        if m.top.itemFocused = -1
            moveToIndex(0, false)
        end if
    end if
End Sub

Sub moveToIndex(index = 0, animate = false, focus = true)
    child = m.containerGroup.getChild(index)
    if child = invalid then return

    m.top.itemFocused = index

    newY = 0 - child.translation[1]

    if animate
        if newY < m.containerGroup.translation[1]
            m.animationDirection = 1
        else
            m.animationDirection = -1
        end if
        
        if m.animation.state = "running"
            m.animation.control = "pause"
        end if
        
        m.interpolator.keyValue = [[0, m.currentY], [0, newY]]
        
        if m.animation.control = "pause"
            m.animation.control = "start"
        else
            m.animation.control = "resume"
        end if
    else
        m.containerGroup.translation = [0, newY]
    end if

    if focus
        child.setFocus(true)
        if child.DoesExist("drawFocusFeedback")
            child.drawFocusFeedback = false
            child.drawFocusFeedback = true
        end if
    end if

    m.currentY = newY
End Sub

Sub OnJumpToIndexChange(event as Object)
    moveToIndex(event.getData(), false)
End Sub

Sub OnAnimateToIndexChange(event as Object)
    moveToIndex(event.getData(), true)
End Sub

Sub OnLongPressTick()
    if m.lastPressedKey = "up"
        moveToIndex(m.top.itemFocused - 1, true)
    else if m.lastPressedKey = "down"
        moveToIndex(m.top.itemFocused + 1, true)
    end if
End Sub

Function onKeyEvent(key, press) as Boolean
    ? ">>> DiscoverView >> OnkeyEvent >> "; key

    if press
        m.lastPressedKey = key
        m.longPressTickTimer.control = "start"

        if key = "up"
            moveToIndex(m.top.itemFocused - 1, true)
            return true
        else if key = "down"
            moveToIndex(m.top.itemFocused + 1, true)
            return true
        end if
    else
        m.longPressTickTimer.control = "stop"
        return true
    end if
  
    return false
End Function
