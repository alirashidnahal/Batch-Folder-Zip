@echo off
setlocal enabledelayedexpansion

REM ============================================================
REM  Folder Compression Script for Windows
REM  Uses WinRAR Rar.exe to create ZIP archives from folders
REM  Supports interactive mode and command-line flags
REM ============================================================

title Folder Compression Tool

REM --- Defaults ---
set "SRC_DIR="
set "COMP_LEVEL="
set "DELETE_FOLDERS="
set "CONFIRM_EACH="
set "WINRAR_PATH="
set "SKIP_CONFIRM=0"
set "CLI_MODE=0"
set "USE_WINRAR_FALLBACK=0"

REM --- Parse command-line flags (inline to preserve quoted paths) ---
if not "%~1"=="" (
    set "CLI_MODE=1"
    goto ParseArgsLoop
)

goto InteractiveMode

:ParseArgsLoop
if "%~1"=="" goto ParseArgsDone

if /i "%~1"=="-h" goto ShowHelp
if /i "%~1"=="--help" goto ShowHelp
if /i "%~1"=="/?" goto ShowHelp

if /i "%~1"=="-s" goto ParseSource
if /i "%~1"=="--source" goto ParseSource
if /i "%~1"=="-l" goto ParseLevel
if /i "%~1"=="--level" goto ParseLevel
if /i "%~1"=="-d" goto ParseDelete
if /i "%~1"=="--delete" goto ParseDelete
if /i "%~1"=="-c" goto ParseConfirmDelete
if /i "%~1"=="--confirm-delete" goto ParseConfirmDelete
if /i "%~1"=="-w" goto ParseWinRAR
if /i "%~1"=="--winrar" goto ParseWinRAR
if /i "%~1"=="-y" goto ParseYes
if /i "%~1"=="--yes" goto ParseYes

echo Error: Unknown option: %~1
echo Use --help for usage information.
goto EndScriptError

:ParseSource
if "%~2"=="" (
    echo Error: %~1 requires a directory path.
    goto EndScriptError
)
set "SRC_DIR=%~2"
shift
shift
goto ParseArgsLoop

:ParseLevel
if "%~2"=="" (
    echo Error: %~1 requires a value ^(0-5^).
    goto EndScriptError
)
set "COMP_LEVEL=%~2"
shift
shift
goto ParseArgsLoop

:ParseDelete
if "%~2"=="" (
    echo Error: %~1 requires Y or N.
    goto EndScriptError
)
set "DELETE_FOLDERS=%~2"
shift
shift
goto ParseArgsLoop

:ParseConfirmDelete
if "%~2"=="" (
    echo Error: %~1 requires Y or N.
    goto EndScriptError
)
set "CONFIRM_EACH=%~2"
shift
shift
goto ParseArgsLoop

:ParseWinRAR
if "%~2"=="" (
    echo Error: %~1 requires a file path.
    goto EndScriptError
)
set "WINRAR_PATH=%~2"
shift
shift
goto ParseArgsLoop

:ParseYes
set "SKIP_CONFIRM=1"
shift
goto ParseArgsLoop

:ParseArgsDone
if not defined SRC_DIR set "SRC_DIR=%CD%"
if not defined COMP_LEVEL set "COMP_LEVEL=3"
if not defined DELETE_FOLDERS set "DELETE_FOLDERS=N"
if not defined CONFIRM_EACH set "CONFIRM_EACH=Y"
if not defined WINRAR_PATH set "WINRAR_PATH=C:\Program Files\WinRAR\WinRAR.exe"

echo !COMP_LEVEL!| findstr /r "^[0-5]$" >nul
if errorlevel 1 (
    echo Error: Invalid compression level "!COMP_LEVEL!". Must be 0-5.
    goto EndScriptError
)

if /i "!DELETE_FOLDERS!"=="Y" goto ValidateDeleteOk
if /i "!DELETE_FOLDERS!"=="N" goto ValidateDeleteOk
echo Error: Invalid --delete value "!DELETE_FOLDERS!". Must be Y or N.
goto EndScriptError

:ValidateDeleteOk
if /i "!CONFIRM_EACH!"=="Y" goto ValidateConfirmOk
if /i "!CONFIRM_EACH!"=="N" goto ValidateConfirmOk
echo Error: Invalid --confirm-delete value "!CONFIRM_EACH!". Must be Y or N.
goto EndScriptError

:ValidateConfirmOk
if /i "!DELETE_FOLDERS!"=="Y" goto ValidateSource
set "CONFIRM_EACH=N"

:ValidateSource
if not exist "!SRC_DIR!" (
    echo Error: Source directory not found: !SRC_DIR!
    goto EndScriptError
)

if not exist "!WINRAR_PATH!" (
    echo Error: WinRAR not found: !WINRAR_PATH!
    goto EndScriptError
)

goto ConfigDone

:ShowHelp
echo.
echo Usage: CompressFolders.bat [OPTIONS]
echo.
echo   Compresses each subfolder in the source directory into a ZIP file.
echo   Run without options for interactive mode.
echo.
echo Options:
echo   -s, --source DIR          Source directory containing folders to zip
echo   -l, --level N             Compression level 0-5 ^(default: 3^)
echo   -d, --delete Y^|N          Delete folders after successful zip ^(default: N^)
echo   -c, --confirm-delete Y^|N   Confirm before each deletion ^(default: Y^)
echo   -w, --winrar PATH         Path to WinRAR.exe or Rar.exe
echo   -y, --yes                 Skip final confirmation prompt
echo   -h, --help                Show this help message
echo.
echo Examples:
echo   CompressFolders.bat -s "F:\music" -l 3 -d N -w "C:\Program Files\WinRAR\Rar.exe" -y
echo   CompressFolders.bat --source "F:\fild" --level 5 --delete Y --confirm-delete N --yes
echo.
goto EndScriptOk

REM ============================================================
REM Interactive mode
REM ============================================================
:InteractiveMode
echo.
echo ============================================================
echo   FOLDER COMPRESSION TOOL
echo   Compresses all folders in the current directory to ZIP
echo ============================================================
echo.
echo Current directory: %CD%
echo.

:PromptCompressionLevel
set "COMP_LEVEL="
set /p "COMP_LEVEL=Compression level [0-5] (0=Store, 3=Normal default, 5=Best): "

if "!COMP_LEVEL!"=="" (
    set "COMP_LEVEL=3"
    goto CompressionLevelDone
)

echo !COMP_LEVEL!| findstr /r "^[0-5]$" >nul
if errorlevel 1 (
    echo   Invalid input. Please enter a number from 0 to 5.
    goto PromptCompressionLevel
)

:CompressionLevelDone

:PromptDeleteFolders
set "DELETE_FOLDERS="
set /p "DELETE_FOLDERS=Delete folders after successful compression? [Y/N] (default N): "

if "!DELETE_FOLDERS!"=="" (
    set "DELETE_FOLDERS=N"
    goto DeleteFoldersDone
)

if /i "!DELETE_FOLDERS!"=="Y" goto DeleteFoldersDone
if /i "!DELETE_FOLDERS!"=="N" goto DeleteFoldersDone

echo   Invalid input. Please enter Y or N.
goto PromptDeleteFolders

:DeleteFoldersDone

set "CONFIRM_EACH=N"

if /i "!DELETE_FOLDERS!"=="Y" goto PromptConfirmEach
goto ConfirmEachDone

:PromptConfirmEach
set "CONFIRM_EACH="
set /p "CONFIRM_EACH=Confirm before deleting each folder? [Y/N] (default Y): "

if "!CONFIRM_EACH!"=="" (
    set "CONFIRM_EACH=Y"
    goto ConfirmEachDone
)

if /i "!CONFIRM_EACH!"=="Y" goto ConfirmEachDone
if /i "!CONFIRM_EACH!"=="N" goto ConfirmEachDone

echo   Invalid input. Please enter Y or N.
goto PromptConfirmEach

:ConfirmEachDone

:PromptWinRARPath
set "WINRAR_PATH="
set /p "WINRAR_PATH=WinRAR path (default C:\Program Files\WinRAR\WinRAR.exe): "

if "!WINRAR_PATH!"=="" (
    set "WINRAR_PATH=C:\Program Files\WinRAR\WinRAR.exe"
)

if not exist "!WINRAR_PATH!" (
    echo   Error: File not found: !WINRAR_PATH!
    goto PromptWinRARPath
)

set "SRC_DIR=%CD%"
goto ConfigDone

REM ============================================================
REM Resolve Rar.exe and show configuration
REM ============================================================
:ConfigDone
for %%I in ("!WINRAR_PATH!") do (
    set "WINRAR_DIR=%%~dpI"
    set "WINRAR_BASENAME=%%~nxI"
)

if /i "!WINRAR_BASENAME!"=="Rar.exe" (
    set "RAR_EXE=!WINRAR_PATH!"
    if exist "!WINRAR_DIR!WinRAR.exe" (
        set "WINRAR_PATH=!WINRAR_DIR!WinRAR.exe"
    ) else (
        set "WINRAR_PATH=!RAR_EXE!"
    )
    set "USE_WINRAR_FALLBACK=0"
) else (
    set "RAR_EXE=!WINRAR_DIR!Rar.exe"
    set "USE_WINRAR_FALLBACK=0"
    if not exist "!RAR_EXE!" (
        if "!CLI_MODE!"=="1" (
            echo WARNING: Rar.exe not found at !RAR_EXE!
            echo          Falling back to WinRAR.exe.
        ) else (
            echo.
            echo   WARNING: Rar.exe not found at !RAR_EXE!
            echo   Falling back to WinRAR.exe - this may not work correctly in batch mode.
            echo.
        )
        set "RAR_EXE=!WINRAR_PATH!"
        set "USE_WINRAR_FALLBACK=1"
    )
)

echo.
echo ============================================================
echo   CONFIGURATION SUMMARY
echo ============================================================
echo   Source directory     : !SRC_DIR!
echo   Compression level    : !COMP_LEVEL!
echo   Delete after zip     : !DELETE_FOLDERS!

if /i "!DELETE_FOLDERS!"=="Y" (
    echo   Confirm each delete  : !CONFIRM_EACH!
) else (
    echo   Confirm each delete  : N/A
)

echo   WinRAR path          : !WINRAR_PATH!
echo   Rar.exe path         : !RAR_EXE!

if "!USE_WINRAR_FALLBACK!"=="1" (
    echo   Note                 : Using WinRAR.exe fallback
)

echo ============================================================
echo.

if "!SKIP_CONFIRM!"=="1" goto StartProcessing

:PromptFinalConfirm
set "FINAL_CONFIRM="
set /p "FINAL_CONFIRM=Proceed with compression? [Y/N] (default N): "

if "!FINAL_CONFIRM!"=="" (
    set "FINAL_CONFIRM=N"
)

if /i "!FINAL_CONFIRM!"=="Y" goto StartProcessing
if /i "!FINAL_CONFIRM!"=="N" (
    echo.
    echo Operation cancelled by user.
    goto EndScript
)

echo   Invalid input. Please enter Y or N.
goto PromptFinalConfirm

REM ============================================================
REM Process all folders in source directory
REM ============================================================
:StartProcessing
set "COUNT_SUCCESS=0"
set "COUNT_FAIL=0"
set "COUNT_SKIP=0"
set "FOUND_FOLDERS=0"

pushd "!SRC_DIR!" 2>nul
if errorlevel 1 (
    echo Error: Cannot access source directory: !SRC_DIR!
    goto EndScriptError
)

echo.
echo Starting compression in: !SRC_DIR!
echo.

for /d %%F in ("*") do (
    set "FOUND_FOLDERS=1"
    call :ProcessFolder "%%F"
)

if "!FOUND_FOLDERS!"=="0" (
    echo No folders found in the source directory.
    echo.
)

popd
goto ShowReport

:ProcessFolder
set "SOURCE_FOLDER=%~1"
set "FOLDER_NAME=%~nx1"
set "ZIP_FILE=!FOLDER_NAME!.zip"

echo [PROCESSING] !FOLDER_NAME!

"!RAR_EXE!" a -m!COMP_LEVEL! -ep1 -y "!ZIP_FILE!" "!SOURCE_FOLDER!\*" >nul 2>&1
set "RAR_EXIT=!errorlevel!"

if exist "!ZIP_FILE!" (
    echo   [OK] Zip file created successfully

    if /i "!DELETE_FOLDERS!"=="Y" (
        set "DO_DELETE=1"

        if /i "!CONFIRM_EACH!"=="Y" (
            set "DELETE_CONFIRM="
            set /p "DELETE_CONFIRM=  Delete folder !FOLDER_NAME!? [Y/N]: "

            if /i not "!DELETE_CONFIRM!"=="Y" (
                set "DO_DELETE=0"
            )
        )

        if "!DO_DELETE!"=="1" (
            rd /s /q "!SOURCE_FOLDER!" 2>nul
            if exist "!SOURCE_FOLDER!" (
                echo   [WARN] Failed to delete folder
                set /a COUNT_FAIL+=1
            ) else (
                echo   [OK] Folder deleted
                set /a COUNT_SUCCESS+=1
            )
        ) else (
            echo   -^> Folder kept ^(skipped by user^)
            set /a COUNT_SKIP+=1
        )
    ) else (
        echo   -^> Folder kept ^(deletion disabled^)
        set /a COUNT_SUCCESS+=1
    )
) else (
    echo   [X] Failed to create zip file ^(Rar exit code: !RAR_EXIT!^)
    if "!RAR_EXIT!"=="7" (
        echo       Hint: Unsupported command switch - check Rar.exe version
    )
    if "!RAR_EXIT!"=="10" (
        echo       Hint: No files found in folder
    )
    set /a COUNT_FAIL+=1
)

echo.
goto :eof

:ShowReport
echo ============================================================
echo   COMPLETED
echo ============================================================
echo   Successfully processed: !COUNT_SUCCESS! folders
echo   Failed               : !COUNT_FAIL! folders

if /i "!DELETE_FOLDERS!"=="Y" (
    if /i "!CONFIRM_EACH!"=="Y" (
        echo   Skipped by user      : !COUNT_SKIP! folders
    )
)

echo ============================================================
echo.

if "!CLI_MODE!"=="1" if "!SKIP_CONFIRM!"=="1" goto EndScriptOk
goto EndScript

:EndScriptError
if "!CLI_MODE!"=="1" (
    endlocal
    exit /b 1
)
goto EndScript

:EndScriptOk
endlocal
exit /b 0

:EndScript
endlocal
pause
