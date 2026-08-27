@echo off
setlocal
color 0a

pushd "%~dp0"
set "MOD_DIR=%~1"
if "%MOD_DIR%"=="" set /p "MOD_DIR=Drag your mod folder here, then press Enter: "

if not exist "%MOD_DIR%\." (
    echo Mod folder not found: %MOD_DIR%
    popd
    pause
    exit /b 1
)

if exist "assets\web_mod" rmdir /s /q "assets\web_mod"
mkdir "assets\web_mod"

if exist "%MOD_DIR%\assets\." (
    echo Detected V-Slice asset layout.
    xcopy "%MOD_DIR%\assets\*" "assets\web_mod\" /E /I /Y /H >nul
) else (
    echo Detected standard mod layout.
    mkdir "assets\web_mod\shared"
    for %%D in (characters custom_events custom_notetypes data fonts images music registry scripts shaders sounds stages weeks achievements) do (
        if exist "%MOD_DIR%\%%D\." xcopy "%MOD_DIR%\%%D\*" "assets\web_mod\shared\%%D\" /E /I /Y /H >nul
    )
    for %%D in (songs videos) do (
        if exist "%MOD_DIR%\%%D\." xcopy "%MOD_DIR%\%%D\*" "assets\web_mod\%%D\" /E /I /Y /H >nul
    )
)
if exist "%MOD_DIR%\_polymod_meta.json" copy /Y "%MOD_DIR%\_polymod_meta.json" "assets\web_mod\_polymod_meta.json" >nul
if exist "%MOD_DIR%\_polymod_icon.png" copy /Y "%MOD_DIR%\_polymod_icon.png" "assets\web_mod\_polymod_icon.png" >nul
if errorlevel 1 goto copy_failed

call setup\windows.bat web
if errorlevel 1 goto build_failed

call haxelib run lime build html5 -final
if errorlevel 1 goto build_failed

rmdir /s /q "assets\web_mod"
echo.
echo HTML5 build complete.
echo Upload the contents of:
echo %CD%\export\release\html5\bin
echo.
popd
pause
exit /b 0

:copy_failed
echo Failed to copy the mod files.
rmdir /s /q "assets\web_mod"
popd
pause
exit /b 1

:build_failed
echo HTML5 build failed.
rmdir /s /q "assets\web_mod"
popd
pause
exit /b 1
