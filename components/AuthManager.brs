Function RefreshToken()

End Function

Function Login()

End Function

Function RequestLoginCode()
    m.global.uriFetcher.request
End Function

Function Logout()
    m.global.auth.user = invalid
    m.global.auth.token = invalid
    m.global.auth.refresh_token = invalid
End Function

Function IsLoggedIn()
    return m.global.auth.user <> invalid
End Function