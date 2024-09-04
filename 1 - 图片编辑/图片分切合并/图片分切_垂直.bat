:: by @RunningCheese，公众号：奔跑中的奶酪

@echo off
setlocal enabledelayedexpansion

REM 检查是否有至少一个输入文件
if "%~1"=="" (
    ECHO 奶酪提示你：
    ECHO 请勿直接双击运行此文件，请选择图片文件，拖放到此 BAT 文件图标上。
    pause
    exit /b 1
)

REM 获取第一张图片的宽度和高度
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        set /a "cropWidth=firstImageWidth/2"
        set "cropHeight=!firstImageHeight!"  REM 保持高度不变
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM 初始化变量
set "index=0"

REM 处理所有输入的文件，将它们水平二等分并按指定命名保存
for %%F in (%*) do (
    for %%j in (0,1) do (
        set "positionTag="
        if %%j==0 set "positionTag=_1左半"
        if %%j==1 set "positionTag=_2右半"

        set "outputFile=%%~dpnF!positionTag!%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=%cropWidth%:%cropHeight%:x=%%j*%cropWidth%:y=0" "!outputFile!"
        echo 已保存: "!outputFile!"
    )
)

REM 完成提示
echo 所有裁切后的图片已保存到原图片的目录下。
