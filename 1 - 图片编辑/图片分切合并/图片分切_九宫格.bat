:: by @RunningCheese�����ںţ������е�����

@echo off
setlocal enabledelayedexpansion

REM ����Ƿ�������һ�������ļ�
if "%~1"=="" (
    ECHO ������ʾ�㣺
    ECHO ����ֱ��˫�����д��ļ�����ѡ��ͼƬ�ļ����Ϸŵ��� BAT �ļ�ͼ���ϡ�
    pause
    exit /b 1
)

REM ���������ʱ�ļ����ļ���
set "tempFolder=%~dpn1_Temp"
if not exist "!tempFolder!" mkdir "!tempFolder!"

REM ��ʼ������
set "index=0"

REM ��������������ļ��������ǲü�Ϊ�����β��������ʱ�ļ�����
for %%F in (%*) do (
    ffprobe.exe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "%%~fF" > temp_size.txt
    for /f "tokens=1,2 delims=," %%A in (temp_size.txt) do (
        set "firstImageWidth=%%A"
        set "firstImageHeight=%%B"
        
        REM ����ü��ߴ�
        if !firstImageWidth! LSS !firstImageHeight! (
            set /a "cropSize=!firstImageWidth!"
            set /a "offsetX=0"
            set /a "offsetY=(!firstImageHeight!-!cropSize!)/2"
        ) else (
            set /a "cropSize=!firstImageHeight!"
            set /a "offsetX=(!firstImageWidth!-!cropSize!)/2"
            set /a "offsetY=0"
        )
        
        REM �ü�ͼƬΪ������
        set "squareImage=!tempFolder!\%%~nF_square%%~xF"
        ffmpeg.exe -i "%%~fF" -vf "crop=!cropSize!:!cropSize!:x=!offsetX!:y=!offsetY!" "!squareImage!"
        echo �Ѳü�Ϊ������: "!squareImage!"
    )
    del temp_size.txt
)

REM ��ȡ�ü����������ͼƬ�Ŀ�Ⱥ͸߶�
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

REM ������Ų���ͼƬ���ļ���
set "outputFolder=%~dpn1_Cropped9"
if not exist "!outputFolder!" mkdir "!outputFolder!"

REM ��������������ͼƬ�������ǲ���Ϊ���ȷݲ���ָ����������
for %%F in (!tempFolder!\*_square.*) do (
    for %%i in (0,1,2) do (
        for %%j in (0,1,2) do (
            set "positionTag="
            if %%i==0 if %%j==0 set "positionTag=_1����"
            if %%i==0 if %%j==2 set "positionTag=_3����"
            if %%i==2 if %%j==0 set "positionTag=_7����"
            if %%i==2 if %%j==2 set "positionTag=_9����"
            if %%i==0 if %%j==1 set "positionTag=_2����"
            if %%i==1 if %%j==0 set "positionTag=_4����"
            if %%i==1 if %%j==1 set "positionTag=_5����"
            if %%i==1 if %%j==2 set "positionTag=_6����"
            if %%i==2 if %%j==1 set "positionTag=_8����"

            set "outputFile=!outputFolder!\%%~nF!positionTag!%%~xF"
            ffmpeg.exe -i "%%~fF" -vf "crop=%cropWidth%:%cropHeight%:x=%%j*%cropWidth%:y=%%i*%cropHeight%" "!outputFile!"
            echo �ѱ���: "!outputFile!"
        )
    )
)

REM ɾ����ʱ�ļ���
rd /s /q "!tempFolder!"

REM �����ʾ
echo ���в��к��ͼƬ�ѱ��浽�ļ���: "!outputFolder!"
