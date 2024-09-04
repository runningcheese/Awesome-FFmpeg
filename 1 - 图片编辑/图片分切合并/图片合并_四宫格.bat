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

REM 检查是否至少有四个输入文件
if "%~3"=="" (
    echo 奶酪提示你：请至少选择 3 个图片文件。
    pause
    exit /b 1
)

REM 获取第一张图片的宽度和高度，并计算比例
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        set /a "aspectRatio=firstImageWidth*100/firstImageHeight"
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM 初始化变量
set "inputFiles="
set "tempFiles="
set "index=0"
set "rowIndex=0"
set "rowFiles="
set "rowOutputs="
set "finalOutput=%~dpn1_Square%~x1"

REM 处理所有输入的文件，将它们拉伸为第一张图片的比例
for %%F in (%*) do (
    set "tempFile=%%~dpnF_resized%%~xF"
    ffmpeg.exe -i "%%~fF" -vf "scale=w=%firstImageWidth%:h=trunc(ow*100/%aspectRatio%):force_original_aspect_ratio=increase,crop=%firstImageWidth%:%firstImageHeight%" "!tempFile!"
    set "rowFiles=!rowFiles! -i "!tempFile!""
    set "tempFiles=!tempFiles! "!tempFile!""
    set /a index+=1

    if !index! equ 2 (
        set /a rowIndex+=1
        set "rowOutput=Row!rowIndex!_Hstack.png"
        ffmpeg.exe !rowFiles! -filter_complex "hstack=inputs=2" "!rowOutput!"
        set "rowOutputs=!rowOutputs! -i "!rowOutput!""
        set "tempFiles=!tempFiles! "!rowOutput!""
        set "rowFiles="
        set "index=0"
    )
)

REM 如果图片数量是奇数，生成一个与第一张图片比例相同的空白图像并补齐
if not "!rowFiles!"=="" (
    ffmpeg.exe -f lavfi -i color=c=white:s=%firstImageWidth%x%firstImageHeight% -vframes 1 blank.png
    set "tempFiles=!tempFiles! blank.png"
    set "rowFiles=!rowFiles! -i blank.png"

    set /a rowIndex+=1
    set "rowOutput=Row!rowIndex!_Hstack.png"
    ffmpeg.exe !rowFiles! -filter_complex "hstack=inputs=2" "!rowOutput!"
    set "rowOutputs=!rowOutputs! -i "!rowOutput!""
    set "tempFiles=!tempFiles! "!rowOutput!""
)

REM 将所有水平拼接的行垂直拼接在一起
ffmpeg.exe !rowOutputs! -filter_complex "vstack=inputs=!rowIndex!" "!finalOutput!"

echo 输出文件: "!finalOutput!"

REM 删除临时文件
for %%T in (!tempFiles!) do (
    if exist "%%~fT" del "%%~fT"
)
