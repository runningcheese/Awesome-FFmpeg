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

REM 创建临时文件夹以保存中间文件
set "tempFolder=%~dpn1_Temp"
if not exist "!tempFolder!" mkdir "!tempFolder!"

REM 获取第一张图片的宽度和高度，并裁剪为正方形
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        
        REM 计算裁剪尺寸
        if !firstImageWidth! LSS !firstImageHeight! (
            set /a "cropSize=!firstImageWidth!"
            set /a "offsetX=0"
            set /a "offsetY=(!firstImageHeight!-!cropSize!)/2"
        ) else (
            set /a "cropSize=!firstImageHeight!"
            set /a "offsetX=(!firstImageWidth!-!cropSize!)/2"
            set /a "offsetY=0"
        )
        
        REM 调试输出变量值
        echo cropSize=!cropSize! offsetX=!offsetX! offsetY=!offsetY!
        
        REM 裁剪图片为正方形
        set "squareImage=!tempFolder!\%%~nF_square%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=!cropSize!:!cropSize!:x=!offsetX!:y=!offsetY!" "!squareImage!"
        echo 已裁剪为正方形: "!squareImage!"
    )
    del temp_size.txt
    goto :SquareCropped
)
:SquareCropped

REM 创建存放裁切图片的文件夹
set "outputFolder=%~dpn1_Cropped4"
if not exist "!outputFolder!" mkdir "!outputFolder!"

REM 初始化变量
set "index=0"

REM 处理所有输入的文件，将它们裁切为四等份并按指定命名保存
for %%F in (%tempFolder%\*_square*) do (
    set /a "cropWidth=!cropSize!/2"
    set /a "cropHeight=!cropSize!/2"
    
    for %%i in (0,1) do (
        for %%j in (0,1) do (
            set "positionTag="
            if %%i==0 if %%j==0 set "positionTag=_1左上"
            if %%i==0 if %%j==1 set "positionTag=_2右上"
            if %%i==1 if %%j==0 set "positionTag=_3左下"
            if %%i==1 if %%j==1 set "positionTag=_4右下"

            set "outputFile=!outputFolder!\%%~nF!positionTag!%%~xF"
            ffmpeg.exe -i "%%~fF" -vf "crop=!cropWidth!:!cropHeight!:x=%%j*!cropWidth!:y=%%i*!cropHeight!" "!outputFile!"
            echo 已保存: "!outputFile!"
        )
    )
)

REM 删除临时文件夹
rmdir /s /q "!tempFolder!"

REM 完成提示
echo 所有裁切后的图片已保存到文件夹: "!outputFolder!"


