:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个视频文件，和一个音频文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请选择一个视频文件，和一个音频文件，可能两个都是 mp4 格式的。
    pause
    exit /b 1
)

REM 输入文件
set "videoFile=%~1"
set "audioFile=%~2"

REM 获取输入视频文件的目录和基名
for %%F in ("%videoFile%") do (
    set "videoDir=%%~dpF"
    set "videoBaseName=%%~nF"
)

REM 输出文件名和路径
set "outputFile=%videoDir%%videoBaseName%_Merged.mp4"

REM 检查 ffmpeg 是否存在
where /Q ffmpeg.exe
if %ERRORLEVEL% neq 0 (
    echo 奶酪提示你：找不到 ffmpeg.exe，请确保 ffmpeg 已正确安装并配置到系统 PATH。
    pause
    exit /b 1
)

REM 使用 ffmpeg 合并音频和视频
ffmpeg.exe -i "%videoFile%" -i "%audioFile%" -vcodec copy -acodec copy -movflags faststart "%outputFile%"

REM 检查合并是否成功
if %ERRORLEVEL% neq 0 (
    echo 奶酪提示你：合并失败，请检查输入文件是否正确。
    pause
    exit /b 1
)

echo 奶酪提示你：合并成功，输出文件为：
echo %outputFile%
