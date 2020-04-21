Sub StartMultiPurposeTask(actions as Object, callback="" as String)
    task = CreateObject("roSGNode", "MultiPurposeTask")
    task.actions = actions
    if callback <> ""
        task.observeField("response", callback)
    end if
    task.control = "RUN"
End Sub