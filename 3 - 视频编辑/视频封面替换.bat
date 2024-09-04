:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择一个 视频 文件，和一个 图片 文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请请选择一个 视频 文件，和一个 图片 文件。
    pause
    exit /b 1
)


REM 输入文件路径（假设第一个参数是视频，第二个是图片）
set firstFile=%1
set secondFile=%2

REM 获取文件扩展名
for %%X in ("%firstFile%") do set firstExt=%%~xX
for %%X in ("%secondFile%") do set secondExt=%%~xX

REM 判断哪个是视频文件
if "%firstExt%"==".mp4" (
    set videoFile=%firstFile%
    set imageFile=%secondFile%
) else if "%secondExt%"==".mp4" (
    set videoFile=%secondFile%
    set imageFile=%firstFile%
) else (
    echo 未找到有效的视频文件，请确保提供的文件格式正确。
    goto :end
)

REM 获取输入视频文件的目录和基名
for %%F in ("%videoFile%") do (
    set videoDir=%%~dpF
    set videoBaseName=%%~nF
)

REM 输出文件名和路径，基于原视频文件名
set outputFile=%videoDir%%videoBaseName%_covered.mp4

REM 使用 ffmpeg 替换视频封面
ffmpeg.exe ^
    -i "%videoFile%" ^
    -i "%imageFile%" ^
    -map 0 -map 1 ^
    -c copy ^
    -c:v:1 png ^
    -disposition:v:1 attached_pic ^
    "%outputFile%"

REM 检查 ffmpeg 的返回值是否成功
if NOT ["%errorlevel%"]==["0"] goto :error
echo 操作成功完成。
goto :end

:error
echo 操作失败，返回值：%errorlevel%.

:end
