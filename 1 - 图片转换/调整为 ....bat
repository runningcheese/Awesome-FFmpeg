:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 定义允许的文件扩展名
set "valid_exts=.bmp .png .jpg .jpeg .gif .tiff .tif .webp .ico .heic .heif .avif .svg"

REM 检查文件扩展名是否在允许的范围内
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO 奶酪提示你：当前文件格式不支持，请选择“图片”文件。
        PAUSE
        EXIT /B 1
    )

REM 提示用户输入最大像素值
set /p maxpx=请输入最大像素值（例如 1024）:

REM 验证输入是否为数字
for /L %%i in (0,1,9) do if "%maxpx%"=="%%i" goto validinput
for /L %%i in (10,1,9999) do if "%maxpx%"=="%%i" goto validinput

ECHO 请输入有效的数字。
EXIT /B 1

:validinput

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有相关文件，并调整大小
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.bmp','*.png','*.jpg', '*.jpeg', '*.gif', '*.tiff', '*.tif', '*.webp', '*.ico', '*.heic','*.heif', '*.avif', '*.svg';" ^
        "foreach ($file in $files) {" ^
        "$outputFile = [System.IO.Path]::Combine($file.DirectoryName, [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + '_%maxpx%px' + $file.Extension);" ^
        "if (Test-Path \"$outputFile\") { echo 文件已存在，跳过： \"$outputFile\"; Start-Sleep -Seconds 1; } else {" ^
        "echo 正在调整文件 \"$($file.FullName)\" 请勿关闭窗口...;" ^
        "Start-Process -NoNewWindow ffmpeg -ArgumentList '-i', \"`\"$($file.FullName)`\"\", '-vf', 'scale=%maxpx%:%maxpx%:force_original_aspect_ratio=decrease', \"`\"$outputFile`\"\" -Wait; } }"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0
