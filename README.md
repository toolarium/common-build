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
powershell -Command "iwr https://git.io/Jfx5G -OutFile ${env:TEMP}/cb.bat" & %TEMP%\cb.bat --install
```

**Linux**

Install the latest linux cli to `/usr/local/bin`

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb.sh | /bin/bash
```

**MacOS**

Install the latest darwin Dapr CLI to `/usr/local/bin`

```bash
curl -fsSL https://raw.githubusercontent.com/toolarium/common-build/master/src/main/cli/cb.sh | /bin/bash
```
