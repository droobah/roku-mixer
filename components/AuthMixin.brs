Function IsLoggedIn()
    return m.global.auth.access_token <> ""
End Function

Sub Login(access_token as String, refresh_token as String)
    StartMultiPurposeTask([
        {
            name: "writeregistry",
            data: {
                registry: "Authentication",
                key: "access_token",
                value: access_token
            }
        },
        {
            name: "writeregistry",
            data: {
                registry: "Authentication",
                key: "refresh_token",
                value: refresh_token
            }
        }
    ])
    m.global.auth.setFields({
        "access_token": access_token,
        "refresh_token": refresh_token,
    })
End Sub

Function Logout()
    StartMultiPurposeTask([
        {
            name: "deleteregistry",
            data: {
                registry: "Authentication",
                key: "access_token"
            }
        },
        {
            name: "deleteregistry",
            data: {
                registry: "Authentication",
                key: "refresh_token"
            }
        },
        {
            name: "deleteregistry",
            data: {
                registry: "Authentication",
                key: "user_id"
            }
        }
    ])
    m.global.auth.access_token = ""
    m.global.auth.refresh_token = ""
    m.global.auth.user_id = ""
End Function

Sub FetchMyProfile()
    MakeGETRequest("https://mixer.com/api/v1/users/current", "UserResponseTransformer", "OnProfileResponse")
End Sub

Sub OnProfileResponse(event as Object)
    response = event.getData()

    if response.code = 200 and response.transformedResponse <> invalid
        m.global.auth.userProfile = response.transformedResponse
        m.global.auth.user_id = response.transformedResponse.model_id.ToStr()
        StartMultiPurposeTask([
            {
                name: "writeregistry",
                data: {
                    registry: "Authentication",
                    key: "user_id",
                    value: response.transformedResponse.model_id.ToStr()
                }
            }
        ])
    end if
End Sub