Function startsWith(value as String, searchString as String) as Boolean
  if Left(searchString, Len(value)) = value then return true
  return false
End Function

Function ceil(num as Dynamic) as Integer
  if num > Int(num) then return Int(num) + 1
  return num
End Function

Function kFormatter(num as Integer) as String
  if num < 1000 then return num.ToStr()
  return (num / 1000).ToStr("%.1f") + "K"
End Function

Function datetimeFormatter(dts as String) as String
  if dts = "" then return dts

  dt = CreateObject("roDateTime")
  dt.FromISO8601String(dts)
  dt.ToLocalTime()

  hours = dt.GetHours().ToStr()
  if Len(hours) = 1 then hours = "0" + hours
  minutes = dt.GetMinutes().ToStr()
  if Len(minutes) = 1 then minutes = "0" + minutes

  return dt.AsDateString("short-date") + " " + hours + ":" + minutes
End Function

' dt1,dt2 = roDatetime or ISO8601 string or "now"
Function datetimeDiffFormatted(dt1 as Object, dt2 as Object) as String
  _dt1seconds = 0
  _dt2seconds = 0

  if type(dt1) = "roString"
    _dt1 = CreateObject("roDateTime")
    if dt1 <> "now"
      _dt1.FromISO8601String(dt1)
    end if
    _dt1seconds = _dt1.AsSeconds()
  else if type(dt1) = "roDateTime"
    _dt1seconds = dt1.AsSeconds()
  end if

  if type(dt2) = "roString"
    _dt2 = CreateObject("roDateTime")
    if dt2 <> "now"
      _dt2.FromISO8601String(dt2)
    end if
    _dt2seconds = _dt2.AsSeconds()
  else if type(dt2) = "roDateTime"
    _dt2seconds = dt2.AsSeconds()
  end if

  secDiff = _dt2seconds - _dt1seconds

  return formatTime(secDiff)
End Function

Function formatTime(seconds as Integer) as String
  if seconds <= 0 then return "0h 0m 0s"

  h = Int(seconds / 3600)
  m = Int((seconds mod 3600) / 60)
  s = Int(seconds mod 3600 mod 60)

  return Substitute("{0}h {1}m {2}s", h.ToStr(), m.ToStr(), s.ToStr())
End Function

Function exists(arr as Object, value) as Boolean
  for each item in arr
    if item = value
      return true
    end if
  end for
  return false
End Function

Function arrayIndexOf(arr as Object, value as String, key="" as String) as Integer
  for i = 0 to arr.Count() - 1
    entryValue = arr.GetEntry(i)
    if key <> ""
      entryValue = entryValue[key]
    end if
    if entryValue = value
      return i
    end if
  end for
  return -1
End Function

Function pushAtIndex(item as Object, atIndex as Integer, arr as Object) as Object
  if atIndex >= arr.Count()
    arr.Push(item)
    return arr
  else if atIndex = 0
    arr.Unshift(item)
    return arr
  end if

  popped = []

  for i = arr.Count() - 1 to atIndex step -1
    popped.Push(arr.Pop())
  end for

  arr.Push(item)

  for i = popped.Count() - 1 to 0 step -1
    arr.Push(popped[i])
  end for

  return arr  
End Function

Function slice(arr as Object, sFrom as Integer, sTo as Integer) as Object
  tempArr = []

  if sFrom < 0 then sFrom = 0
  if sTo < 0 then sTo = 0

  if sFrom > arr.Count()
    return tempArr
  end if

  loopTo = sTo - 1
  if loopTo > arr.Count() - 1
    loopTo = arr.Count() - 1
  end if

  for i = sFrom to loopTo
    tempArr.Push(arr[i])
  end for

  return tempArr
End Function

Function sortNodes(arr as Object, key="" as String, reverse=false as Boolean) as Object
  if key = ""
    return arr
  end if

  tempArr = []
  for each item in arr
    tempArr.Push({
      item: item,
      sortkey: item[key]
    })
  end for

  if reverse
    tempArr.SortBy("sortkey", "r")
  else
    tempArr.SortBy("sortkey")
  end if

  returnArr = []
  for each item in tempArr
    returnArr.Push(item.item)
  end for

  return returnArr
End Function

Function doScale(number as Integer, scaleFactor as Integer) as Integer
  if scaleFactor = 0 or number = 0
    return number
  end if

  scaledValue = number - number / scaleFactor
  return scaledValue
End Function

Function secondsToUTC(seconds as Integer) as String
  dt = CreateObject("roDateTime")
  dt.FromSeconds(seconds)
  return dt.ToISOString()
End Function

Function getAAField(aa as Object, fields as Object, default as Object) as Object
  if aa = invalid then return default
  if type(aa) <> "roAssociativeArray" then return default

  value = aa
  for i = 0 to fields.Count() - 1
    aaFieldValue = value.Lookup(fields[i])

    if aaFieldValue = invalid
      return default
    end if

    if fields.Count() - 1 > i
      if type(aaFieldValue) <> "roAssociativeArray"
        return default
      end if
    end if

    value = aaFieldValue
  end for

  return value
End Function