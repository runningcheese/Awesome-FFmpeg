:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件、多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 定义允许的文件扩展名
set "valid_exts=.gif"

REM 检查文件扩展名是否在允许的范围内
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO 奶酪提示你：当前文件格式不支持，请选择“GIF”文件。
        PAUSE
        EXIT /B 1
    )

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有 GIF 文件，并依次倒放
    powershell -Command ^
        "Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.gif' | ForEach-Object {" ^
        "$reversedGif = [System.IO.Path]::ChangeExtension($_.FullName, '_Reversed.gif');" ^
        "if (Test-Path $reversedGif) {" ^
        "Write-Host '倒放 GIF 文件已存在，跳过：' $reversedGif; Start-Sleep -Seconds 1;" ^
        "} else {" ^
        "Write-Host '正在倒放 GIF 文件：' $_.FullName '请勿关闭窗口...';" ^
        "ffmpeg -i $_.FullName -vf reverse $reversedGif;" ^
        "}" ^
        "}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0



