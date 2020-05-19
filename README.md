#### Install channel here
<https://my.roku.com/add/6QRRQVV>

#### To Run:

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

#### To Build:

1. Run
```
cd scripts/ && ./build.sh
```
New build folder is created. Ex: builds/build_2020_04_22_21_45_37  
Sideloadable ZIP file is also generated. Ex: builds/build_2020_04_22_21_45_37/out/**roku-deploy.zip**

#### To Package:
To upload a channel to the Roku Channel Store, you need to "package" your previously built **roku-deploy.zip** file into a .pkg file.  
<https://developer.roku.com/en-gb/docs/developer-program/publishing/packaging-channels.md>
