:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个带“内嵌字幕”的视频文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

ffmpeg -i "%~nx1" "%~n1".srt

