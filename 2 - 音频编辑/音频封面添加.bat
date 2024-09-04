:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个 mp3 文件，和一个 图片 文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请请选择一个 mp3 文件，和一个 图片 文件。
    pause
    exit /b 1
)

REM 输入文件
set audioFile=%1
set imageFile=%2

REM 获取输入音频文件的目录和基名
for %%F in ("%audioFile%") do (
    set audioDir=%%~dpF
    set audioBaseName=%%~nF
)

REM 输出文件名和路径
set outputFile=%audioDir%%audioBaseName%_with_cover.mp3

REM 使用 ffmpeg 给 mp3 文件添加图片封面
ffmpeg.exe -i "%audioFile%" -i "%imageFile%" -map 0:0 -map 1:0 -c copy -id3v2_version 3 -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" "%outputFile%"
