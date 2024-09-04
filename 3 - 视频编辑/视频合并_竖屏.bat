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

REM 设置默认运行模式和编码方式，默认为 0 
REM 0 是 CPU，1 是 N卡， 2 是 A卡，3 是 HEVC+N卡，4 是 HEVC+A卡。
SET "gpu_codec_option=0"

REM 根据选项设置 ffmpeg 的硬件加速参数
SET "ffmpeg_hardware="
IF "%gpu_codec_option%"=="1" SET "ffmpeg_hardware=-c:v h264_nvenc"
IF "%gpu_codec_option%"=="2" SET "ffmpeg_hardware=-c:v h264_amf"
IF "%gpu_codec_option%"=="3" SET "ffmpeg_hardware=-c:v hevc_nvenc"
IF "%gpu_codec_option%"=="4" SET "ffmpeg_hardware=-c:v hevc_amf"

REM 创建临时文件夹用于存放生成的 1080x1920 视频
SET "temp_dir=%temp%\video_processing"
IF NOT EXIST "%temp_dir%" (
    mkdir "%temp_dir%"
)

REM 准备文件列表和输出文件名
SET "file_list=%temp_dir%\file_list.txt"
IF EXIST "%file_list%" DEL /F /Q "%file_list%"
SET "outputFile="
SET "index=0"

REM 遍历所有传入的文件夹路径
:process_files
IF "%~1"=="" GOTO merge_videos

REM 获取传入的文件路径
set "input_file=%~1"
SET "mp4File=%temp_dir%\%~n1_1080x1920.mp4"

REM 转换为 1080x1920 比例的 MP4 格式
echo 正在处理文件 "%input_file%"，请勿关闭窗口...
SET "scaleFilter=scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:black"
IF "%gpu_codec_option%"=="0" (
    ffmpeg -i "%input_file%" -vf "%scaleFilter%" "%mp4File%" -y
) ELSE (
    ffmpeg -i "%input_file%" -vf "%scaleFilter%" %ffmpeg_hardware% "%mp4File%" -y
)

REM 将生成的文件路径添加到文件列表
echo file '%mp4File%' >> "%file_list%"

REM 设置输出文件名
IF "!index!"=="0" (
    SET "outputFile=%~dp1%~n1_Merged.mp4"
)
SET /a index+=1

REM 移动到下一个文件
SHIFT
GOTO process_files

:merge_videos
IF NOT EXIST "%file_list%" GOTO end

REM 使用 ffmpeg 拼接视频文件
ffmpeg -f concat -safe 0 -i "%file_list%" -c copy "%outputFile%" -y

REM 删除生成的 1080x1920 视频
for /F "usebackq tokens=2 delims=''" %%F in ("%file_list%") do (
    set "filePath=%%~F"
    if exist "!filePath!" del /F /Q "!filePath!"
)

REM 删除临时文件列表
del /F /Q "%file_list%"

:end
ECHO 视频已成功拼接: "%outputFile%"
exit /b 0
