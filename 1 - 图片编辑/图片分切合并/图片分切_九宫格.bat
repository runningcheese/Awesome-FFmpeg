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

REM 创建存放临时文件的文件夹
set "tempFolder=%~dpn1_Temp"
if not exist "!tempFolder!" mkdir "!tempFolder!"

REM 初始化变量
set "index=0"

REM 处理所有输入的文件，将它们裁剪为正方形并存放在临时文件夹中
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
        
        REM 裁剪图片为正方形
        set "squareImage=!tempFolder!\%%~nF_square%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=!cropSize!:!cropSize!:x=!offsetX!:y=!offsetY!" "!squareImage!"
        echo 已裁剪为正方形: "!squareImage!"
    )
    del temp_size.txt
)

REM 获取裁剪后的正方形图片的宽度和高度
for %%F in (!tempFolder!\*_square.*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        set /a "cropWidth=firstImageWidth/3"
        set /a "cropHeight=firstImageHeight/3"
    )
    del temp_size.txt
    goto :SizeObtained
)
:SizeObtained

REM 创建存放裁切图片的文件夹
set "outputFolder=%~dpn1_Cropped9"
if not exist "!outputFolder!" mkdir "!outputFolder!"

REM 处理所有正方形图片，将它们裁切为三等份并按指定命名保存
for %%F in (!tempFolder!\*_square.*) do (
    for %%i in (0,1,2) do (
        for %%j in (0,1,2) do (
            set "positionTag="
            if %%i==0 if %%j==0 set "positionTag=_1上左"
            if %%i==0 if %%j==2 set "positionTag=_3上右"
            if %%i==2 if %%j==0 set "positionTag=_7下左"
            if %%i==2 if %%j==2 set "positionTag=_9下右"
            if %%i==0 if %%j==1 set "positionTag=_2上中"
            if %%i==1 if %%j==0 set "positionTag=_4中左"
            if %%i==1 if %%j==1 set "positionTag=_5中中"
            if %%i==1 if %%j==2 set "positionTag=_6中右"
            if %%i==2 if %%j==1 set "positionTag=_8下中"

            set "outputFile=!outputFolder!\%%~nF!positionTag!%%~xF"
            ffmpeg.exe -i "%%~fF" -vf "crop=%cropWidth%:%cropHeight%:x=%%j*%cropWidth%:y=%%i*%cropHeight%" "!outputFile!"
            echo 已保存: "!outputFile!"
        )
    )
)

REM 删除临时文件夹
rd /s /q "!tempFolder!"

REM 完成提示
echo 所有裁切后的图片已保存到文件夹: "!outputFolder!"
