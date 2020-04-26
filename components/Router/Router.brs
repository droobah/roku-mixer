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
      path: "/login",
      componentName: "LoginView",
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
      path: "/game/:gameId",
      componentName: "GameView",
      fullscreen: true,
      topLevel: false,
    }
  ]

  m.screenStack = []

  m.spinner = m.top.findNode("Spinner")

  m.top.observeField("focusedChild", "OnFocusedChildChange")
  m.global.observeFieldScoped("route", "onRouteChange")
  m.global.observeFieldScoped("routeWithExtra", "onRouteChange")
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
        if routeParts[i].Left(1) <> ":"
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
      routeComponent[paramName] = matchingRoute.path.Split("/")[i]
    end if
  end for
  
  return routeComponent
End Function

Sub onRouteChange(event as Object)
  route = event.getData()
  routeExtraData = invalid

  if type(route) = "roAssociativeArray"
    routeExtraData = route.extra
    route = route.route
  end if

  ? "ROUTE CHANGE "; route

  if route = invalid or route = "" then return

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

    if routeExtraData <> invalid and type(routeExtraData) = "roAssociativeArray"
      component.setFields(routeExtraData)
    end if

    ' Set "contentSet = true" on the route view's Init() function
    ' to show it immediately without the spinner.
    ' Useful if your view doesn't interact with HTTP resources
    if component.contentSet <> invalid and component.contentSet = false
      component.observeField("contentSet", "RouteContentSet")
      component.visible = false
      m.spinner.control = "start"
    else
      m.spinner.control = "stop"
    end if

    if matchingRoute.fullscreen = false
      component.translation = [0, 84]
      m.spinner.translation = [1920 / 2 - m.spinner.width / 2, (1080 + 84) / 2 - m.spinner.height / 2]
    end if

    if m.screenStack.peek() <> invalid and m.screenStack.peek().route = route
      RemoveTop()
    end if

    AddScreen(component, matchingRoute.topLevel, nonDuplicatePreviousRoute)
  end if
End Sub

Sub RouteContentSet(event as Object)
  event.getRoSGNode().visible = true
  m.spinner.control = "stop"
End Sub

Sub AddScreen(node, topLevelNode, nonDuplicatePreviousRoute)
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
  ' insert below loading spinner
  m.top.insertChild(node, m.top.getChildCount() - 1)
  node.setFocus(true)
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