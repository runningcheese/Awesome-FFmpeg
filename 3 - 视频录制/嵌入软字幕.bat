:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个 视频 文件，和一个 字幕 文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 检查第一个输入的文件扩展名是否为常见字幕格式
SET "ext1=%~x1"
if /I "%ext1%"==".srt" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".ass" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".ssa" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".sub" (
    GOTO InvalidFirstFile
)
if /I "%ext1%"==".txt" (
    GOTO InvalidFirstFile
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请请选择一个 视频 文件，和一个 字幕 文件。
    pause
    exit /b 1
)

REM 构建 ffmpeg 命令
SET "ffmpeg_command=ffmpeg -i "%~nx1" -i "%~nx2" -map 0:v -map 0:a -map 1 -c:v copy -c:a copy -c:s mov_text -metadata:s:s:0 language="sub" -metadata:s:s:0 title="sub" "%~dpn1_软字幕.mp4""

REM 执行 ffmpeg 命令
%ffmpeg_command%
exit /b 0

:InvalidFirstFile
ECHO 奶酪提示你：
ECHO 第一个文件似乎是字幕文件，请确保第一个选择的是 视频 文件，然后再选择字幕文件。
pause
exit /b 1
