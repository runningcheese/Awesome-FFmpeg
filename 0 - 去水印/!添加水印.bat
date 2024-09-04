:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off
setlocal enabledelayedexpansion

REM 检查是否传入了文件
IF "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，选择一个文件，多个文件或文件夹，拖放到此 BAT 文件图标上。
    PAUSE
    EXIT /B 1
)

REM 设置文字、图片、字体路径
SET TEXT=@奔跑中的奶酪
SET IMAGE_PATH="D:/CommandLine/SendTo+/Assets/Logo.png"
SET FONT_PATH="D:/CommandLine/SendTo+/Assets/Fontfile.ttf"

REM 横屏文字水印位置和大小
SET LandscapeTextX=1620
SET LandscapeTextY=50
SET LandscapeTextSize=36

REM 横屏图片水印位置
SET LandscapeImageX=1540
SET LandscapeImageY=32

REM 竖屏文字水印位置和大小
SET PortraitTextX=730
SET PortraitTextY=60
SET PortraitTextSize=42

REM 竖屏图片水印位置
SET PortraitImageX=650
SET PortraitImageY=45

REM 遍历所有传入的文件夹路径
:process_folders
    IF "%~1"=="" GOTO end

    REM 获取传入的文件夹路径
    set "folder=%~1"

    REM 使用 PowerShell 获取指定文件夹内的所有视频文件，并根据视频方向添加水印
    powershell -Command ^
        "$files = Get-ChildItem -Path '%folder%' -File -Recurse -Include '*.mp4', '*.mkv', '*.ts', '*.wmv', '*.avi', '*.mpg', '*.mpeg', '*.mov', '*.flv', '*.m4v', '*.rmvb', '*.3gp';" ^
        "foreach ($file in $files) {" ^
        "$mediaInfo = ffmpeg -i \"$($file.FullName)\" 2>&1 | Select-String -Pattern '\d{2,5}x\d{2,5}';" ^
        "$resolution = $mediaInfo.Matches[0].Value -split 'x';" ^
        "$width = [int]$resolution[0];" ^
        "$height = [int]$resolution[1];" ^
        "$mp4File = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($file.FullName), [System.IO.Path]::GetFileNameWithoutExtension($file.FullName) + '_Watermark.mp4');" ^
        "if (-Not (Test-Path $mp4File)) {" ^
        "echo 正在添加水印并处理视频文件 $($file.FullName) 请勿关闭窗口...;" ^
        "if ($width -ge $height) {" ^
        "ffmpeg -i \"$($file.FullName)\" -i \"%IMAGE_PATH%\" -filter_complex \"drawtext=text='%TEXT%':fontfile='%FONT_PATH%':x=%LandscapeTextX%:y=%LandscapeTextY%:fontsize=%LandscapeTextSize%:fontcolor=white:shadowx=2:shadowy=2:shadowcolor=DimGray:alpha=0.9,overlay=%LandscapeImageX%:%LandscapeImageY%\" -c:a copy \"$mp4File\" -y;" ^
        "} else {" ^
        "ffmpeg -i \"$($file.FullName)\" -i \"%IMAGE_PATH%\" -filter_complex \"drawtext=text='%TEXT%':fontfile='%FONT_PATH%':x=%PortraitTextX%:y=%PortraitTextY%:fontsize=%PortraitTextSize%:fontcolor=white:shadowx=2:shadowy=2:shadowcolor=DimGray:alpha=0.9,overlay=%PortraitImageX%:%PortraitImageY%\" -c:a copy \"$mp4File\" -y;" ^
        "}}}"

    REM 移动到下一个参数
    SHIFT
    GOTO process_folders

:end
ECHO 所有任务已完成。
EXIT /B 0
