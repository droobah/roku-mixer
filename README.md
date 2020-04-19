To Run:

1. Enable Developer Mode on your Roku
2. Install "celsoaf.brightscript" VSCode extension
3. Edit launch.json (replace ROKUIP and DEVMODEPASSWORD)
```
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "brightscript",
            "request": "launch",
            "name": "BrightScript Debug: Launch",
            "stopOnEntry": false,
            "host": "ROKUIP",
            "password": "DEVMODEPASSWORD",
            "rootDir": "${workspaceFolder}",
            "enableDebuggerAutoRecovery": false,
            "stopDebuggerOnAppExit": false,
            "files": [
                "source/**/*.*",
                "components/**/*.*",
                "fonts/**/*.*",
                "images/**/*.*",
                "manifest"
              ]
        }
    ]
}
```
4. Run -> Start Debugging (F5)