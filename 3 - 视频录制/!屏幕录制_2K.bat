:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

:: 获取当前日期和时间
set "mydate=%date:~0,4%-%date:~5,2%"
set "mytime=%time:~0,2%-%time:~3,2%-%time:~6,2%"

:: 删除前导空格
set mytime=%mytime: =0%

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

:: 执行 ffmpeg 命令
ffmpeg -f gdigrab -framerate 30 -draw_mouse 1 -offset_x 0 -offset_y 0 -video_size 2560x1440 -i desktop %ffmpeg_hardware% "%USERPROFILE%\Downloads\Record_%mydate%_%mytime%.mp4"

:: 录制结束提示
echo 录制完成！视频已保存至下载文件夹。
