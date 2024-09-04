:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个带“内嵌字幕”的视频文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

REM 如果没有选择硬件加速选项，默认使用软件编码器
IF "%ffmpeg_hardware%"=="" SET "ffmpeg_hardware=-c:v libx264"

REM 执行 ffmpeg 命令
ffmpeg -i "%~nx1" -vf subtitles="filename='%~nx1':force_style='FontSize=20,FontName=Microsoft Yahei'" %ffmpeg_hardware% -x264-params crf=22 -preset fast -profile:v high "%~dpn1_output.mp4"
