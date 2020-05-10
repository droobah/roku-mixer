Sub Init()
  m.buttonGroup = m.top.findNode("ButtonGroup")
  m.top.observeField("buttons", "OnButtonsSet")
  m.top.observeField("spacing", "OnSpacingSet")
  m.top.observeField("buttonFocused", "OnFocusedButtonChange")
  m.top.observeField("focusedChild", "OnFocusedChildChange")
  m.top.observeField("buttonSelected", "OnButtonSelected")
End Sub

Sub OnFocusedChildChange()
  if m.top.isInFocusChain() and not m.buttonGroup.isInFocusChain() then
    OnFocusedButtonChange()
  end if
End Sub

Sub OnFocusedButtonChange()
  for i = 0 to m.top.buttons.Count() - 1
    if i = m.top.buttonFocused
      m.buttonGroup.getChild(i).setFocus(true)
    else
      m.buttonGroup.getChild(i).setFocus(false)
    end if
  end for
End Sub

Sub OnSpacingSet(event as Object)
  m.buttonGroup.itemSpacings = [event.getData()]
  m.top.unobserveField("spacing")
End Sub

Sub OnButtonsSet()
  for each button in m.top.buttons
    buttonComponent = CreateObject("roSGNode", m.top.itemComponentName)
    if m.top.direction = "vert"
      buttonComponent.width = m.top.maxWidth
    else
      buttonComponent.width = -1
    end if
    if m.top.height > -1
        buttonComponent.height = m.top.height
    end if
    buttonComponent.data = button
    buttonComponent.noClickHandler = true
    m.buttonGroup.appendChild(buttonComponent)
  end for
  m.top.unobserveField("buttons")
  OnButtonSelected()
End Sub

Sub OnButtonSelected()
  if m.top.radio
    for i = 0 to m.buttonGroup.getChildCount() - 1
      button = m.buttonGroup.getChild(i)
      fields = button.data
      if i = m.top.buttonFocused
        fields["icon"] = ""
      else
        fields.Delete("icon")
      end if
      button.data = fields
    end for
  end if
End Sub

Function onKeyEvent(key as String, press as Boolean) as Boolean
  ? ">>> CustomButtonGroup >> OnkeyEvent"

  ' Handle only key up event
  if not press then return false

  if m.top.direction = "vert"
    if key = "up" and m.top.buttonFocused > 0
      m.top.buttonFocused -= 1
      return true
    else if key = "down" and m.top.buttonFocused < m.top.buttons.Count() - 1
      m.top.buttonFocused += 1
      return true
    end if
  else if m.top.direction = "horiz"
    if key = "left" and m.top.buttonFocused > 0
      m.top.buttonFocused -= 1
      return true
    else if key = "right" and m.top.buttonFocused < m.top.buttons.Count() - 1
      m.top.buttonFocused += 1
      return true
    end if
  end if

  if key = "OK"
    m.top.buttonSelected = m.top.buttonFocused
    return true
  end if

  return false
End Function