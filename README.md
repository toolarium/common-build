# common-build

The common-build project has the goal to simplify the development environment setup. It works for the main environment such as Linux, Windows and Mac.
It can be used as a "transparent" wrapper of the most common build tools such as Gradle, Maven or Ant.

It simplifies additional the installation of java versions. All software will be installed in a so called "devtools" directory. All settings you can overwrite
by corresponding environment variables.



## Installing common-build

### Using script to install the latest release

**Windows**

Install the latest windows cli to `c:\devtools` and add this directory to User PATH environment variable.

```powershell
powershell -Command "iwr https://git.io/JJenc -OutFile ${env:TEMP}/cb-install.bat" & %TEMP%\cb-install.bat
```
or with full link
```powershell
powershell -Command "iwr https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.bat -OutFile ${env:TEMP}/cb-install.bat" & %TEMP%\cb-install.bat
```


**Linux** (coming soon)

Install the latest linux cli to `$HOME/devtools`

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.sh | /bin/bash
```

**MacOS** (coming soon)

Install the latest darwin Dapr CLI to `/usr/local/bin`

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/bin/cb-install.sh | /bin/bash
```
