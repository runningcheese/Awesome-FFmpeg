:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off
setlocal enabledelayedexpansion

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请至少选择“两个”图片文件，拖放到此 BAT 文件图标上，支持传入 mp3 作为背景音乐。
    pause
    exit /b 1
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请至少选择“两个”图片文件，支持传入 mp3 作为背景音乐。
    pause
    exit /b 1
)

REM 设置每张图片的持续时间，默认 5 秒
SET Time=5

REM 准备输入文件列表和输出文件名
set "fileList="
set "outputFile="
set "audioFile="
set "imageList="

REM 读取所有拖放的文件并将其加入输入列表
set "index=0"
set "concatFilter="
for %%F in (%*) do (
    if /I "%%~xF"==".mp3" (
        REM 如果文件是 MP3，则将其设置为背景音乐
        set "audioFile=%%F"
    ) else (
        if !index! equ 0 (
            REM 将输出文件名设置为第一个图片文件的路径和文件名
            set "outputFile=%%~dpF%%~nF_Portrait.mp4"
        )
        REM 将每个图片文件加入文件列表
        set "imageList=!imageList! %%F"
        REM 将图片文件调整为1080x1920分辨率
        ffmpeg.exe -i %%F -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setdar=9/16" -q:v 1 "temp_!index!.jpg"
        set "fileList=!fileList! -loop 1 -t %Time% -i temp_!index!.jpg"
        REM 构造 concat 过滤器部分
        set "concatFilter=!concatFilter![!index!:v] "
        set /a index+=1
    )
)

REM 如果没有图片文件，退出
if !index! equ 0 (
    echo 未找到图片文件，请提供图片文件。
    exit /b 1
)

REM 去掉最后一个空格，并完成过滤器
set "concatFilter=%concatFilter:~0,-1% concat=n=!index!:v=1:a=0,format=yuv420p,setsar=1,setdar=9/16"

REM 计算视频总时长（每张图片时间 * 图片数量）
set /a totalDuration=index*%Time%

REM 构造 ffmpeg 命令
set "ffmpegCmd=ffmpeg.exe %fileList%"

REM 如果发现了音频文件，将其加入 ffmpeg 命令中，并设置音频循环
if defined audioFile (
    REM -stream_loop -1 用于让音频无限循环，直到视频结束
    set "ffmpegCmd=!ffmpegCmd! -stream_loop -1 -i !audioFile!"
)

REM 添加过滤器将图片连接成视频，视频时长基于图片时长
set "ffmpegCmd=!ffmpegCmd! -filter_complex "!concatFilter!" -vsync vfr -pix_fmt yuv420p"

REM 如果有音频文件，确保音频循环直到视频结束，并同步音频与视频
if defined audioFile (
    set "ffmpegCmd=!ffmpegCmd! -t !totalDuration! -c:a aac -b:a 192k"
)

REM 设置输出文件名
set "ffmpegCmd=!ffmpegCmd! "%outputFile%""

REM 执行 ffmpeg 命令
!ffmpegCmd!

REM 清理临时文件
for /L %%i in (0,1,!index!-1) do del temp_%%i.jpg

echo 输出文件: !outputFile!
