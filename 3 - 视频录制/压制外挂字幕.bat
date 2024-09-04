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

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

REM 构建 ffmpeg 命令
SET "ffmpeg_command=ffmpeg -i "%~nx1" -vf subtitles="filename='%~nx2':force_style='FontSize=20,FontName=Microsoft Yahei'""

REM 如果有硬件加速参数，添加到命令中
if not "%ffmpeg_hardware%"=="" (
    SET "ffmpeg_command=%ffmpeg_command% %ffmpeg_hardware%"
)

REM 添加其他参数
SET "ffmpeg_command=%ffmpeg_command% -x264-params crf=22 -preset fast -profile:v high "%~dpn1_硬字幕.mp4""

REM 执行 ffmpeg 命令
%ffmpeg_command%
exit /b 0

:InvalidFirstFile
ECHO 奶酪提示你：
ECHO 请确保选中视频和字幕文件后，鼠标最后是放在“视频”图标上的，然后再拖入 BAT 脚本。
pause
exit /b 1
