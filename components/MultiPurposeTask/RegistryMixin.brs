Function readRegistry(registryName as String, key as String) as Object
  registry = CreateObject("roRegistrySection", registryName)
  if registry.Exists(key)
    return registry.Read(key)
  end if

  return invalid
End Function

Sub writeRegistry(registryName as String, key as String, value as String)
  registry = CreateObject("roRegistrySection", registryName)
  registry.Write(key, value)
  registry.Flush()
End Sub

Sub deleteRegistry(registryName as String, key as String)
  registry = CreateObject("roRegistrySection", registryName)
  if registry.Exists(key)
    registry.Delete(key)
    registry.Flush()
  end if
End Sub