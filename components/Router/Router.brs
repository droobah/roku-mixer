Sub Init()
  m.routes = [
    {
      path: "/discover",
      componentName: "DiscoverView",
      fullscreen: false, ' whether to show or hide header
      topLevel: true, ' top level route destroys all other routes below it
    },
    {
      path: "/following",
      componentName: "FollowingView",
      fullscreen: false,
      topLevel: true,
    },
    {
      path: "/games",
      componentName: "GamesView",
      fullscreen: false,
      topLevel: true,
    },
    {
      path: "/browse",
      componentName: "BrowseView",
      fullscreen: false,
      topLevel: true,
    },
    {
      path: "/settings",
      componentName: "SettingsView",
      fullscreen: false,
      topLevel: true,
    },
    {
      path: "/stream/:token",
      componentName: "StreamView",
      fullscreen: true,
      topLevel: false,
    },
    {
      path: "/game/:id",
      componentName: "GameView",
      fullscreen: true,
      topLevel: false,
    }
  ]

  m.screenStack = []

  m.top.observeField("focusedChild", "OnFocusedChildChange")
  m.global.observeFieldScoped("route", "onRouteChange")
  m.global.observeFieldScoped("routeBack", "goBackReceived")
End Sub

Sub OnFocusedChildChange()
  if m.top.hasFocus()
    node = m.screenStack.Peek()
    if node <> invalid
      node.setFocus(true)
    end if
  end if
End Sub

Function getMatchingRoute(routeName as String) as Object
  routeName = LCase(routeName)

  ' Append leading /
  if routeName.Left(1) <> "/"
    routeName = "/" + routeName
  end if

  ' Remove ending /
  if routeName.Right(1) = "/"
    routeName = routeName.Left(routeName.Len() - 1)
  end if

  userRouteParts = routeName.Split("/")
  userRouteParts.Shift()

  for each route in m.routes
    routeParts = route.path.Split("/")
    routeParts.Shift()

    if routeParts.Count() = userRouteParts.Count()
      matching = true
      i = 0
      while matching = true and i <= routeParts.Count() - 1
        if routeParts[i] <> ":"
          if routeParts[i] <> userRouteParts[i]
            matching = false
          end if
        end if
        i += 1
      end while

      if matching = true
        return route
      end if
    end if
  end for

  return invalid
End Function

Function mapComponentParams(route as String, matchingRoute as Object) as Object
  routeComponent = CreateObject("roSGNode", matchingRoute.componentName)

  matchingRouteParts = matchingRoute.path.Split("/")
  matchingRouteParts.Shift()
  for i = 0 to matchingRouteParts.Count() - 1
    part = matchingRouteParts[i]
    if part.Left(1) = ":"
      paramName = part.Mid(1)
      routeComponent[paramName] = route.path.Split("/")[i]
    end if
  end for
  
  return routeComponent
End Function

Sub onRouteChange(event as Object)
  route = event.getData()
  ? "ROUTE CHANGE"; route

  if route = invalid or route = "" then return

  routeFocusOnContentLoad = true
  ' if route.focus <> invalid and route.focus = false
  '   routeFocusOnContentLoad = false
  ' end if

  nonDuplicatePreviousRoute = true
  ' if route.nonDuplicatePreviousRoute <> invalid and route.nonDuplicatePreviousRoute = false
  '   nonDuplicatePreviousRoute = false
  ' end if

  matchingRoute = getMatchingRoute(route)

  if matchingRoute <> invalid
    m.global.currentRoute = matchingRoute
    component = mapComponentParams(route, matchingRoute)
    component.addFields({
      route: route,
      matchingRoute: matchingRoute
    })
    if routeFocusOnContentLoad = true
      component.observeField("contentSet", "RouteContentSet")
    end if
    if matchingRoute.fullscreen = false
      component.translation = [0, 84]
    end if

    if m.screenStack.peek() <> invalid and m.screenStack.peek().route = route
      RemoveTop()
    end if
    AddScreen(component, matchingRoute.topLevel, routeFocusOnContentLoad, nonDuplicatePreviousRoute)
  end if
End Sub

Sub RouteContentSet(msg as Object)
  msg.getRoSGNode().setFocus(true)
End Sub

Sub AddScreen(node, topLevelNode, focus, nonDuplicatePreviousRoute)
  if topLevelNode
    For i = m.screenStack.Count() - 1 To 0 Step -1
      RemoveScreen(m.screenStack.GetEntry(i), false, false)
    End For
  else
    prev = m.screenStack.peek()
    if prev <> invalid
      ' if previous screen is same as new route component, remove it.
      if nonDuplicatePreviousRoute and prev.subtype() = node.subtype()
        RemoveScreen(prev, false, false)
      else
        prev.visible = false
      end if
    end if
  end if
  m.top.appendChild(node)
  node.visible = true
  if focus
    node.setFocus(true)
  end if
  m.screenStack.push(node)
End Sub

Sub RemoveTop()
  RemoveScreen(invalid)
End Sub

Sub RemoveScreen(node as Object, showPrev=true as Boolean, updateRoute=true as Boolean)
  if node = invalid OR (m.screenStack.peek() <> invalid AND m.screenStack.peek().isSameNode(node)) 
    last = m.screenStack.pop()
    m.top.removeChild(last)
    
    if showPrev
      prev = m.screenStack.peek()
      if prev <> invalid
        if updateRoute
          m.global.currentRoute = prev.matchingRoute
        end if
        prev.visible = true
        prev.setFocus(true)
      end if
    end if
  end if
End Sub

Sub goBackReceived(event as Object)
  if event.getData() = true
    if m.screenStack.Count() > 1
      RemoveTop()
    end if
  end if
End Sub

function onKeyEvent(key, press) as Boolean
  ? ">>> Router >> OnkeyEvent"

  if not press then return false

  if key = "back" and m.screenStack.Count() > 1
    RemoveTop()
    return m.screenStack.count() <> 0
  else if (key = "up" or key = "down") and m.screenStack.Count() > 0
    ' Dont pass down up/down key event (MainScene uses it to focus nav menu) if the route is fullscreen
    if m.screenStack.Peek().matchingRoute.fullscreen = true
      return true
    end if
  end if

  return false
end function