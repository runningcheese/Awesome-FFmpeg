:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个 mp3 文件拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 定义允许的文件扩展名
set "valid_exts=.mp3 .wav .flac .aac .ogg .wma .m4a .alac .ape .aiff"

REM 检查文件扩展名是否在允许的范围内
:check_extension
    IF "%~1"=="" GOTO process_folders

    set "file_ext=%~x1"
    echo %valid_exts% | findstr /i /c:"%file_ext%" >nul
    IF ERRORLEVEL 1 (
        ECHO 奶酪提示你：当前文件格式不支持，请选择“音频”文件。
        PAUSE
        EXIT /B 1
    )

REM 输入文件
set "audioFile=%~1"

REM 获取输入音频文件的目录和基名
for %%F in ("%audioFile%") do (
    set "audioDir=%%~dpF"
    set "audioBaseName=%%~nF"
)

REM 输出图片文件名和路径
setlocal enabledelayedexpansion
set "outputImageFile=%audioDir%%audioBaseName%_cover.jpg"

REM 使用 ffmpeg 提取 MP3 文件中的封面图片
ffmpeg.exe -i "!audioFile!" -an -vcodec copy "!outputImageFile!"

ECHO 封面图片已提取至: "!outputImageFile!"
