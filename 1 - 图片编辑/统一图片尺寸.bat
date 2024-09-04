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

REM 获取第一张图片的宽度和高度
for %%F in (%*) do (
    REM 获取图片的宽度
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 %%F > temp_width.txt
    set /p firstImageWidth=<temp_width.txt
    del temp_width.txt

    REM 获取图片的高度
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 %%F > temp_height.txt
    set /p firstImageHeight=<temp_height.txt
    del temp_height.txt

    REM 检查是否成功获取到尺寸
    if not defined firstImageWidth (
        echo 无法获取第一张图片的宽度。
        pause
        exit /b 1
    )
    if not defined firstImageHeight (
        echo 无法获取第一张图片的高度。
        pause
        exit /b 1
    )

    goto :WidthObtained
)
:WidthObtained

REM 确保尺寸值被正确设置
if "%firstImageWidth%"=="" (
    echo 未能获取图片宽度，请检查文件是否有效。
    pause
    exit /b 1
)

REM 获取第一个文件的名称（不包含扩展名）
for %%F in (%1) do set "folderName=%%~nF_Unisize"

REM 创建以第一个文件名为名称的文件夹
mkdir "%folderName%"

REM 处理所有拖放的文件并将结果保存到新创建的文件夹中
for %%F in (%*) do (
    set "outputFile=%folderName%\%%~nF%%~xF"
    echo 处理 %%F 并输出到 !outputFile!
    ffmpeg.exe -i %%F -vf "scale=w=%firstImageWidth%:h=-1, pad=%firstImageWidth%:%firstImageHeight%:(ow-iw)/2:(oh-ih)/2:white" "!outputFile!" 2>nul
    if errorlevel 1 (
        echo 处理 %%F 失败，请检查文件和命令。
        pause
        exit /b 1
    )
)

echo 所有图片已调整为宽度：%firstImageWidth% 高度：%firstImageHeight% 并保存到文件夹：%folderName%
