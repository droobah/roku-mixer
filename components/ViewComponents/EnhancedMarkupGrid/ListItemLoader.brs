Sub Init()
    m.spinner = m.top.findNode("Spinner")
End Sub

Sub WidthChanged(event as Object)
    width = event.getData()

    m.spinner.translation = [width / 2 - m.spinner.width / 2, (width / 16 * 9) / 2 - m.spinner.height]
End Sub