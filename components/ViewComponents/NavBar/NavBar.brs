Sub Init()
  print "[NavBar] Init()"

  m.buttonsContainerMarginX = 21
  m.buttonCollapsedWidth = 48
  m.buttonSpacingX = 40
  m.buttonHeight = 48

  m.calculateWidthLabel = m.top.findNode("CalculateWidthLabel")
  m.buttonsTargetList = m.top.findNode("ButtonsTargetList")

  m.buttonsTargetListContent = CreateObject("roSGNode", "ContentNode")
  m.buttonsTargetList.content = m.buttonsTargetListContent

  m.content = [{
    title: "DISCOVER",
    icon: "pkg:/images/discover.png",
    iconColor: "0xD82B2B",
    routePath: "/discover",
    dynamicComponentName: "NavbarMenuItem"
  }, {
    title: "FOLLOWING",
    icon: "pkg:/images/following.png",
    routePath: "/following",
    dynamicComponentName: "NavbarMenuItem"
  }, {
    title: "GAMES",
    icon: "pkg:/images/games.png",
    routePath: "/games",
    dynamicComponentName: "NavbarMenuItem"
  }, {
    title: "BROWSE",
    icon: "pkg:/images/browse.png",
    routePath: "/browse",
    dynamicComponentName: "NavbarMenuItem"
  }, {
    title: "SETTINGS",
    icon: "pkg:/images/settings.png",
    routePath: "/settings",
    dynamicComponentName: "NavbarMenuItem"
  }, {
    title: "LOGIN",
    icon: "pkg:/images/user.png",
    routePath: "/login",
    dynamicComponentName: "NavBarMenuItemUser",
    profileButton: true
  }]

  m.focusedTargetSetRects = []
  m.unfocusedTargetSetRects = []

  SetContent()
  SetTargetListRects()
  ' m.buttonsTargetList.setFocus(true)

  ' select default item
  m.defaultSelection = 0
  m.buttonsTargetList.animateToItem = m.defaultSelection
  OnButtonClick(m.defaultSelection)

  m.top.observeField("focusedChild", "OnFocusedChildChange")
  m.buttonsTargetList.observeField("itemSelected", "OnButtonClick")
  m.global.observeFieldScoped("currentRoute", "OnCurrentRouteChanged")
End Sub

Sub OnFocusedChildChange()
  if m.top.isInFocusChain()
    m.buttonsTargetList.opacity = 1.0
    if not m.buttonsTargetList.isInFocusChain()
      m.buttonsTargetList.setFocus(true)
    end if
  else
    m.buttonsTargetList.opacity = 0.5
  end if
End Sub

Sub OnButtonClick(event as Dynamic)
  if type(event) = "roInteger" or type(event) = "Integer"
    index = event
  else
    index = event.getData()
    m.defaultSelection = invalid
  end if

  m.global.route = m.content[index].routePath
End Sub

Sub OnCurrentRouteChanged(event as Object)
  route = event.getData()
  ' TODO: react to route change here and change active menu item

  ' if route.name = invalid then return
  ' for i = 0 to m.top.content.Count() - 1
  '   m.buttonsContainer.findNode(m.top.content[i].key).isSelected = startsWith(m.top.content[i].routeName, route.name)
  ' end for
End Sub

Sub AddMenuItem(item)
  unfocusedItemWidth = m.buttonCollapsedWidth
  
  ' Add unfocused item rect for all existing sets
  for each rect in m.focusedTargetSetRects
    rect.Push([
      rect.Peek()[0] + rect.Peek()[2] + m.buttonSpacingX, 0, unfocusedItemWidth, m.buttonHeight
    ])
  end for

  ' New item as focused rect
  tempRects = []
  xOffset = m.buttonsContainerMarginX
  for i = 0 to m.focusedTargetSetRects.Count() - 1
    tempRects.Push([
      xOffset, 0, unfocusedItemWidth, m.buttonHeight
    ])
    xOffset += unfocusedItemWidth + m.buttonSpacingX
  end for

  x = m.buttonsContainerMarginX
  if tempRects.Count() > 0
    x = tempRects.Peek()[0] + tempRects.Peek()[2] + m.buttonSpacingX
  end if
  tempRects.Push([
    x, 0, m.buttonCollapsedWidth + GetButtonTextWidth(item.title) + 9, m.buttonHeight
  ])

  m.focusedTargetSetRects.Push(tempRects)

  ' Add unfocused rect to unfocused set
  x = m.buttonsContainerMarginX
  if m.unfocusedTargetSetRects.Count() > 0
    x = m.unfocusedTargetSetRects.Peek()[0] + m.unfocusedTargetSetRects.Peek()[2] + m.buttonSpacingX
  end if
  m.unfocusedTargetSetRects.Push([ x, 0, unfocusedItemWidth, m.buttonHeight ])
End Sub

Sub AddMenuItemProfileButton(item)
  unfocusedItemWidth = m.buttonCollapsedWidth
  
  ' Add unfocused item rect for all existing sets
  for each rect in m.focusedTargetSetRects
    rect.Push([
      1920 - m.buttonsTargetList.translation[0] - unfocusedItemWidth - m.buttonsContainerMarginX, 0, unfocusedItemWidth, m.buttonHeight
    ])
  end for

  ' New item as focused rect
  tempRects = []
  xOffset = m.buttonsContainerMarginX
  for i = 0 to m.focusedTargetSetRects.Count() - 1
    tempRects.Push([
      xOffset, 0, unfocusedItemWidth, m.buttonHeight
    ])
    xOffset += unfocusedItemWidth + m.buttonSpacingX
  end for

  tempRects.Push([
    1920 - m.buttonsTargetList.translation[0] - unfocusedItemWidth - m.buttonsContainerMarginX - 240 - 9, 0, m.buttonCollapsedWidth + 240 + 9, m.buttonHeight
  ])

  m.focusedTargetSetRects.Push(tempRects)

  ' Add unfocused rect to unfocused set
  m.unfocusedTargetSetRects.Push([ 1920 - m.buttonsTargetList.translation[0] - unfocusedItemWidth - m.buttonsContainerMarginX, 0, unfocusedItemWidth, m.buttonHeight ])
End Sub

Sub SetTargetListRects()
  for each item in m.content
    if item.profileButton <> invalid and item.profileButton = true
      AddMenuItemProfileButton(item)
    else
      AddMenuItem(item)
    end if
  end for

  ' Create sets from rectangles
  m.focusedTargetSet = []
  for i = 0 to m.focusedTargetSetRects.Count() - 1
    rect = m.focusedTargetSetRects[i]

    ' bug workaround https://community.roku.com/t5/Roku-Developer-Program/TargetList-with-2-children-acts-really-weird-on-animation/td-p/449373
    rect.Unshift([
      -100, 0, 1, 1
    ])
    rect.Push([
      2020, 0, 1, 1
    ])

    focusedSet = CreateObject("roSGNode", "TargetSet")
    focusedSet.focusIndex = i + 1 ' continuation from above bug workaround
    focusedSet.color = "0x00FF0033"
    focusedSet.targetRects = rect
    m.focusedTargetSet.Push(focusedSet)
  end for

  m.buttonsTargetList.focusedTargetSet = m.focusedTargetSet
  ' m.buttonsTargetList.showTargetRects = true


  ' bug workaround https://community.roku.com/t5/Roku-Developer-Program/TargetList-with-2-children-acts-really-weird-on-animation/td-p/449373
  m.unfocusedTargetSetRects.Unshift([
    -100, 0, 1, 1
  ])
  m.unfocusedTargetSetRects.Push([
    2020, 0, 1, 1
  ])

  m.unfocusedTargetSet = CreateObject("roSGNode", "TargetSet")
  m.unfocusedTargetSet.targetRects = m.unfocusedTargetSetRects
  ' m.buttonsTargetList.unfocusedTargetSet = m.unfocusedTargetSet

  m.buttonsTargetList.targetSet = m.focusedTargetSet[0]
End Sub

Sub SetContent()
  for each item in m.content
    node = CreateObject("roSGNode", "ContentNode")
    node.addFields({
      data: item
    })
    m.buttonsTargetListContent.appendChild(node)
  end for
End Sub

Function GetButtonTextWidth(txt as String) as Integer
  m.calculateWidthLabel.text = txt
  return m.calculateWidthLabel.boundingRect().width
End Function

' Sub SetContent()
'   totalWidth = 0
'   for each item in m.top.content
'     menuItem = CreateObject("roSGNode", "HeaderMenuItem")
'     menuItem.id = item.key
'     menuItem.data = item
'     m.buttonsContainer.appendChild(menuItem)
'     totalWidth += menuItem.boundingRect().width + m.buttonsSpacing
'   end for
'   ' center the buttons
'   ' x = (m.top.width - totalWidth) / 2
'   ' if x < 0 then x = 0
'   ' center the buttons vertically
'   x = 60
'   y = 84 / 2 - m.buttonsContainer.boundingRect().height / 2
'   m.buttonsContainer.translation = [x, y]
'   m.top.unobserveField("content")
' End Sub

' Sub FocusButton(index as Integer)
'   for i = 0 to m.top.content.Count() - 1
'     if i = index
'       wasAlreadyFocused = false
'       if m.top.focusedItem = index
'         wasAlreadyFocused = true
'       end if

'       m.top.focusedItem = index
'       m.buttonsContainer.findNode(m.top.content[i].key).setFocus(true)
'     else
'       m.buttonsContainer.findNode(m.top.content[i].key).setFocus(false)
'     end if
'   end for
' End Sub

' Sub ClickButton(index as Integer, focus=true as Boolean)
'   if index <= m.top.content.Count() - 1:
'     m.global.route = {
'       name: m.top.content[index].routeName,
'       focus: focus
'     }
'   end if
' End Sub

Function onKeyEvent(key as String, press as Boolean) as Boolean
  ' Handle only key up event
  if not press then return false

  ? ">>> NavBar >> OnkeyEvent"

  if key = "down"
    itemSelected = m.defaultSelection
    if itemSelected = invalid
      itemSelected = m.buttonsTargetList.itemSelected
    end if
    m.buttonsTargetList.animateToItem = itemSelected
  end if

  ' if key = "left"
  '   currentFocusedIndex = arrayIndexOf(m.top.content, m.buttonsContainer.focusedChild.id, "key")
  '   if currentFocusedIndex > 0
  '     FocusButton(currentFocusedIndex - 1)
  '     return true
  '   end if
  ' else if key = "right"
  '   currentFocusedIndex = arrayIndexOf(m.top.content, m.buttonsContainer.focusedChild.id, "key")
  '   if currentFocusedIndex > -1 and currentFocusedIndex + 1 < m.top.content.Count()
  '     FocusButton(currentFocusedIndex + 1)
  '   end if
  '   return true
  ' else if key = "OK"
  '   ClickButton(m.top.focusedItem)
  '   return true
  ' end if

  return false
End Function