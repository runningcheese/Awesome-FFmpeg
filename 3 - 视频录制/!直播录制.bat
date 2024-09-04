:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

:: 设置默认运行模式和编码方式，默认为 0 
:: 0 是 CPU，1 是 N卡，2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

:: 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

:: 获取当前日期和时间
set "mydate=%date:~0,4%-%date:~5,2%"
set "mytime=%time:~0,2%-%time:~3,2%-%time:~6,2%"

:: 删除前导空格
set mytime=%mytime: =0%

:: 提示用户输入直播流地址
set /p stream_url=请输入直播流地址，按 Q 或 Ctrl+C 中止： 

:: 检查用户是否输入了直播流地址
if "%stream_url%"=="" (
    echo 您未输入直播流地址，程序将退出。
    pause
    exit /b
)

:: 执行 ffmpeg 命令
ffmpeg -i "%stream_url%" %ffmpeg_hardware% -c copy "%USERPROFILE%\Downloads\LiveRecord_%mydate%_%mytime%.mp4"

:: 录制结束提示
echo 录制完成！视频已保存至「下载」文件夹。
pause
