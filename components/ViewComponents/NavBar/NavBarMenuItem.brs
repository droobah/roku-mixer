Sub Init()
  m.background = m.top.findNode("Background")
  m.label = m.top.findNode("Label")
  m.icon = m.top.findNode("Icon")
  
  m.top.observeField("itemContent", "ContentSet")
  m.top.observeField("currRect", "OnRectangleChange")
  m.top.observeField("focusPercent", "OnFocusPercentChange")
  m.top.observeField("groupHasFocus", "OnGroupFocusChange")
End Sub

Sub ContentSet(event as Object)
  if event.getData().data = invalid then return

  itemData = event.getData().data

  m.label.text = itemData.title

  if itemData.icon <> invalid and itemData.icon <> ""
    m.icon.uri = itemData.icon
    if itemData.iconColor <> invalid and itemData.iconColor <> ""
      m.icon.blendColor = itemData.iconColor
    end if
  end if
End Sub

Sub OnRectangleChange(event as Object)
  rect = event.getData()

  m.background.width = rect.width
  m.background.height = rect.height
End Sub

' Sub OnGroupFocusChange(event as Object)
'   ' Hide/Show label when targetgroup loses or regains focus
'   ' Regaining focus does not trigger focus change so we do it here
'   groupGainedFocus = event.getData()

'   if groupGainedFocus
'     if m.top.itemHasFocus = true
'       m.label.opacity = 1
'     end if
'   end if
' End Sub

Sub OnFocusPercentChange(event as Object)
  percent = event.getData()

  m.background.blendColor = interpolateColor("0x2E2E2E", "0x505050", percent)

  opacity = 0.4
  if percent > 0.4
    opacity = percent
  end if
  m.icon.opacity = opacity

  opacity = 0
  if percent >= 0.95
    opacity = 1.0
  end if
  m.label.opacity = opacity
End Sub

Function componentToHex(c as Integer) as String
  return ("0" + StrI(c, 16)).Right(2)
End Function

Function hexToRgb(hex as String) as Object
  bigint = Val(hex, 16)
  r = (bigint >> 16) and 255
  g = (bigint >> 8) and 255
  b = bigint and 255

  return [r, g, b]
End Function

Function interpolateColor(color1 as String, color2 as String, factor as Float) as String
  color1Rgb = hexToRgb(color1)
  color2Rgb = hexToRgb(color2)
  hex = "0x"
  for i = 0 to 2
    ' Int(x-0.5)+1  ===  round
    color = Int(color1Rgb[i] + factor * (color2Rgb[i] - color1Rgb[i]) - 0.5) + 1
    hex += componentToHex(color)
  end for
  return hex
End Function