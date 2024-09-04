:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off
setlocal enabledelayedexpansion

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请至少选择“两个”图片文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 检查是否至少有两个输入文件
if "%~2"=="" (
    echo 奶酪提示你：请至少选择“两个”图片文件。
    pause
    exit /b 1
)

REM 获取第一张图片的高度
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "%%~fF" > temp_height.txt
    set /p firstImageHeight=<temp_height.txt
    del temp_height.txt
    goto :HeightObtained
)
:HeightObtained

REM 准备输入文件列表和输出文件名
set "inputFiles="
set "outputFile="
set "tempFiles="

REM 读取所有拖放的文件并重设高度为第一张图片的高度
set "index=0"
for %%F in (%*) do (
    if !index! equ 0 (
        set "outputFile=%%~dpnF_Hstack%%~xF"
    )
    set "tempFile=%%~dpnF_resized%%~xF"
    ffmpeg.exe -i "%%~fF" -vf "scale=-1:%firstImageHeight%" "!tempFile!"
    set "inputFiles=!inputFiles! -i "!tempFile!""
    set "tempFiles=!tempFiles! "!tempFile!""
    set /a index+=1
)

REM 合成图片为水平拼接
ffmpeg.exe %inputFiles% -filter_complex "hstack=inputs=%index%" "%outputFile%"

echo 输出文件: "%outputFile%"

REM 删除临时文件
for %%T in (!tempFiles!) do (
    if exist "%%~fT" del "%%~fT"
)

